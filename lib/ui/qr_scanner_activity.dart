import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../api/api_client.dart';
import '../api/api_manager.dart';
import '../api/model/room_model.dart';
import '../res/layout/activity_qr_scanner_layout.dart';
import '../res/layout/dialog_qr_result_layout.dart';
import '../session_store.dart';
import 'task_detail_activity.dart';
import 'web_view_activity.dart';

class QrScannerActivity extends StatefulWidget {
  const QrScannerActivity({super.key});

  @override
  State<QrScannerActivity> createState() => _QrScannerActivityState();
}

class _QrScannerActivityState extends State<QrScannerActivity> {
  late final MobileScannerController _scannerController;
  bool _isFlashOn = false;
  bool _isHandling = false;

  late final SessionStore _session;
  late final ApiClient _api;

  @override
  void initState() {
    super.initState();
    _session = SessionStore.instance;
    _api = ApiManager.getInstance(_session).client;
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isHandling) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null && code.trim().isNotEmpty) {
        _isHandling = true;
        _handleQrResult(code.trim());
      }
    }
  }

  void _toggleFlash() {
    _scannerController.toggleTorch();
    setState(() => _isFlashOn = !_isFlashOn);
  }

  void _showManualInputDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nhập mã hoặc số phòng'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập số phòng (VD: 101) hoặc link QR',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = textController.text.trim();
              Navigator.of(ctx).pop();
              if (val.isNotEmpty) {
                _isHandling = true;
                _handleQrResult(val);
              }
            },
            child: const Text('Xem phòng'),
          ),
        ],
      ),
    );
  }

  void _handleQrResult(String content) {
    _showLoadingDialog('Đang tìm kiếm thông tin phòng...');

    final hotelId = _session.hotelId;

    // Check if plain room number was entered (e.g. "101", "P102")
    final cleanNum = content.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNum.isNotEmpty && cleanNum.length <= 4 && !content.contains('/')) {
      _lookupRoomByNumber(hotelId, cleanNum, content);
      return;
    }

    // Try QR lookup via housekeeping API
    _api.request('GET', '/hotels/housekeeping/rooms/by-qr/${Uri.encodeComponent(content)}', null, (data, error) {
      if (!mounted) return;
      _hideLoadingDialog();

      if (error == null && data != null && data['roomNumber'] != null) {
        final room = RoomModel.fromJson(data);
        _openTaskDetail(room);
        return;
      }

      // If it's a URL or arbitrary QR code, show QR Result Dialog
      _showResultDialog(content);
    });
  }

  void _lookupRoomByNumber(String hotelId, String roomNum, String rawInput) {
    _api.request('GET', '/hotels/${Uri.encodeComponent(hotelId)}/rooms?number=${Uri.encodeComponent(roomNum)}', null, (data, error) {
      if (!mounted) return;
      _hideLoadingDialog();

      if (error == null && data != null) {
        final items = data['items'] ?? data['data'];
        if (items is List && items.isNotEmpty) {
          final room = RoomModel.fromJson(items.first as Map<String, dynamic>);
          _openTaskDetail(room);
          return;
        }
      }
      _showResultDialog(rawInput);
    });
  }

  void _openTaskDetail(RoomModel room) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TaskDetailActivity(room: room)),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(color: Color(0xFF0F766E)),
            const SizedBox(width: 18),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showResultDialog(String content) {
    final isUrl = content.startsWith('http://') || content.startsWith('https://');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DialogQrResultLayout(
        qrContent: content,
        isUrl: isUrl,
        onCopy: () {
          Clipboard.setData(ClipboardData(text: content));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã sao chép nội dung QR!')),
          );
        },
        onOpenLink: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => WebViewActivity(targetUrl: content)),
          );
        },
        onClose: () {
          Navigator.of(ctx).pop();
          _isHandling = false;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActivityQrScannerLayout(
      controller: _scannerController,
      isFlashOn: _isFlashOn,
      onBackClick: () => Navigator.of(context).pop(),
      onToggleFlash: _toggleFlash,
      onManualInputClick: _showManualInputDialog,
      onDetect: _onDetect,
    );
  }
}
