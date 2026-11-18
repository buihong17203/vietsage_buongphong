import '../error/api_error.dart';
import 'api_client.dart';
import 'model/auth_response.dart';
import 'model/login_request.dart';
import 'model/user_profile_model.dart';

class AuthApiHandler {
  final ApiClient client;

  AuthApiHandler(this.client);

  void login(
    LoginRequest request, {
    required void Function(AuthResponse response) onSuccess,
    required void Function(ApiError error) onError,
  }) {
    client.login(
      request.email,
      request.password,
      request.hotelId,
      (accessToken, refreshToken, hotelId, hotelName, staffName, staffRole, error) {
        if (error != null) {
          onError(error);
        } else {
          final resp = AuthResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
            hotelId: hotelId,
            hotelName: hotelName,
            staffName: staffName,
            staffRole: staffRole,
          );
          onSuccess(resp);
        }
      },
    );
  }

  void refreshToken({
    required void Function(String newAccessToken) onSuccess,
    required void Function(ApiError error) onError,
  }) {
    client.refreshToken((success, newAccessToken) {
      if (success && newAccessToken != null) {
        onSuccess(newAccessToken);
      } else {
        onError(ApiError(status: 401, message: 'Phiên làm việc đã hết hạn.'));
      }
    });
  }

  void logout(void Function(bool success, ApiError? error) callback) {
    client.logout(callback);
  }

  void fetchProfile({
    required void Function(UserProfileModel profile) onSuccess,
    required void Function(ApiError error) onError,
  }) {
    client.fetchUserProfile((staffName, staffRole, hotelId, hotelName, error) {
      if (error != null) {
        onError(error);
      } else {
        final profile = UserProfileModel(
          name: staffName,
          role: staffRole,
          hotelId: hotelId,
          hotelName: hotelName,
        );
        onSuccess(profile);
      }
    });
  }
}
