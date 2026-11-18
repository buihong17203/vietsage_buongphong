import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/api_manager.dart';
import '../res/layout/activity_login_layout.dart';
import '../res/values/strings.dart';
import '../session_store.dart';
import 'home_activity.dart';

class LoginActivity extends StatefulWidget {
  const LoginActivity({super.key});

  @override
  State<LoginActivity> createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  late final SessionStore _session;
  late final ApiClient _api;

  @override
  void initState() {
    super.initState();
    _session = SessionStore.instance;
    _api = ApiManager.getInstance(_session).client;

    if (_session.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goToHome());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _attemptLogin() {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = ResStrings.emailRequired);
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorMessage = ResStrings.passwordRequired);
      return;
    }

    String preferredHotelId = _session.getHotelIdForUser(email);
    if (preferredHotelId.isEmpty) {
      preferredHotelId = SessionStore.defaultHotelId;
    }

    setState(() => _isLoading = true);

    _api.login(
      email,
      password,
      preferredHotelId,
      (access, refresh, hotelId, hotelName, staffName, staffRole, error) async {
        if (!mounted) return;
        setState(() => _isLoading = false);

        if (error != null) {
          final msg = error.message;
          if (msg.contains('Unable to resolve host') || msg.contains('No address associated') || error.errorType == 'DNS_NETWORK_ERROR') {
            setState(() {
              _errorMessage = '⚠️ Không thể kết nối tới máy chủ vietsage.com do lỗi mạng/DNS trên máy.\n\nKhắc phục: Kiểm tra lại mạng Wifi/4G hoặc DNS riêng tư.';
            });
          } else {
            setState(() {
              _errorMessage = msg.isNotEmpty ? msg : ResStrings.loginFailed;
            });
          }
          return;
        }

        final finalHotelId = (hotelId.isNotEmpty) ? hotelId : preferredHotelId;
        await _session.saveLogin(
          baseUrl: 'https://vietsage.com',
          email: email,
          password: password,
          access: access,
          refresh: refresh,
          hotelId: finalHotelId,
          hotelName: hotelName,
          staffName: staffName,
          staffRole: staffRole,
          cookies: _api.cookiesString,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(ResStrings.loginSuccess),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _goToHome();
        }
      },
    );
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeActivity()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActivityLoginLayout(
      emailController: _emailController,
      passwordController: _passwordController,
      isPasswordVisible: _isPasswordVisible,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      onTogglePasswordVisibility: () {
        setState(() => _isPasswordVisible = !_isPasswordVisible);
      },
      onLoginPressed: _attemptLogin,
    );
  }
}
