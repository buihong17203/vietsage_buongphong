import 'package:flutter/material.dart';
import '../../drawable/drawables.dart';
import '../values/colors.dart';

class DialogQrResultLayout extends StatelessWidget {
  final String qrContent;
  final String? roomInfo;
  final bool isUrl;
  final VoidCallback onCopy;
  final VoidCallback onOpenLink;
  final VoidCallback? onActionRoom;
  final VoidCallback onClose;

  const DialogQrResultLayout({
    super.key,
    required this.qrContent,
    this.roomInfo,
    required this.isUrl,
    required this.onCopy,
    required this.onOpenLink,
    this.onActionRoom,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: ResColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kết quả quét mã QR',
              style: TextStyle(
                color: ResColors.brand,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Nội dung mã QR:',
              style: TextStyle(color: Color(0xFF52706A), fontSize: 13),
            ),
            const SizedBox(height: 10),

            // Content Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: AppDrawables.bgCard,
              child: SelectableText(
                qrContent,
                style: const TextStyle(fontSize: 14.5, color: ResColors.textDark),
              ),
            ),

            if (roomInfo != null && roomInfo!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCEEAD6)),
                ),
                child: Text(
                  roomInfo!,
                  style: const TextStyle(
                    color: Color(0xFF137333),
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Copy & Open Link Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCopy,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Sao chép'),
                  ),
                ),
                if (isUrl) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onOpenLink,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Mở liên kết'),
                    ),
                  ),
                ],
              ],
            ),

            if (onActionRoom != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onActionRoom,
                  child: const Text('Vào dọn phòng này'),
                ),
              ),
            ],

            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onClose,
                child: const Text('Đóng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
