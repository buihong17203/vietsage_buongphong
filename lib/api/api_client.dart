import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../error/api_error.dart';
import '../error/api_exception.dart';
import '../error/error_handler.dart';
import '../session_store.dart';
import 'api_config.dart';

typedef ApiCallback = void Function(Map<String, dynamic>? data, ApiError? error);
typedef LoginCallback = void Function(
  String accessToken,
  String refreshToken,
  String hotelId,
  String hotelName,
  String staffName,
  String staffRole,
  ApiError? error,
);
typedef ProfileCallback = void Function(
  String staffName,
  String staffRole,
  String hotelId,
  String hotelName,
  ApiError? error,
);
typedef RefreshCallback = void Function(bool success, String? newAccessToken);

class ApiClient {
  final String baseUrl;
  String _token;
  final String? _email;
  final String? _password;
  SessionStore? _sessionStore;

  static bool _isRefreshing = false;
  static final List<Completer<bool>> _refreshWaiters = [];

  // Cookie store
  final Map<String, String> _cookies = {};

  ApiClient({
    String? baseUrl,
    String? token,
    String? email,
    String? password,
    SessionStore? sessionStore,
  })  : baseUrl = ApiConfig.normalizeBaseUrl(baseUrl ?? sessionStore?.baseUrl),
        _token = token ?? (sessionStore?.accessToken ?? ''),
        _email = email ?? sessionStore?.email,
        _password = password ?? sessionStore?.password,
        _sessionStore = sessionStore {
    _loadCookiesFromSession();
  }

  void _loadCookiesFromSession() {
    final raw = _sessionStore?.cookies ?? '';
    if (raw.isNotEmpty) {
      final pairs = raw.split(';');
      for (final p in pairs) {
        final kv = p.trim().split('=');
        if (kv.length >= 2) {
          _cookies[kv[0].trim()] = kv.sublist(1).join('=').trim();
        }
      }
    }
  }

  String get cookiesString {
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  void setSessionStore(SessionStore sessionStore) {
    _sessionStore = sessionStore;
    if (_token.isEmpty) {
      _token = sessionStore.accessToken;
    }
    _loadCookiesFromSession();
  }

  String resolvePath(String path) {
    if (baseUrl.contains('vietsage.com')) {
      if (path.startsWith('/hotels/')) {
        return '/api/hotel-ops$path';
      }
    }
    return path;
  }

  Map<String, String> _buildHeaders({String? overrideToken, String? contentType}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Accept-Language': 'vi',
      'User-Agent': 'VietSageHousekeeping/1.0 (Android-Flutter)',
    };
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    final t = overrideToken ?? _token;
    if (t.isNotEmpty && !t.startsWith('cookie-')) {
      headers['Authorization'] = 'Bearer $t';
    }
    if (_cookies.isNotEmpty) {
      headers['Cookie'] = cookiesString;
    }
    return headers;
  }

