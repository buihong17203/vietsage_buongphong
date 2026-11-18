import 'package:flutter/material.dart';
import '../res/values/colors.dart';

class AppDrawables {
  AppDrawables._();

  /// Corresponds to res/drawable/bg_card.xml
  /// White background, 12dp rounded corner, 1dp #D7E3E0 border
  static BoxDecoration get bgCard => BoxDecoration(
        color: ResColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ResColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get bgCardSelected => BoxDecoration(
        color: ResColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ResColors.brand, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: ResColors.brand.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );

  /// App Logo Widget referencing assets/images/ic_app_logo.png
  static Widget appLogo({double size = 48}) {
    return Image.asset(
      'assets/images/ic_app_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback icon if asset image is not loaded
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: ResColors.brand,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.hotel_rounded, color: Colors.white, size: size * 0.6),
        );
      },
    );
  }

  // Icons matching res/drawable XML files
  static const IconData icArrowBack = Icons.arrow_back_ios_new_rounded;
  static const IconData icEdit = Icons.edit_outlined;
  static const IconData icLogout = Icons.logout_rounded;
  static const IconData icPerson = Icons.person_outline_rounded;
  static const IconData icQrScan = Icons.qr_code_scanner_rounded;
  static const IconData icHotel = Icons.apartment_rounded;
  static const IconData icRefresh = Icons.refresh_rounded;
  static const IconData icFlash = Icons.flash_on_rounded;
  static const IconData icFlashOff = Icons.flash_off_rounded;
}
