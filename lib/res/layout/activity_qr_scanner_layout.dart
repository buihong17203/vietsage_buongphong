import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../drawable/drawables.dart';

class ActivityQrScannerLayout extends StatelessWidget {
  final MobileScannerController controller;
  final bool isFlashOn;
  final VoidCallback onBackClick;
  final VoidCallback onToggleFlash;
  final VoidCallback onManualInputClick;
  final void Function(BarcodeCapture capture) onDetect;

  const ActivityQrScannerLayout({
    super.key,
    required this.controller,
    required this.isFlashOn,
    required this.onBackClick,
    required this.onToggleFlash,
    required this.onManualInputClick,
    required this.onDetect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            controller: controller,
            onDetect: onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off_rounded, color: Colors.white70, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'Không thể khởi động camera.\nVui lòng cấp quyền camera trong Cài đặt.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: onManualInputClick,
                        child: const Text('Nhập mã thủ công'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Viewfinder Target Border in Center
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2.5),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Top Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.black45,
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: onBackClick,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      label: const Text('Đóng', style: TextStyle(color: Colors.white)),
                    ),
                    const Expanded(
                      child: Text(
                        'Quét mã QR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFlashOn ? AppDrawables.icFlashOff : AppDrawables.icFlash,
                        color: Colors.white,
                      ),
                      tooltip: isFlashOn ? 'Tắt Flash' : 'Bật Flash',
                      onPressed: onToggleFlash,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Bar Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                color: Colors.black54,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Hướng camera về phía mã QR để quét',
                      style: TextStyle(color: Colors.white70, fontSize: 13.5),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onManualInputClick,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Dán hoặc nhập link QR thủ công'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