  void _extractCookiesFromHeaders(HttpHeaders headers) {
    final setCookies = headers[HttpHeaders.setCookieHeader];
    if (setCookies != null && setCookies.isNotEmpty) {
      for (final raw in setCookies) {
        final parts = raw.split(';')[0].trim().split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final val = parts.sublist(1).join('=').trim();
          _cookies[key] = val;
        }
      }
      _sessionStore?.saveCookies(cookiesString);
    }
  }

  static String mapRoleCodeToVietnamese(String? code) {
    if (code == null || code.trim().isEmpty || code == 'null') {
      return 'Nhân viên buồng phòng';
    }
    final upper = code.trim().toUpperCase();
    if (upper.contains('HOUSEKEEPING') || upper.contains('BUONG_PHONG') || upper.contains('BUONGPHONG')) {
      return 'Nhân viên buồng phòng';
    }
    if (upper.contains('SERVICE') || upper.contains('PHUC_VU') || upper.contains('PHUCVU') || upper.contains('WAITER') || upper.contains('STAFF')) {
      return 'Nhân viên phục vụ';
    }
    if (upper.contains('RECEPTION') || upper.contains('LE_TAN') || upper.contains('LETAN')) {
      return 'Nhân viên lễ tân';
    }
    return 'Nhân viên buồng phòng';
  }

  Future<void> request(
    String method,
    String path,
    dynamic body,
    ApiCallback callback,
  ) async {
    try {
      final data = await _executeWithRetry(method, path, body);
      callback(data, null);
    } catch (e) {
      final error = ErrorHandler.fromThrowable(e);
      callback(null, error);
    }
  }

  Future<Map<String, dynamic>> _executeWithRetry(
    String method,
    String path,
    dynamic body, {
    bool hasRetried = false,
  }) async {
    try {
      return await _rawRequest(method, path, body);
    } on ApiException catch (e) {
      if (e.status == 401 && !hasRetried && _sessionStore != null && _sessionStore!.isLoggedIn) {
        final refreshed = await refreshTokenFuture();
        if (refreshed) {
          _token = _sessionStore!.accessToken;
          return await _rawRequest(method, path, body);
        } else {
          _sessionStore?.notifySessionExpired();
          throw ApiException(401, 'Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.');
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _rawRequest(
    String method,
    String path,
    dynamic body, {
    String? overrideToken,
  }) async {
    final fullUrl = '$baseUrl${resolvePath(path)}';
    final uri = Uri.parse(fullUrl);

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);

    try {
      final reqMethod = method.toUpperCase();
      HttpClientRequest req;
      if (reqMethod == 'GET') {
        req = await client.getUrl(uri);
      } else if (reqMethod == 'POST') {
        req = await client.postUrl(uri);
      } else if (reqMethod == 'PATCH') {
        req = await client.patchUrl(uri);
      } else if (reqMethod == 'PUT') {
        req = await client.putUrl(uri);
      } else if (reqMethod == 'DELETE') {
        req = await client.deleteUrl(uri);
      } else {
        throw ApiException(400, 'Phương thức HTTP không hỗ trợ: $method');
      }

      final headers = _buildHeaders(
        overrideToken: overrideToken,
        contentType: body != null ? 'application/json; charset=utf-8' : null,
      );

      headers.forEach((k, v) {
        req.headers.set(k, v);
      });

      if (body != null) {
        final jsonStr = jsonEncode(body);
        req.add(utf8.encode(jsonStr));
      }

      final resp = await req.close().timeout(const Duration(seconds: 20));
      _extractCookiesFromHeaders(resp.headers);

      final statusCode = resp.statusCode;
      final responseBody = await resp.transform(utf8.decoder).join();
      final trimmed = responseBody.trim();

      dynamic parsed;
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          parsed = jsonDecode(trimmed);
        } catch (_) {
          parsed = <String, dynamic>{};
        }
      } else {
        if (statusCode >= 200 && statusCode < 300) {
          parsed = <String, dynamic>{};
        } else {
          throw ApiException(statusCode, 'Máy chủ phản hồi ($statusCode)');
        }
      }

      if (statusCode < 200 || statusCode >= 300) {
        String msg = 'Yêu cầu thất bại ($statusCode)';
        if (parsed is Map) {
          final data = parsed['data'];
          if (data is Map && data['detail'] != null) {
            msg = data['detail'].toString();
          } else if (parsed['message'] != null) {
            msg = parsed['message'].toString();
          } else if (parsed['error'] != null) {
            msg = parsed['error'].toString();
          }
        }
        throw ApiException(statusCode, msg);
      }

      if (parsed is Map<String, dynamic>) {
        if (parsed['data'] is Map<String, dynamic>) {
          return parsed['data'] as Map<String, dynamic>;
        }
        if (parsed['data'] is List) {
          return {'items': parsed['data']};
        }
        return parsed;
      }
      if (parsed is List) {
        return {'items': parsed};
      }
      return <String, dynamic>{};
    } finally {
      client.close();
    }
  }

  Future<void> login(
    String targetEmail,
    String targetPassword,
    String? preferredHotelId,
    LoginCallback callback,
  ) async {
    final cleanEmail = targetEmail.trim().toLowerCase();
    final cleanPassword = targetPassword.trim();
    final defaultHotelId = (preferredHotelId != null && preferredHotelId.trim().isNotEmpty)
        ? preferredHotelId.trim()
        : SessionStore.defaultHotelId;

    // --- Strategy 1: Direct NestJS Core Auth (POST /auth/login) ---
    try {
      final directUri = Uri.parse('$baseUrl/auth/login');
      final directClient = HttpClient();
      directClient.connectionTimeout = const Duration(seconds: 15);

      final req = await directClient.postUrl(directUri);
      req.headers.set('Content-Type', 'application/json');
      req.headers.set('Accept', 'application/json');
      req.headers.set('User-Agent', 'VietSageHousekeeping/1.0 (Android-Flutter)');
      req.add(utf8.encode(jsonEncode({
        'email': cleanEmail,
        'password': cleanPassword,
      })));

      final resp = await req.close().timeout(const Duration(seconds: 20));
      _extractCookiesFromHeaders(resp.headers);
      final statusCode = resp.statusCode;
      final bodyStr = await resp.transform(utf8.decoder).join();
      directClient.close();

      if (statusCode >= 200 && statusCode < 300) {
        final json = jsonDecode(bodyStr);
        final data = json['data'] ?? json;
        if (data is Map && data['accessToken'] != null) {
          final accessToken = data['accessToken'].toString();
          final refreshToken = (data['refreshToken'] ?? '').toString();
          _token = accessToken;

          String finalHotelId = defaultHotelId;
          String finalHotelName = SessionStore.defaultHotelName;
          String staffName = '';
          String staffRole = 'Nhân viên buồng phòng';

          // Call GET /auth/me with Bearer token
          try {
            final meObj = await _rawRequest('GET', '/auth/me', null, overrideToken: accessToken);
            staffName = (meObj['fullName'] ?? meObj['name'] ?? meObj['username'] ?? '').toString();

            if (meObj['activeRole'] is Map) {
              final activeRole = meObj['activeRole'] as Map;
              final code = (activeRole['code'] ?? activeRole['baseRoleCode'] ?? '').toString();
              staffRole = (activeRole['name'] != null && activeRole['name'].toString().isNotEmpty)
                  ? activeRole['name'].toString()
                  : mapRoleCodeToVietnamese(code);
            }

            final accessibleHotels = meObj['accessibleHotels'];
            if (accessibleHotels is List && accessibleHotels.isNotEmpty) {
              bool matched = false;
              for (final h in accessibleHotels) {
                if (h is Map && h['id'] == defaultHotelId) {
                  finalHotelName = (h['name'] ?? finalHotelName).toString();
                  matched = true;
                  break;
                }
              }
              if (!matched) {
                final first = accessibleHotels.first as Map;
                finalHotelId = (first['id'] ?? finalHotelId).toString();
                finalHotelName = (first['name'] ?? finalHotelName).toString();
              }
            }
          } catch (_) {}

          callback(accessToken, refreshToken, finalHotelId, finalHotelName, staffName, staffRole, null);
          return;
        }
      } else if (statusCode == 400 || statusCode == 401) {
        String errMsg = 'Sai email hoặc mật khẩu đăng nhập';
        try {
          final errJson = jsonDecode(bodyStr);
          if (errJson['message'] != null) errMsg = errJson['message'].toString();
        } catch (_) {}
        callback('', '', '', '', '', '', ApiError(status: statusCode, message: errMsg));
        return;
      }
    } catch (_) {
      // Direct login failed or not available, fallback to Strategy 2 (NextAuth)
    }

    // --- Strategy 2: NextAuth Credentials Flow ---
    try {
      String csrfToken = '';
      try {
        final csrfResp = await _rawRequest('GET', '/api/auth/csrf', null);
        csrfToken = csrfResp['csrfToken']?.toString() ?? '';
      } catch (_) {}

      if (csrfToken.isEmpty) {
        callback('', '', '', '', '', '', ApiError(status: 400, message: 'Không lấy được mã xác thực CSRF từ máy chủ'));
        return;
      }

      final formFields = [
        'email=${Uri.encodeComponent(cleanEmail)}',
        'password=${Uri.encodeComponent(cleanPassword)}',
        'csrfToken=${Uri.encodeComponent(csrfToken)}',
        'callbackUrl=${Uri.encodeComponent('$baseUrl/hotels/housekeeping')}',
        'json=true',
      ].join('&');

      final authClient = HttpClient();
      authClient.connectionTimeout = const Duration(seconds: 15);

      final req = await authClient.postUrl(Uri.parse('$baseUrl/api/auth/callback/credentials'));
      req.followRedirects = false; // CRUCIAL: Do not automatically follow redirects to catch 302 errors!
      req.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      req.headers.set('Accept', 'application/json');
      req.headers.set('User-Agent', 'VietSageHousekeeping/1.0 (Android-Flutter)');
      if (_cookies.isNotEmpty) {
        req.headers.set('Cookie', cookiesString);
      }
      req.add(utf8.encode(formFields));

      final resp = await req.close().timeout(const Duration(seconds: 25));
      _extractCookiesFromHeaders(resp.headers);

      final statusCode = resp.statusCode;
      final bodyStr = await resp.transform(utf8.decoder).join();
      final location = resp.headers.value(HttpHeaders.locationHeader) ?? '';
      authClient.close();

      // Check for authentication failure redirects
      if (bodyStr.contains('error=') ||
          bodyStr.contains('CredentialsSignin') ||
          location.contains('error=') ||
          location.contains('CredentialsSignin')) {
        callback('', '', '', '', '', '', ApiError(status: 401, message: 'Sai email hoặc mật khẩu đăng nhập'));
        return;
      }

      if (statusCode != 200 && statusCode != 302) {
        callback('', '', '', '', '', '', ApiError(status: statusCode, message: 'Đăng nhập thất bại (Mã $statusCode)'));
        return;
      }

      // Check session validity
      try {
        final sessionResp = await _rawRequest('GET', '/api/auth/session', null);
        final user = sessionResp['user'] ?? sessionResp;

        if (user is! Map || user.isEmpty) {
          callback('', '', '', '', '', '', ApiError(status: 401, message: 'Sai email hoặc mật khẩu đăng nhập'));
          return;
        }

        String staffName = (user['name'] ?? user['fullName'] ?? '').toString();
        String staffRole = mapRoleCodeToVietnamese(sessionResp['activeRoleCode']?.toString() ?? user['role']?.toString());
        String finalHotelId = (user['hotelId'] ?? defaultHotelId).toString();
        String finalHotelName = (user['hotelName'] ?? SessionStore.defaultHotelName).toString();

        _token = 'cookie-session-${DateTime.now().millisecondsSinceEpoch}';
        callback(_token, '', finalHotelId, finalHotelName, staffName, staffRole, null);
      } catch (e) {
        callback('', '', '', '', '', '', ApiError(status: 401, message: 'Không thể xác thực phiên đăng nhập'));
      }
    } catch (e) {
      callback('', '', '', '', '', '', ErrorHandler.fromThrowable(e));
    }
  }

  Future<bool> refreshTokenFuture() async {
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _refreshWaiters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    bool success = false;
    try {
      final rToken = _sessionStore?.refreshToken ?? '';
      if (rToken.isNotEmpty) {
        // Strategy 1: Direct NestJS auth endpoint (POST /auth/refresh) như VietSageHousekeeping gốc
        try {
          final res = await _rawRequest('POST', '/auth/refresh', {'refreshToken': rToken});
          final newToken = (res['accessToken'] ?? res['token'])?.toString() ?? '';
          if (newToken.isNotEmpty) {
            _token = newToken;
            final newRefresh = (res['refreshToken'] ?? rToken).toString();
            await _sessionStore?.updateTokens(newToken, newRefresh);
            success = true;
          }
        } catch (_) {}

        // Strategy 2: Fallback to Next.js ops endpoint (POST /api/auth/token/refresh)
        if (!success) {
          try {
            final res = await _rawRequest('POST', '/api/auth/token/refresh', {'refreshToken': rToken});
            final newToken = (res['accessToken'] ?? res['token'])?.toString() ?? '';
            if (newToken.isNotEmpty) {
              _token = newToken;
              final newRefresh = (res['refreshToken'] ?? rToken).toString();
              await _sessionStore?.updateTokens(newToken, newRefresh);
              success = true;
            }
          } catch (_) {}
        }
      }

      if (!success && _email != null && _password != null && _email.isNotEmpty) {
        final completer = Completer<bool>();
        login(_email, _password, _sessionStore?.hotelId, (acc, ref, hId, hName, sName, sRole, err) {
          if (err == null && acc.isNotEmpty) {
            _sessionStore?.updateTokens(acc, ref);
            completer.complete(true);
          } else {
            completer.complete(false);
          }
        });
        success = await completer.future;
      }
    } catch (_) {
      success = false;
    } finally {
      _isRefreshing = false;
      for (final waiter in _refreshWaiters) {
        waiter.complete(success);
      }
      _refreshWaiters.clear();
    }
    return success;
  }

  void refreshToken(RefreshCallback callback) {
    refreshTokenFuture().then((ok) => callback(ok, _token));
  }

  Future<void> fetchUserProfile(ProfileCallback callback) async {
    try {
      // Try /auth/me first if Bearer token is present
      if (_token.isNotEmpty && !_token.startsWith('cookie-')) {
        try {
          final meData = await _rawRequest('GET', '/auth/me', null);
          final staffName = (meData['fullName'] ?? meData['name'] ?? '').toString();
          String staffRole = 'Nhân viên buồng phòng';

          if (meData['activeRole'] is Map) {
            final activeRole = meData['activeRole'] as Map;
            staffRole = (activeRole['name'] != null && activeRole['name'].toString().isNotEmpty)
                ? activeRole['name'].toString()
                : mapRoleCodeToVietnamese(activeRole['code']?.toString());
          }

          String hotelId = _sessionStore?.hotelId ?? SessionStore.defaultHotelId;
          String hotelName = _sessionStore?.hotelName ?? SessionStore.defaultHotelName;

          final hotels = meData['accessibleHotels'];
          if (hotels is List && hotels.isNotEmpty) {
            for (final h in hotels) {
              if (h is Map && h['id'] == hotelId) {
                hotelName = (h['name'] ?? hotelName).toString();
                break;
              }
            }
          }

          callback(staffName, staffRole, hotelId, hotelName, null);
          return;
        } catch (_) {}
      }

      // NextAuth /api/auth/session fallback
      final sessionResp = await _rawRequest('GET', '/api/auth/session', null);
      String name = '';
      String role = 'Nhân viên buồng phòng';
      String hotelId = _sessionStore?.hotelId ?? SessionStore.defaultHotelId;
      String hotelName = _sessionStore?.hotelName ?? SessionStore.defaultHotelName;

      final user = sessionResp['user'] ?? sessionResp;
      if (user is Map) {
        name = (user['name'] ?? user['fullName'] ?? '').toString();
        role = mapRoleCodeToVietnamese(sessionResp['activeRoleCode']?.toString() ?? user['role']?.toString());
        if (user['hotelId'] != null) hotelId = user['hotelId'].toString();
        if (user['hotelName'] != null) hotelName = user['hotelName'].toString();
      }
      callback(name, role, hotelId, hotelName, null);
    } catch (e) {
      callback('', '', '', '', ErrorHandler.fromThrowable(e));
    }
  }

  Future<void> logout(void Function(bool success, ApiError? error) callback) async {
    try {
      await _rawRequest('POST', '/api/auth/signout', null);
      _cookies.clear();
      _token = '';
      callback(true, null);
    } catch (e) {
      _cookies.clear();
      _token = '';
      callback(true, null);
    }
  }
}
