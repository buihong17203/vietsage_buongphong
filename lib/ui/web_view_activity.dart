import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../api/api_client.dart';
import '../api/api_manager.dart';
import '../api/model/room_model.dart';
import '../res/layout/activity_web_view_layout.dart';
import '../session_store.dart';
import 'task_detail_activity.dart';

class WebViewActivity extends StatefulWidget {
  final String targetUrl;

  const WebViewActivity({super.key, required this.targetUrl});

  @override
  State<WebViewActivity> createState() => _WebViewActivityState();
}

class _WebViewActivityState extends State<WebViewActivity> {
  late final WebViewController _controller;
  String _title = 'Đang tải...';
  String _subtitle = '';
  int _progress = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String? _roomBannerText;
  RoomModel? _detectedRoom;

  late final SessionStore _session;
  late final ApiClient _api;

  @override
  void initState() {
    super.initState();
    _session = SessionStore.instance;
    _api = ApiManager.getInstance(_session).client;

    _subtitle = Uri.tryParse(widget.targetUrl)?.host ?? widget.targetUrl;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() => _progress = progress);
          },
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
              _subtitle = Uri.tryParse(url)?.host ?? url;
            });
            _checkIfRoomUrl(url);
          },
          onPageFinished: (url) async {
            final pageTitle = await _controller.getTitle() ?? 'Trang web';
            setState(() {
              _isLoading = false;
              _title = pageTitle.isNotEmpty ? pageTitle : 'Trang web';
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.targetUrl));

    _checkIfRoomUrl(widget.targetUrl);
  }

  void _checkIfRoomUrl(String url) {
    if (url.contains('/g/') || url.contains('/rooms/')) {
      _api.request('GET', '/hotels/housekeeping/rooms/by-qr/${Uri.encodeComponent(url)}', null, (data, error) {
        if (!mounted) return;
        if (error == null && data != null && data['roomNumber'] != null) {
          final room = RoomModel.fromJson(data);
          setState(() {
            _detectedRoom = room;
            _roomBannerText = 'Phòng ${room.roomNumber} - Cần dọn dẹp';
          });
        }
      });
    }
  }

  void _openExternalBrowser() async {
    final currentUrl = await _controller.currentUrl() ?? widget.targetUrl;
    final uri = Uri.tryParse(currentUrl);
    if (uri != null) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onRoomBannerAction() {
    if (_detectedRoom != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TaskDetailActivity(room: _detectedRoom!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActivityWebViewLayout(
      controller: _controller,
      title: _title,
      subtitle: _subtitle,
      progress: _progress,
      isLoading: _isLoading,
      hasError: _hasError,
      roomBannerText: _roomBannerText,
      onBackClick: () => Navigator.of(context).pop(),
      onRefreshClick: () => _controller.reload(),
      onOpenExternalClick: _openExternalBrowser,
      onRetryClick: () {
        setState(() => _hasError = false);
        _controller.reload();
      },
      onRoomBannerActionClick: _onRoomBannerAction,
    );
  }
}
