import 'package:flutter/material.dart';
import '../../drawable/drawables.dart';
import '../values/colors.dart';

class ActivityProfileLayout extends StatelessWidget {
  final String staffName;
  final String staffRole;
  final String email;
  final String hotelName;
  final String? hotelId;
  final VoidCallback onBackClick;
  final VoidCallback onEditNameClick;
  final VoidCallback onSelectRoleClick;
  final VoidCallback onLogoutClick;

  const ActivityProfileLayout({
    super.key,
    required this.staffName,
    required this.staffRole,
    required this.email,
    required this.hotelName,
    this.hotelId,
    required this.onBackClick,
    required this.onEditNameClick,
    required this.onSelectRoleClick,
    required this.onLogoutClick,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResColors.background,
      appBar: AppBar(
        backgroundColor: ResColors.brand,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: onBackClick,
        ),
        title: const Text(
          'Hồ Sơ Cá Nhân',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          children: [
            // Avatar & Name Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: ResColors.brand, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: ClipOval(
                      child: AppDrawables.appLogo(size: 60),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    staffName.isNotEmpty ? staffName : 'Nhân viên buồng phòng',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ResColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: ResColors.brandLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      staffRole.isNotEmpty ? staffRole : 'Nhân viên buồng phòng',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ResColors.brand,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Information Details Card (Xuống dòng thông tin cho từng mục)
            Container(
              decoration: AppDrawables.bgCard,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Họ và tên
                  _buildStackedInteractiveRow(
                    label: 'Họ và tên',
                    value: staffName.isNotEmpty ? staffName : 'Chưa thiết lập',
                    icon: AppDrawables.icEdit,
                    onTap: onEditNameClick,
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),

                  // 2. Bộ phận / Chức danh
                  _buildStackedInteractiveRow(
                    label: 'Bộ phận / Chức danh',
                    value: staffRole.isNotEmpty ? staffRole : 'Nhân viên buồng phòng',
                    icon: AppDrawables.icEdit,
                    onTap: onSelectRoleClick,
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),

                  // 3. Email tài khoản
                  _buildStackedStaticRow(
                    label: 'Email tài khoản',
                    value: email.isNotEmpty ? email : 'Chưa thiết lập',
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),

                  // 4. Khách sạn (Đã bỏ hoàn toàn Mã khách sạn ID)
                  _buildStackedStaticRow(
                    label: 'Khách sạn',
                    value: hotelName.isNotEmpty ? hotelName : 'VietSage Hotel',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section 2: Logout Button Card
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onLogoutClick,
                icon: const Icon(AppDrawables.icLogout, color: Color(0xFFDC2626), size: 20),
                label: const Text(
                  'ĐĂNG XUẤT TÀI KHOẢN',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE2E2),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFFECACA), width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Footer: Tách thành 2 dòng và căn lề giữa ở cuối màn hình
            const Center(
              child: Column(
                children: [
                  Text(
                    'VietSage Housekeeping',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: ResColors.textMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ứng dụng buồng phòng',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: ResColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Row có thể bấm chỉnh sửa: Label ở trên, Value ở dưới
  Widget _buildStackedInteractiveRow({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 13.5, color: ResColors.textMuted),
                ),
                const Spacer(),
                Icon(icon, size: 15, color: ResColors.brand),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: ResColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Row thông tin tĩnh: Label ở trên, Value ở dưới
  Widget _buildStackedStaticRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13.5, color: ResColors.textMuted),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ResColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
