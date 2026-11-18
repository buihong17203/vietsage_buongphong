import 'dart:async';
import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/api_manager.dart';
import '../api/model/room_model.dart';
import '../api/realtime_client.dart';
import '../notification_helper.dart';
import '../res/layout/activity_home_layout.dart';
import '../session_store.dart';
import 'login_activity.dart';
import 'profile_activity.dart';
import 'qr_scanner_activity.dart';
import 'task_detail_activity.dart';

class HomeActivity extends StatefulWidget {
  const HomeActivity({super.key});

  @override
  State<HomeActivity> createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  final List<RoomModel> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  late final SessionStore _session;
  late final ApiClient _api;
  final RealtimeClient _realtime = RealtimeClient();
  final Set<String> _knownProcessingIds = {};
  bool _isFirstLoad = true;
  Timer? _periodicSyncTimer;

  @override
  void initState() {
    super.initState();
    _session = SessionStore.instance;

    if (!_session.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginActivity()),
        );
      });
      return;
    }

    _api = ApiManager.getInstance(_session).client;
    _session.addListener(_onSessionChanged);

    loadRoomsAndTasks();
    _startRealtime();
    _fetchUserProfile();
    _startPeriodicSync();
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    _realtime.close();
    _periodicSyncTimer?.cancel();
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  void _startPeriodicSync() {
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_session.active && mounted) {
        _pollProcessingRooms();
      }
    });
  }

  void _startRealtime() {
    _realtime.connect(_session, (eventName, payload) {
      debugPrint('[HomeActivity] Realtime event: $eventName, payload=$payload');
      if (!mounted) return;

      if (eventName == 'room_status.updated' ||
          eventName == 'housekeeping_task.created' ||
          eventName == 'housekeeping_task.completed' ||
          eventName == 'housekeeping_task.started' ||
          eventName == 'housekeeping_task.claimed') {
        final status = (payload['status'] ?? '').toString();
        final roomNumber = (payload['roomNumber'] ?? payload['number'] ?? '').toString();

        if (status == 'PROCESSING' && roomNumber.isNotEmpty) {
          final notifId = roomNumber.hashCode.abs();
          // Nổ thông báo hệ thống ra màn hình thiết bị (kèm rung và chuông)
          NotificationHelper.showSystemNotification(
            id: notifId,
            title: '🔔 PHÒNG CẦN DỌN: PHÒNG $roomNumber',
            body: 'Phòng $roomNumber vừa check-out, cần dọn dẹp ngay!',
          );

          NotificationHelper.showAlertBanner(
            context,
            title: '🔔 PHÒNG CẦN DỌN: PHÒNG $roomNumber',
            message: 'Phòng $roomNumber vừa check-out, cần dọn dẹp ngay!',
            onTap: () => loadRoomsAndTasks(),
          );
        } else if (status == 'AVAILABLE' && roomNumber.isNotEmpty) {
          final notifId = roomNumber.hashCode.abs() + 10000;
          NotificationHelper.showSystemNotification(
            id: notifId,
            title: '✅ PHÒNG $roomNumber ĐÃ DỌN XONG',
            body: 'Phòng $roomNumber đã sẵn sàng đón khách.',
          );

          NotificationHelper.showAlertBanner(
            context,
            title: '✅ PHÒNG $roomNumber ĐÃ DỌN XONG',
            message: 'Phòng $roomNumber đã sẵn sàng đón khách.',
          );
        }

        loadRoomsAndTasks();
      }
    });
  }

  void _pollProcessingRooms() {
    final hotelId = _session.hotelId;
    _api.request('GET', '/hotels/${Uri.encodeComponent(hotelId)}/rooms?status=PROCESSING&limit=100', null, (data, error) {
      if (error != null || data == null || !mounted) return;
      final items = data['items'] ?? data['data'];
      if (items is! List) return;

      final currentIds = <String>{};
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final id = (item['id'] ?? item['_id'] ?? '').toString();
          currentIds.add(id);

          if (!_isFirstLoad && !_knownProcessingIds.contains(id)) {
            final roomNumber = (item['roomNumber'] ?? item['number'] ?? '--').toString();
            final floor = (item['floor'] ?? '--').toString();
            final notifId = roomNumber.hashCode.abs();

            // Nổ thông báo hệ thống ra thiết bị
            NotificationHelper.showSystemNotification(
              id: notifId,
              title: '🔔 PHÒNG CẦN DỌN: PHÒNG $roomNumber',
              body: 'Phòng $roomNumber (Tầng $floor) vừa trả phòng, cần dọn dẹp!',
            );

            NotificationHelper.showAlertBanner(
              context,
              title: '🔔 PHÒNG CẦN DỌN: PHÒNG $roomNumber',
              message: 'Phòng $roomNumber (Tầng $floor) vừa trả phòng, cần dọn dẹp!',
              onTap: () => loadRoomsAndTasks(),
            );
          }
        }
      }

      _knownProcessingIds.clear();
      _knownProcessingIds.addAll(currentIds);
      _isFirstLoad = false;
    });
  }

  void _fetchUserProfile() {
    _api.fetchUserProfile((name, role, hotelId, hotelName, error) {
      if (error == null && mounted) {
        if (name.isNotEmpty && name != 'null') _session.setStaffName(name);
        if (role.isNotEmpty && role != 'null') _session.setStaffRole(role);
        if (hotelName.isNotEmpty) _session.setHotel(_session.hotelId, hotelName);
      }
    });
  }

  Future<void> loadRoomsAndTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final hotelId = _session.hotelId;
    final completer = Completer<void>();

    // 1. Chỉ lấy phòng có trạng thái PROCESSING (Khách vừa trả / cần dọn)
    _api.request('GET', '/hotels/${Uri.encodeComponent(hotelId)}/rooms?status=PROCESSING&limit=100', null, (roomData, roomError) {
      if (!mounted) {
        completer.complete();
        return;
      }

      final mergedMap = <String, RoomModel>{};

      if (roomData != null) {
        final items = roomData['items'] ?? roomData['data'];
        if (items is List) {
          for (final it in items) {
            if (it is Map<String, dynamic>) {
              final r = RoomModel.fromJson(it);
              if (r.status == 'PROCESSING') {
                mergedMap[r.id] = r;
              }
            }
          }
        }
      }

      // 2. Lấy danh sách nhiệm vụ dọn phòng đang hoạt động
      _api.request('GET', '/hotels/${Uri.encodeComponent(hotelId)}/housekeeping/tasks?limit=100', null, (taskData, taskError) {
        if (!mounted) {
          completer.complete();
          return;
        }

        if (roomError != null && taskError != null) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Không thể kết nối máy chủ: ${roomError.message}';
          });
          completer.complete();
          return;
        }

        if (taskData != null) {
          final tItems = taskData['items'] ?? taskData['data'];
          if (tItems is List) {
            for (final it in tItems) {
              if (it is Map<String, dynamic>) {
                final status = (it['status'] ?? '').toString().toUpperCase();
                // Bỏ qua các công việc đã dọn xong hoặc bị hủy
                if (status == 'COMPLETED' || status == 'CANCELLED' || status == 'AVAILABLE') {
                  continue;
                }

                final rId = (it['roomId'] ?? it['id'] ?? '').toString();
                final existing = mergedMap[rId];
                final effectiveStatus = (status == 'IN_PROGRESS' || status == 'CLAIMED') ? status : (existing?.status ?? 'PROCESSING');
                final staffName = it['assignedToName']?.toString() ?? it['assignedName']?.toString() ?? existing?.assignedToName;

                if (existing != null) {
                  mergedMap[rId] = existing.copyWith(
                    status: effectiveStatus,
                    taskId: it['id']?.toString(),
                    taskStatus: it['status']?.toString(),
                    priority: it['priority']?.toString(),
                    assignedTo: it['assignedTo']?.toString(),
                    assignedToName: staffName,
                    description: it['description']?.toString(),
                  );
                } else {
                  // Thêm phòng từ danh sách công việc chưa hoàn thành
                  mergedMap[rId] = RoomModel(
                    id: rId,
                    roomNumber: (it['roomNumber'] ?? it['number'] ?? '--').toString(),
                    floor: (it['floor'] ?? it['roomFloor'] ?? '').toString(),
                    roomType: (it['roomType'] ?? it['type'] ?? 'Tiêu chuẩn').toString(),
                    status: effectiveStatus,
                    taskId: it['id']?.toString(),
                    taskStatus: it['status']?.toString(),
                    priority: it['priority']?.toString(),
                    assignedTo: it['assignedTo']?.toString(),
                    assignedToName: staffName,
                    description: it['description']?.toString(),
                  );
                }
              }
            }
          }
        }

        // Lọc strictly: Chỉ hiển thị phòng cần dọn (loại bỏ hoàn toàn phòng AVAILABLE / đã sạch / đang có khách)
        final roomsToClean = mergedMap.values.where((r) {
          final s = r.status.toUpperCase();
          return s != 'AVAILABLE' && s != 'COMPLETED' && s != 'OCCUPIED' && s != 'CANCELLED';
        }).toList();

        // Sắp xếp danh sách phòng theo thứ tự: Tầng -> Phòng
        int extractNumber(String s) {
          final match = RegExp(r'\d+').firstMatch(s);
          return match != null ? int.tryParse(match.group(0)!) ?? 0 : 0;
        }

        roomsToClean.sort((a, b) {
          // 1. So sánh Tầng (Floor) trước
          final floorNumA = extractNumber(a.floor);
          final floorNumB = extractNumber(b.floor);
          if (floorNumA != floorNumB) {
            return floorNumA.compareTo(floorNumB);
          }
          final floorStrCmp = a.floor.compareTo(b.floor);
          if (floorStrCmp != 0) return floorStrCmp;

          // 2. Cùng tầng thì so sánh tiếp theo số Phòng (Room)
          final roomNumA = extractNumber(a.roomNumber);
          final roomNumB = extractNumber(b.roomNumber);
          if (roomNumA != roomNumB) {
            return roomNumA.compareTo(roomNumB);
          }
          return a.roomNumber.compareTo(b.roomNumber);
        });

        setState(() {
          _rooms.clear();
          _rooms.addAll(roomsToClean);
          _isLoading = false;
        });
        completer.complete();
      });
    });

    return completer.future;
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileActivity()),
    );
  }

  void _openQrScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QrScannerActivity()),
    );
  }

  void _openTaskDetail(RoomModel room) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (_) => TaskDetailActivity(room: room)),
    );
    if (!mounted) return;
    if (result is RoomModel) {
      setState(() {
        final idx = _rooms.indexWhere((r) => r.id == result.id);
        if (idx != -1) {
          if (result.status == 'AVAILABLE' || result.status == 'COMPLETED') {
            _rooms.removeAt(idx);
          } else {
            _rooms[idx] = result;
          }
        }
      });
    }
    loadRoomsAndTasks();
  }

  @override
  Widget build(BuildContext context) {
    final staffSubtitle = _session.staffName.isNotEmpty && _session.staffName != _session.staffRole
        ? '${_session.staffName} (${_session.staffRole})'
        : _session.staffRole;

    return ActivityHomeLayout(
      hotelName: _session.hotelName,
      staffSubtitle: staffSubtitle,
      rooms: _rooms,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      onRefresh: loadRoomsAndTasks,
      onProfileClick: _openProfile,
      onScanQrClick: _openQrScanner,
      onRoomClick: _openTaskDetail,
    );
  }
}
