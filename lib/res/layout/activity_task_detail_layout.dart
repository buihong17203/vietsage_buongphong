import 'package:flutter/material.dart';
import '../../api/model/room_model.dart';
import '../../drawable/drawables.dart';
import '../values/colors.dart';
import '../values/strings.dart';

class ActivityTaskDetailLayout extends StatelessWidget {
  final RoomModel room;
  final bool isBusy;
  final String? errorMessage;
  final VoidCallback onBackClick;
  final VoidCallback onStartCleanClick;
  final VoidCallback onCompleteClick;
  final VoidCallback onRecleanClick;

  const ActivityTaskDetailLayout({
    super.key,
    required this.room,
    required this.isBusy,
    this.errorMessage,
    required this.onBackClick,
    required this.onStartCleanClick,
    required this.onCompleteClick,
    required this.onRecleanClick,
  });

  @override
  Widget build(BuildContext context) {
    // Trạng thái chỉ nhận: 'Cần dọn', 'Đang dọn', 'Đã dọn'
    final labelStatus = ResStrings.label(room.status);

    Color statusColor = ResColors.urgent;
    if (labelStatus == 'Đang dọn') {
      statusColor = const Color(0xFFD97706);
    } else if (labelStatus == 'Đã dọn') {
      statusColor = const Color(0xFF16A34A);
    }

    final isNeedClean = labelStatus == 'Cần dọn';
    final isCleaning = labelStatus == 'Đang dọn';
    final isCleaned = labelStatus == 'Đã dọn';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nút Quay lại danh sách: Được đặt trong 1 tag/pill có màu nền riêng biệt nổi bật
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          elevation: 1,
                          shadowColor: Colors.black12,
                          child: InkWell(
                            onTap: onBackClick,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: ResColors.brand),
                                  SizedBox(width: 6),
                                  Text(
                                    ResStrings.backToList,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: ResColors.brand,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Tên phòng: Đóng khung bo góc và căn lề giữa của dòng
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ResColors.brand.withValues(alpha: 0.4),
                              width: 1.8,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            'Phòng ${room.roomNumber}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: ResColors.textDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Trạng thái: Chỉ hiển thị "Cần dọn", "Đang dọn", "Đã dọn" căn giữa hài hòa
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                labelStatus,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Thẻ thông tin chi tiết phòng (bg_card)
                      Container(
                        width: double.infinity,
                        decoration: AppDrawables.bgCard,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Tầng: ? < 1 dòng >
                            Row(
                              children: [
                                const Text('Tầng: ', style: TextStyle(fontSize: 14.5, color: ResColors.textMuted)),
                                Text(
                                  room.floor.isNotEmpty ? room.floor : '--',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ResColors.textDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 2. Loại phòng < xuống dòng thông tin viết dòng dưới >
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Loại phòng:', style: TextStyle(fontSize: 14, color: ResColors.textMuted)),
                                const SizedBox(height: 4),
                                Text(
                                  room.roomType,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ResColors.textDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 3. Ưu tiên: ---------- < 1 dòng >
                            Row(
                              children: [
                                const Text('Ưu tiên: ', style: TextStyle(fontSize: 14.5, color: ResColors.textMuted)),
                                Text(
                                  room.priority?.toUpperCase() == 'URGENT' ? 'Khẩn cấp' : 'Bình thường',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: room.priority?.toUpperCase() == 'URGENT' ? ResColors.urgent : ResColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 4. Người phụ trách < xuống dòng thông tin viết dòng dưới >
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Người phụ trách:', style: TextStyle(fontSize: 14, color: ResColors.textMuted)),
                                const SizedBox(height: 4),
                                Text(
                                  (room.assignedToName != null && room.assignedToName!.isNotEmpty)
                                      ? room.assignedToName!
                                      : 'Chưa phân công',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ResColors.textDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 5. Cập nhật lúc < xuống dòng thông tin viết dòng dưới >
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Cập nhật lúc:', style: TextStyle(fontSize: 14, color: ResColors.textMuted)),
                                const SizedBox(height: 4),
                                Text(
                                  room.updatedAt.isNotEmpty
                                      ? room.updatedAt.replaceAll('T', ' ').replaceAll('Z', '')
                                      : 'Vừa xong',
                                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: ResColors.textDark),
                                ),
                              ],
                            ),

                            if (room.description != null && room.description!.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ghi chú:', style: TextStyle(fontSize: 14, color: ResColors.textMuted)),
                                  const SizedBox(height: 4),
                                  Text(
                                    room.description!,
                                    style: const TextStyle(fontSize: 14.5, color: ResColors.textDark),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Banner báo lỗi nếu có
                      if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13.5),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // 1. KHI PHÒNG "CẦN DỌN": Chỉ hiện DUY NHẤT nút "Bắt đầu dọn phòng"
                      if (isNeedClean) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isBusy ? null : onStartCleanClick,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ResColors.brand,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: isBusy
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    ResStrings.startClean,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],

                      // 2. KHI ĐÃ BẤM BẮT ĐẦU ("ĐANG DỌN"): Nút bắt đầu biến mất, hiện DUY NHẤT nút "Đã dọn xong"
                      if (isCleaning) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isBusy ? null : onCompleteClick,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: isBusy
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    '✅  ${ResStrings.completeClean}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],

                      // 3. KHI ĐÃ DỌN XONG ("ĐÃ DỌN"): Cho phép báo cần dọn lại nếu phát sinh
                      if (isCleaned) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: isBusy ? null : onRecleanClick,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: isBusy
                                ? const CircularProgressIndicator(color: Color(0xFFDC2626))
                                : const Text(
                                    ResStrings.recleanBtn,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
