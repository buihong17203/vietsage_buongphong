import 'package:flutter/material.dart';
import '../../api/model/room_model.dart';
import '../../drawable/drawables.dart';
import '../values/colors.dart';
import '../values/strings.dart';

class ActivityHomeLayout extends StatelessWidget {
  final String hotelName;
  final String staffSubtitle;
  final List<RoomModel> rooms;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onProfileClick;
  final VoidCallback onScanQrClick;
  final void Function(RoomModel room) onRoomClick;

  const ActivityHomeLayout({
    super.key,
    required this.hotelName,
    required this.staffSubtitle,
    required this.rooms,
    required this.isLoading,
    this.errorMessage,
    required this.onRefresh,
    required this.onProfileClick,
    required this.onScanQrClick,
    required this.onRoomClick,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: ResColors.brand,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    children: [
                      // App Logo - Tap to open Profile
                      GestureDetector(
                        onTap: onProfileClick,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: AppDrawables.appLogo(size: 34),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Header Title & Subtitle
                      Expanded(
                        child: GestureDetector(
                          onTap: onProfileClick,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hotelName.isNotEmpty ? hotelName : ResStrings.defaultHotelName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                staffSubtitle,
                                style: const TextStyle(
                                  color: Color(0xFFD1FAE5),
                                  fontSize: 12.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Scan QR Button
                      ElevatedButton.icon(
                        onPressed: onScanQrClick,
                        icon: const Icon(AppDrawables.icQrScan, size: 16, color: ResColors.brand),
                        label: const Text(
                          ResStrings.scanQr,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: ResColors.brand,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: ResColors.brand,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: const Size(0, 38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sub-header: Title & swipe hint (Responsive)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      const Text(
                        ResStrings.roomsToClean,
                        style: TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.bold,
                          color: ResColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        ResStrings.swipeHint,
                        style: TextStyle(
                          fontSize: 12,
                          color: ResColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Error banner if any
            if (errorMessage != null && errorMessage!.isNotEmpty)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13),
                    ),
                  ),
                ),
              ),

            // Main Content: Refreshable Room List
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                color: ResColors.brand,
                child: rooms.isEmpty
                    ? (isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: ResColors.brand),
                          )
                        : _buildEmptyState())
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                            itemCount: rooms.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              return _buildRoomCard(room);
                            },
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 90),
        const Center(
          child: Text('✨', style: TextStyle(fontSize: 48)),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            ResStrings.allRoomsClean,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ResColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            ResStrings.allRoomsCleanSub,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: ResColors.textMuted,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomCard(RoomModel room) {
    // Chỉ hiển thị 'Cần dọn', 'Đang dọn', 'Đã dọn'
    final labelStatus = ResStrings.label(room.status);

    Color statusColor = const Color(0xFFDC2626);
    Color statusBg = const Color(0xFFFEE2E2);
    if (labelStatus == 'Đang dọn') {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFEF3C7);
    } else if (labelStatus == 'Đã dọn') {
      statusColor = const Color(0xFF16A34A);
      statusBg = const Color(0xFFDCFCE7);
    }

    // Người phụ trách: Chỉ hiện tên khi có người bấm bắt đầu dọn (trạng thái 'Đang dọn'), bình thường để trống sau dấu :
    final isCleaningStarted = labelStatus == 'Đang dọn';
    final staffName = (isCleaningStarted && room.assignedToName != null && room.assignedToName!.isNotEmpty)
        ? room.assignedToName!
        : '';

    return InkWell(
      onTap: () => onRoomClick(room),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: AppDrawables.bgCard,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng 1: Phòng ??? & Trạng thái
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Phòng ${room.roomNumber}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ResColors.textDark,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    labelStatus,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dòng 2: Tầng ? • Loại phòng
            Text(
              'Tầng ${room.floor.isNotEmpty ? room.floor : "--"}  •  Loại phòng: ${room.roomType}',
              style: const TextStyle(fontSize: 13.5, color: ResColors.textMuted),
            ),
            const SizedBox(height: 5),

            // Dòng 3: Người phụ trách: (chỉ hiện tên khi có người bấm bắt đầu dọn, bình thường sau : để trống)
            Text(
              'Người phụ trách: $staffName',
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: ResColors.border),
            const SizedBox(height: 10),

            // Dòng 4: Xem chi tiết
            const Row(
              children: [
                Text(
                  'Xem chi tiết',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: ResColors.brand,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 11,
                  color: ResColors.brand,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
