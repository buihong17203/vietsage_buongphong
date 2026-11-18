import 'package:flutter_test/flutter_test.dart';
import 'package:vietsage_buongphong/api/api_config.dart';
import 'package:vietsage_buongphong/housekeeping_rules.dart';
import 'package:vietsage_buongphong/session_store.dart';

void main() {
  group('HousekeepingRules Tests', () {
    test('onlyProcessingRoomCanBeCompleted', () {
      expect(HousekeepingRules.canComplete('PROCESSING', 'QUEUED'), isTrue);
      expect(HousekeepingRules.canComplete('PROCESSING', 'IN_PROGRESS'), isTrue);
      expect(HousekeepingRules.canComplete('PROCESSING', null), isTrue);
      expect(HousekeepingRules.canComplete('PROCESSING', ''), isTrue);
      expect(HousekeepingRules.canComplete('OCCUPIED', 'IN_PROGRESS'), isFalse);
      expect(HousekeepingRules.canComplete('PROCESSING', 'BLOCKED'), isFalse);
      expect(HousekeepingRules.canComplete('AVAILABLE', ''), isFalse);
    });

    test('apiUrlMustBeHttpsWithoutTrailingSlash', () {
      expect(
        ApiConfig.normalizeBaseUrl(' https://vietsage.com/ '),
        equals('https://vietsage.com'),
      );
      expect(
        ApiConfig.normalizeBaseUrl(' https://api.vietsage.vn/ '),
        equals('https://api.vietsage.vn'),
      );
    });

    test('insecureApiUrlIsRejected', () {
      expect(
        () => ApiConfig.normalizeBaseUrl('http://api.vietsage.vn'),
        throwsArgumentError,
      );
    });

    test('defaultHotelIdAndNameConstants', () {
      expect(SessionStore.defaultHotelId, equals('cmsr8ftxx013h01qp1sjkp8s8'));
      expect(SessionStore.defaultHotelName, equals('VietSage Hotel'));
    });
  });
}
