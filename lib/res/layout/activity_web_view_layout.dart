import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../values/colors.dart';

class ActivityWebViewLayout extends StatelessWidget {
  final WebViewController controller;
  final String title;
  final String subtitle;
  final int progress;
  final bool isLoading;
  final bool hasError;
  final String? roomBannerText;
  final VoidCallback onBackClick;
  final VoidCallback onRefreshClick;
  final VoidCallback onOpenExternalClick;
  final VoidCallback onRetryClick;
  final VoidCallback? onRoomBannerActionClick;

  const ActivityWebViewLayout({
    super.key,
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.isLoading,
    required this.hasError,
    this.roomBannerText,
    required this.onBackClick,
    required this.onRefreshClick,
    required this.onOpenExternalClick,
    required this.onRetryClick,
    this.onRoomBannerActionClick,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ResColors.brand,
        elevation: 2,
        leadingWidth: 80,
        leading: TextButton.icon(
          onPressed: onBackClick,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
          label: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: ResColors.textDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11.5, color: ResColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: ResColors.brand),
            tooltip: 'Tải lại',
            onPressed: onRefreshClick,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded, color: ResColors.brand),
            tooltip: 'Mở trình duyệt ngoài',
            onPressed: onOpenExternalClick,
          ),
        ],
        bottom: isLoading && progress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: progress / 100.0,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(ResColors.brand),
                  minHeight: 2,
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          // WebView
          WebViewWidget(controller: controller),

          // Room Banner shortcut if URL is a hotel room
          if (roomBannerText != null && roomBannerText!.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFFFEF3C7),
                child: Row(
                  children: [
                    const Icon(Icons.room_service_rounded, color: Color(0xFFB45309), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        roomBannerText!,
                        style: const TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onRoomBannerActionClick,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ResColors.brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text('Vào dọn phòng', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

          // Error Container if failed to load
          if (hasError)
            Container(
              color: ResColors.surface,
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Không thể tải trang web',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ResColors.textDark),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Vui lòng kiểm tra lại kết nối mạng và thử lại.',
                    style: TextStyle(fontSize: 13.5, color: ResColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onRetryClick,
                    style: ElevatedButton.styleFrom(backgroundColor: ResColors.brand),
                    child: const Text('Tải lại'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
