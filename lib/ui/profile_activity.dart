import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/api_manager.dart';
import '../res/layout/activity_profile_layout.dart';
import '../res/values/strings.dart';
import '../session_store.dart';
import 'login_activity.dart';

class ProfileActivity extends StatefulWidget {
  const ProfileActivity({super.key});

  @override
  State<ProfileActivity> createState() => _ProfileActivityState();
}

class _ProfileActivityState extends State<ProfileActivity> {
  late final SessionStore _session;
  late final ApiClient _api;

  @override
  void initState() {
    super.initState();
    _session = SessionStore.instance;
    _api = ApiManager.getInstance(_session).client;

    _fetchProfile();
  }

  void _fetchProfile() {
    _api.fetchUserProfile((name, role, hotelId, hotelName, error) {
      if (error == null && mounted) {
        if (name.isNotEmpty && name != 'null') _session.setStaffName(name);
        if (role.isNotEmpty && role != 'null') _session.setStaffRole(role);
        if (hotelName.isNotEmpty) _session.setHotel(_session.hotelId, hotelName);
        setState(() {});
      }
    });
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _session.staffName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi tên hiển thị'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ví dụ: Nguyễn Văn Tuấn',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                _session.setStaffName(newName);
                setState(() {});
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showRoleSelectionDialog() {
    final roles = [
      ResStrings.defaultRoleHousekeeping,
      ResStrings.defaultRoleService,
      'Trưởng ca / Giám sát',
    ];

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Chọn bộ phận / chức danh'),
        children: roles.map((role) {
          final isSelected = _session.staffRole == role;
          return SimpleDialogOption(
            onPressed: () {
              _session.setStaffRole(role);
              setState(() {});
              Navigator.of(ctx).pop();
            },
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF0F766E) : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _session.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginActivity()),
                  (route) => false,
                );
              }
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActivityProfileLayout(
      staffName: _session.staffName,
      staffRole: _session.staffRole,
      email: _session.email,
      hotelName: _session.hotelName,
      onBackClick: () => Navigator.of(context).pop(),
      onEditNameClick: _showEditNameDialog,
      onSelectRoleClick: _showRoleSelectionDialog,
      onLogoutClick: _confirmLogout,
    );
  }
}
