import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/api_manager.dart';
import '../api/model/room_model.dart';
import '../res/layout/activity_task_detail_layout.dart';
import '../session_store.dart';

class TaskDetailActivity extends StatefulWidget {
  final RoomModel room;

  const TaskDetailActivity({super.key, required this.room});

  @override
  State<TaskDetailActivity> createState() => _TaskDetailActivityState();
}

class _TaskDetailActivityState extends State<TaskDetailActivity> {
  late RoomModel _currentRoom;
  bool _isBusy = false;
  String? _errorMessage;

  late final SessionStore _session;
  late final ApiClient _api;

  @override
  void initState() {
    super.initState();
    _currentRoom = widget.room;
    _session = SessionStore.instance;
    _api = ApiManager.getInstance(_session).client;

    _loadLatestRoomInfo();
  }

  void _loadLatestRoomInfo() {
    final hotelId = _session.hotelId;
    _api.request('GET', '/hotels/${Uri.encodeComponent(hotelId)}/rooms/${Uri.encodeComponent(_currentRoom.id)}', null, (data, error) {
      if (!mounted) return;
      if (error == null && data != null) {
        setState(() {
          _currentRoom = RoomModel.fromJson(data).copyWith(
            taskId: _currentRoom.taskId,
            taskStatus: _currentRoom.taskStatus,
            priority: _currentRoom.priority,
            assignedToName: _currentRoom.assignedToName,
          );
        });
      }
    });

    if (_currentRoom.taskId != null && _currentRoom.taskId!.isNotEmpty) {
      _api.request('GET', '/hotels/${Uri.encodeComponent(hotelId)}/housekeeping/tasks/${Uri.encodeComponent(_currentRoom.taskId!)}', null, (tData, tError) {
        if (!mounted) return;
        if (tError == null && tData != null) {
          setState(() {
            _currentRoom = _currentRoom.copyWith(
              taskStatus: tData['status']?.toString(),
              priority: tData['priority']?.toString(),
              assignedToName: tData['assignedToName']?.toString() ?? tData['assignedName']?.toString(),
              description: tData['description']?.toString(),
            );
          });
        }
      });
    }
  }

