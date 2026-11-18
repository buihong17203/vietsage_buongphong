class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String roleCode;
  final String hotelId;
  final String hotelName;

  const UserProfileModel({
    this.id = '',
    this.name = '',
    this.email = '',
    this.role = 'Nhân viên buồng phòng',
    this.roleCode = '',
    this.hotelId = '',
    this.hotelName = '',
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    String detectedRole = 'Nhân viên buồng phòng';
    String code = '';

    if (json['activeRole'] is Map) {
      final roleObj = json['activeRole'] as Map<String, dynamic>;
      code = (roleObj['code'] ?? roleObj['baseRoleCode'] ?? '').toString();
      detectedRole = (roleObj['name'] ?? 'Nhân viên buồng phòng').toString();
    } else if (json['role'] != null) {
      detectedRole = json['role'].toString();
    }

    return UserProfileModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? json['fullName'] ?? json['username'] ?? '').toString(),
      role: detectedRole,
      roleCode: code,
      hotelId: (json['hotelId'] ?? '').toString(),
      hotelName: (json['hotelName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'roleCode': roleCode,
      'hotelId': hotelId,
      'hotelName': hotelName,
    };
  }
}
