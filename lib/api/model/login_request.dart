class LoginRequest {
  final String email;
  final String password;
  final String hotelId;

  LoginRequest({
    required this.email,
    required this.password,
    this.hotelId = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim().toLowerCase(),
      'password': password.trim(),
      if (hotelId.isNotEmpty) 'hotelId': hotelId.trim(),
    };
  }
}
