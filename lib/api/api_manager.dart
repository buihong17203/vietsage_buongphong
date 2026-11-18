import '../session_store.dart';
import 'api_client.dart';
import 'auth_api_handler.dart';
import 'room_api_handler.dart';
import 'task_api_handler.dart';

class ApiManager {
  static ApiManager? _instance;

  final SessionStore sessionStore;
  final ApiClient client;
  final AuthApiHandler authHandler;
  final RoomApiHandler roomHandler;
  final TaskApiHandler taskHandler;

  factory ApiManager.getInstance([SessionStore? store]) {
    final effectiveStore = store ?? SessionStore.instance;
    if (_instance == null || _instance!.sessionStore != effectiveStore) {
      final c = ApiClient(sessionStore: effectiveStore);
      _instance = ApiManager._withClient(
        effectiveStore,
        c,
        AuthApiHandler(c),
        RoomApiHandler(c),
        TaskApiHandler(c),
      );
    }
    return _instance!;
  }

  ApiManager._withClient(
    this.sessionStore,
    this.client,
    this.authHandler,
    this.roomHandler,
    this.taskHandler,
  );

  AuthApiHandler get auth => authHandler;
  RoomApiHandler get rooms => roomHandler;
  TaskApiHandler get tasks => taskHandler;
}
