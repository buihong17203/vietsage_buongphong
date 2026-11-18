import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vietsage_buongphong/api/model/room_model.dart';
import 'package:vietsage_buongphong/api/model/task_model.dart';
import 'package:vietsage_buongphong/api/model/user_profile_model.dart';
import 'package:vietsage_buongphong/main.dart';
import 'package:vietsage_buongphong/session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionStore.instance.init();
  });

  testWidgets('App loads LoginActivity by default when not logged in', (WidgetTester tester) async {
    await tester.pumpWidget(const VietSageHousekeepingApp());
    await tester.pumpAndSettle();

    expect(find.text('VIETSAGE'), findsOneWidget);
    expect(find.text('Đăng Nhập'), findsOneWidget);
    expect(find.text('ĐĂNG NHẬP'), findsOneWidget);
  });

  test('RoomModel parses JSON correctly', () {
    final json = {
      'id': 'room-101',
      'roomNumber': '101',
      'floor': '1',
      'status': 'PROCESSING',
      'roomType': 'Deluxe',
      'priority': 'URGENT',
      'assignedToName': 'Nguyễn Văn A',
    };
    final room = RoomModel.fromJson(json);
    expect(room.id, equals('room-101'));
    expect(room.roomNumber, equals('101'));
    expect(room.status, equals('PROCESSING'));
    expect(room.roomType, equals('Deluxe'));
    expect(room.priority, equals('URGENT'));
    expect(room.assignedToName, equals('Nguyễn Văn A'));
  });

  test('TaskModel parses JSON correctly', () {
    final json = {
      'id': 'task-1',
      'roomId': 'room-101',
      'roomNumber': '101',
      'title': 'Dọn phòng khách trả',
      'status': 'CLAIMED',
      'priority': 'NORMAL',
    };
    final task = TaskModel.fromJson(json);
    expect(task.id, equals('task-1'));
    expect(task.status, equals('CLAIMED'));
  });

  test('UserProfileModel parses JSON correctly', () {
    final json = {
      'id': 'user-1',
      'name': 'Trần Thị B',
      'email': 'buongphong@vietsage.vn',
      'role': 'Nhân viên buồng phòng',
      'hotelName': 'VietSage Hotel',
    };
    final user = UserProfileModel.fromJson(json);
    expect(user.name, equals('Trần Thị B'));
    expect(user.role, equals('Nhân viên buồng phòng'));
  });
}
