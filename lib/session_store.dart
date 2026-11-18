import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'res/values/strings.dart';

class SessionStore extends ChangeNotifier {
  static SessionStore? _instance;
  late SharedPreferences _prefs;
  bool _initialized = false;
  int _lastExpiredNoticeTime = 0;

  VoidCallback? onSessionExpired;

  SessionStore._();

  static SessionStore get instance {
    _instance ??= SessionStore._();
    return _instance!;
  }

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  static const String defaultHotelId = ResStrings.defaultHotelId;
  static const String defaultHotelName = ResStrings.defaultHotelName;
  static const String defaultBaseUrl = 'https://vietsage.com';

  String get baseUrl => _prefs.getString('base') ?? defaultBaseUrl;
  String get accessToken => _prefs.getString('access') ?? '';
  String get refreshToken => _prefs.getString('refresh') ?? '';
  String get email => _prefs.getString('email') ?? '';
  String get lastEmail => _prefs.getString('last_email') ?? 'housekeeping@vietsage.vn';
  String get password => _prefs.getString('password') ?? '';
  String get hotelId => _prefs.getString('hotelId') ?? defaultHotelId;
  String get hotelName => _prefs.getString('hotelName') ?? defaultHotelName;
  String get cookies => _prefs.getString('cookies') ?? '';

  bool get isLoggedIn => (_prefs.getBool('is_logged_in') ?? false) && email.isNotEmpty;
  bool get active => isLoggedIn;

  String get staffName {
    final name = _prefs.getString('staff_name') ?? '';
    if (name.isEmpty) {
      if (email.isNotEmpty) {
        final saved = _prefs.getString('map_user_staff_name_${email.toLowerCase()}');
        if (saved != null && saved.isNotEmpty) return saved;
      }
      return staffRole;
    }
    return name;
  }

  String get staffRole {
    final role = _prefs.getString('staff_role') ?? '';
    if (role.isEmpty) {
      final clean = email.toLowerCase();
      if (clean.contains('phucvu') || clean.contains('service')) {
        return ResStrings.defaultRoleService;
      }
      return ResStrings.defaultRoleHousekeeping;
    }
    return role;
  }

  String getHotelIdForUser(String email) {
    if (email.isEmpty) return defaultHotelId;
    return _prefs.getString('map_user_hotel_id_${email.toLowerCase().trim()}') ?? defaultHotelId;
  }

  String getHotelNameForUser(String email) {
    if (email.isEmpty) return defaultHotelName;
    return _prefs.getString('map_user_hotel_name_${email.toLowerCase().trim()}') ?? defaultHotelName;
  }

  Future<void> saveLogin({
    String? baseUrl,
    required String email,
    required String password,
    String? access,
    String? refresh,
    String? hotelId,
    String? hotelName,
    String? staffName,
    String? staffRole,
    String? cookies,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final fHotelId = (hotelId == null || hotelId.trim().isEmpty) ? defaultHotelId : hotelId.trim();
    final fHotelName = (hotelName == null || hotelName.trim().isEmpty) ? defaultHotelName : hotelName.trim();

    String detectedRole = (staffRole != null && staffRole.trim().isNotEmpty && staffRole != 'null')
        ? staffRole.trim()
        : (cleanEmail.contains('phucvu') || cleanEmail.contains('service')
            ? ResStrings.defaultRoleService
            : ResStrings.defaultRoleHousekeeping);

    String finalStaffName = (staffName != null && staffName.trim().isNotEmpty && staffName != 'null')
        ? staffName.trim()
        : (_prefs.getString('map_user_staff_name_$cleanEmail') ?? ResStrings.defaultRoleHousekeeping);

    await _prefs.setString('base', (baseUrl == null || baseUrl.isEmpty) ? defaultBaseUrl : baseUrl);
    await _prefs.setString('email', cleanEmail);
    await _prefs.setString('last_email', cleanEmail);
    await _prefs.setString('password', password);
    await _prefs.setString('access', access ?? '');
    await _prefs.setString('refresh', refresh ?? '');
    await _prefs.setString('hotelId', fHotelId);
    await _prefs.setString('hotelName', fHotelName);
    await _prefs.setString('staff_name', finalStaffName);
    await _prefs.setString('staff_role', detectedRole);
    if (cookies != null) {
      await _prefs.setString('cookies', cookies);
    }

    await _prefs.setString('map_user_hotel_id_$cleanEmail', fHotelId);
    await _prefs.setString('map_user_hotel_name_$cleanEmail', fHotelName);
    await _prefs.setString('map_user_staff_name_$cleanEmail', finalStaffName);
    await _prefs.setBool('is_logged_in', true);

    notifyListeners();
  }

  Future<void> updateTokens(String access, String refresh) async {
    if (access.isNotEmpty) await _prefs.setString('access', access.trim());
    if (refresh.isNotEmpty) await _prefs.setString('refresh', refresh.trim());
    notifyListeners();
  }

  Future<void> saveCookies(String cookies) async {
    await _prefs.setString('cookies', cookies);
    notifyListeners();
  }

  Future<void> setStaffName(String name) async {
    final trimmed = name.trim();
    await _prefs.setString('staff_name', trimmed);
    if (email.isNotEmpty && trimmed.isNotEmpty) {
      await _prefs.setString('map_user_staff_name_${email.toLowerCase()}', trimmed);
    }
    notifyListeners();
  }

  Future<void> setStaffRole(String role) async {
    final trimmed = role.trim().isEmpty ? ResStrings.defaultRoleHousekeeping : role.trim();
    await _prefs.setString('staff_role', trimmed);
    notifyListeners();
  }

  Future<void> setHotel(String hotelId, String hotelName) async {
    final fId = hotelId.trim().isEmpty ? defaultHotelId : hotelId.trim();
    final fName = hotelName.trim().isEmpty ? defaultHotelName : hotelName.trim();
    await _prefs.setString('hotelId', fId);
    await _prefs.setString('hotelName', fName);
    if (email.isNotEmpty) {
      await _prefs.setString('map_user_hotel_id_${email.toLowerCase()}', fId);
      await _prefs.setString('map_user_hotel_name_${email.toLowerCase()}', fName);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _prefs.setBool('is_logged_in', false);
    await _prefs.remove('email');
    await _prefs.remove('password');
    await _prefs.remove('access');
    await _prefs.remove('refresh');
    await _prefs.remove('cookies');
    await _prefs.remove('staff_name');
    await _prefs.remove('staff_role');
    notifyListeners();
  }

  void notifySessionExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastExpiredNoticeTime < 3000) {
      return;
    }
    _lastExpiredNoticeTime = now;
    logout();
    onSessionExpired?.call();
  }
}