  // Bấm bắt đầu dọn phòng là bắt đầu dọn luôn, không cần xác nhận gì thêm
  void _startCleanImmediately() {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    final hotelId = _session.hotelId;

    void performClaimAndStart(String tId, int tVersion) {
      // 1. Claim task
      _api.request('POST', '/hotels/${Uri.encodeComponent(hotelId)}/housekeeping/tasks/${Uri.encodeComponent(tId)}/claim', {'expectedVersion': tVersion}, (cData, cErr) {
        // 2. Start task ngay sau khi claim
        _api.request('POST', '/hotels/${Uri.encodeComponent(hotelId)}/housekeeping/tasks/${Uri.encodeComponent(tId)}/start', {'expectedVersion': tVersion}, (sData, sErr) {
          if (!mounted) return;
          setState(() => _isBusy = false);

          // Cập nhật trạng thái phòng sang Đang dọn
          setState(() {
            _currentRoom = _currentRoom.copyWith(
              status: 'IN_PROGRESS',
              taskStatus: 'IN_PROGRESS',
              taskId: tId,
              assignedToName: _session.staffName,
            );
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bắt đầu dọn phòng ${_currentRoom.roomNumber}!'),
              backgroundColor: const Color(0xFF0F766E),
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      });
    }

    if (_currentRoom.taskId != null && _currentRoom.taskId!.isNotEmpty) {
      performClaimAndStart(_currentRoom.taskId!, _currentRoom.version);
    } else {
      // Nếu phòng chưa có task, tạo task mới trên hệ thống trước
      final body = {
        'roomId': _currentRoom.id,
        'priority': _currentRoom.priority ?? 'NORMAL',
        'notes': 'Yêu cầu dọn dẹp buồng phòng',
      };
      _api.request('POST', '/hotels/${Uri.encodeComponent(hotelId)}/housekeeping/tasks', body, (data, error) {
        if (!mounted) return;
        if (error != null || data == null) {
          // Fallback cập nhật cục bộ nếu offline hoặc tạo task bị từ chối
          setState(() {
            _isBusy = false;
            _currentRoom = _currentRoom.copyWith(
              status: 'IN_PROGRESS',
              assignedToName: _session.staffName,
            );
          });
          return;
        }

        final newTaskId = (data['id'] ?? data['_id'] ?? '').toString();
        final newVersion = data['version'] is int ? data['version'] as int : 1;
        if (newTaskId.isNotEmpty) {
          performClaimAndStart(newTaskId, newVersion);
        } else {
          setState(() {
            _isBusy = false;
            _currentRoom = _currentRoom.copyWith(
              status: 'IN_PROGRESS',
              assignedToName: _session.staffName,
            );
          });
        }
      });
    }
  }

  // Popup xác nhận khi bấm nút "Đã dọn xong" phòng trường hợp bấm nhầm
  void _confirmComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Xác nhận đã dọn xong?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc chắn phòng ${_currentRoom.roomNumber} đã được dọn sạch sẽ hay chưa?\n\nPhòng sẽ được đổi sang trạng thái "Đã dọn" và thông báo hoàn tất tới Lễ tân.',
          style: const TextStyle(fontSize: 14.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Chưa xong'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _markRoomReady();
            },
            child: const Text('Xác nhận đã dọn xong'),
          ),
        ],
      ),
    );
  }

  void _markRoomReady() {
    setState(() => _isBusy = true);
    final hotelId = _session.hotelId;

    void finalizeReady() {
      final path = '/hotels/${Uri.encodeComponent(hotelId)}/rooms/${Uri.encodeComponent(_currentRoom.id)}/ready';
      _api.request('PATCH', path, {}, (data, error) {
        if (!mounted) return;
        setState(() => _isBusy = false);
        if (error != null) {
          setState(() => _errorMessage = 'Lỗi cập nhật: ${error.message}');
          return;
        }

        setState(() {
          _currentRoom = _currentRoom.copyWith(
            status: 'AVAILABLE',
            taskStatus: 'COMPLETED',
          );
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Dọn phòng thành công'),
            content: Text('Phòng ${_currentRoom.roomNumber} đã dọn xong!'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(_currentRoom);
                },
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      });
    }

    if (_currentRoom.taskId != null && _currentRoom.taskId!.isNotEmpty) {
      final completePath = '/hotels/${Uri.encodeComponent(hotelId)}/housekeeping/tasks/${Uri.encodeComponent(_currentRoom.taskId!)}/complete';
      _api.request('POST', completePath, {'expectedVersion': _currentRoom.version}, (cData, cErr) {
        finalizeReady();
      });
    } else {
      finalizeReady();
    }
  }

  void _confirmReclean() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Báo phòng cần dọn lại'),
        content: Text('Chuyển phòng ${_currentRoom.roomNumber} về trạng thái "Cần dọn"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () {
              Navigator.of(ctx).pop();
              _recleanRoom();
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  void _recleanRoom() {
    setState(() => _isBusy = true);
    final hotelId = _session.hotelId;
    final path = '/hotels/${Uri.encodeComponent(hotelId)}/rooms/${Uri.encodeComponent(_currentRoom.id)}/re-clean';

    _api.request('POST', path, {}, (data, error) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      if (error != null) {
        setState(() => _errorMessage = error.message);
        return;
      }
      setState(() {
        _currentRoom = _currentRoom.copyWith(status: 'PROCESSING');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phòng ${_currentRoom.roomNumber} đã chuyển về Cần dọn')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_currentRoom);
      },
      child: ActivityTaskDetailLayout(
        room: _currentRoom,
        isBusy: _isBusy,
        errorMessage: _errorMessage,
        onBackClick: () => Navigator.of(context).pop(_currentRoom),
        onStartCleanClick: _startCleanImmediately,
        onCompleteClick: _confirmComplete,
        onRecleanClick: _confirmReclean,
      ),
    );
  }
}
