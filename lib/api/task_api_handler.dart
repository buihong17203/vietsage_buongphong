import '../error/api_error.dart';
import 'api_client.dart';
import 'model/task_model.dart';

class TaskApiHandler {
  final ApiClient client;

  TaskApiHandler(this.client);

  void getTasksByRoom(
    String hotelId,
    String roomId, {
    required void Function(List<TaskModel> tasks) onSuccess,
    required void Function(ApiError error) onError,
  }) {
    final path = '/hotels/${Uri.encodeComponent(hotelId)}/housekeeping/tasks?roomId=${Uri.encodeComponent(roomId)}&limit=10';
    client.request('GET', path, null, (data, error) {
      if (error != null) {
        onError(error);
        return;
      }
      final list = <TaskModel>[];
      if (data != null) {
        final items = data['items'] ?? data['data'];
        if (items is List) {
          for (final item in items) {
            if (item is Map<String, dynamic>) {
              list.add(TaskModel.fromJson(item));
            }
          }
        }
      }
      onSuccess(list);
    });
  }

  void mutateTask(
    String hotelId,
    String taskId,
    String endpoint, {
    int? expectedVersion,
    required void Function(Map<String, dynamic>? data) onSuccess,
    required void Function(ApiError error) onError,
  }) {
    final path = '/hotels/${Uri.encodeComponent(hotelId)}/housekeeping/tasks/${Uri.encodeComponent(taskId)}/$endpoint';
    final body = <String, dynamic>{};
    if (expectedVersion != null) {
      body['expectedVersion'] = expectedVersion;
    }

    client.request('POST', path, body, (data, error) {
      if (error != null) {
        onError(error);
      } else {
        onSuccess(data);
      }
    });
  }

  void updateTaskStatus(
    String hotelId,
    String taskId,
    String status, {
    required void Function(bool success, ApiError? error) callback,
  }) {
    final path = '/hotels/${Uri.encodeComponent(hotelId)}/housekeeping/tasks/${Uri.encodeComponent(taskId)}';
    final payload = {'status': status};

    client.request('PATCH', path, payload, (data, error) {
      callback(error == null, error);
    });
  }
}
