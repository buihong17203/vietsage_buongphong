class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String hotelId;
  final String hotelName;
  final String staffName;
  final String staffRole;

  AuthResponse({
    this.accessToken = '',
    this.refreshToken = '',
    this.hotelId = '',
    this.hotelName = '',
    this.staffName = '',
    this.staffRole = '',
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: (json['accessToken'] ?? json['access_token'] ?? json['token'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? json['refresh_token'] ?? '').toString(),
      hotelId: (json['hotelId'] ?? '').toString(),
      hotelName: (json['hotelName'] ?? '').toString(),
      staffName: (json['staffName'] ?? json['name'] ?? '').toString(),
      staffRole: (json['staffRole'] ?? json['role'] ?? '').toString(),
    );
  }
}
