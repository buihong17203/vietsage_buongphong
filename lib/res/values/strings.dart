class ResStrings {
  ResStrings._();

  static const String appName = 'VietSage Buồng phòng';
  static const String defaultHotelName = 'VietSage Hotel';
  static const String defaultHotelId = 'cmsr8ftxx013h01qp1sjkp8s8';
  static const String defaultRoleHousekeeping = 'Nhân viên buồng phòng';
  static const String defaultRoleService = 'Nhân viên phục vụ';

  // Login strings
  static const String loginTitle = 'Đăng Nhập';
  static const String emailHint = 'Email / Tài khoản';
  static const String passwordHint = 'Mật khẩu';
  static const String loginBtn = 'ĐĂNG NHẬP';
  static const String loggingInBtn = 'Đang xác thực...';
  static const String emailRequired = 'Vui lòng nhập email / tài khoản';
  static const String passwordRequired = 'Vui lòng nhập mật khẩu';
  static const String loginSuccess = 'Đăng nhập thành công!';
  static const String loginFailed = 'Đăng nhập thất bại. Vui lòng kiểm tra lại tài khoản hoặc mật khẩu.';

  // Home strings
  static const String roomsToClean = 'Phòng Cần Dọn';
  static const String swipeHint = 'Vuốt để cập nhật';
  static const String scanQr = 'Quét QR';
  static const String allRoomsClean = 'Tất Cả Phòng Đã Sạch Sẽ!';
  static const String allRoomsCleanSub = 'Hiện tại không có phòng nào cần dọn dẹp.\nKhi có khách trả phòng, chuông thông báo sẽ tự động nổi lên.';
  static const String tapToClaimHint = 'Xem chi tiết ›';
  static const String viewDetail = 'Xem chi tiết';

  // Task detail strings - Không có ký tự '<' thừa vì nút đã có icon mũi tên
  static const String backToList = 'Quay lại danh sách';
  static const String startClean = 'Bắt đầu dọn phòng';
  static const String completeClean = 'Đã dọn xong';
  static const String recleanBtn = 'Báo phòng cần dọn dẹp lại';
  static const String cleanDoneTitle = 'Dọn phòng thành công';
  static const String cleanDoneMsg = 'Đã hoàn tất dọn phòng!';
  static const String close = 'Đóng';

  /// Trạng thái chuẩn hóa chỉ hiển thị: 'Cần dọn', 'Đang dọn', 'Đã dọn'
  static String label(String s) {
    final upper = s.toUpperCase();
    if (upper == 'IN_PROGRESS' || upper == 'CLAIMED' || upper == 'CLEANING') {
      return 'Đang dọn';
    }
    if (upper == 'AVAILABLE' || upper == 'COMPLETED' || upper == 'CLEAN') {
      return 'Đã dọn';
    }
    return 'Cần dọn';
  }
}
