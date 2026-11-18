import '../error/api_error.dart';
import 'api_client.dart';
import 'model/room_model.dart';

class RoomApiHandler {
  final ApiClient client;

  RoomApiHandler(this.client);

  void getRooms(
    String hotelId, {
    String? status,
    required void Function(List<RoomModel> rooms) onSuccess,
    required void Function(ApiError error) onError,
  }) {
    String path = '/hotels/${Uri.encodeComponent(hotelId)}/rooms?limit=100';
    if (status != null && status.isNotEmpty) {
      path += '&status=${Uri.encodeComponent(status)}';
    }

    client.request('GET', path, null, (data, error) {
      if (error != null) {
        onError(error);
        return;
      }
      final list = <RoomModel>[];
      if (data != null) {
        final items = data['items'] ?? data['data'];
        if (items is List) {
          for (final item in items) {
            if (item is Map<String, dynamic>) {
              list.add(RoomModel.fromJson(item));
            }
          }
        }
      }
      onSuccess(list);
    });
  }

  void getRoomById(
    String hotelId,
    String roomId, {
    required void Function(RoomModel room) onSuccess,
    required void Function(ApiError error) onError,
  }) {
    final path = '/hotels/${Uri.encodeComponent(hotelId)}/rooms/${Uri.encodeComponent(roomId)}';
    client.request('GET', path, null, (data, error) {
      if (error != null) {
        onError(error);
        return;
      }
      Map<String, dynamic> roomJson = {};
      if (data != null) {
        if (data['data'] is Map<String, dynamic>) {
          roomJson = data['data'] as Map<String, dynamic>;
        } else {
          roomJson = data;
        }
      }
      onSuccess(RoomModel.fromJson(roomJson));
    });
  }

  void getRoomByQr(
    String qrCode, {
    required void Function(RoomModel? room) onSuccess,
    required void Function(ApiError error) onError,
  }) {
    final path = '/hotels/housekeeping/rooms/by-qr/${Uri.encodeComponent(qrCode)}';
    client.request('GET', path, null, (data, error) {
      if (error != null) {
        onError(error);
        return;
      }
      Map<String, dynamic> roomJson = {};
      if (data != null) {
        if (data['room'] is Map<String, dynamic>) {
          roomJson = data['room'] as Map<String, dynamic>;
        } else if (data['data'] is Map<String, dynamic>) {
          roomJson = data['data'] as Map<String, dynamic>;
        } else {
          roomJson = data;
        }
      }
      onSuccess(RoomModel.fromJson(roomJson));
    });
  }

  void markRoomReady(
    String hotelId,
    String roomId, {
    String? expectedUpdatedAt,
    required void Function(bool success) onDone,
    required void Function(ApiError error) onError,
  }) {
    final path = '/hotels/${Uri.encodeComponent(hotelId)}/rooms/${Uri.encodeComponent(roomId)}/ready';
    final body = <String, dynamic>{};
    if (expectedUpdatedAt != null && expectedUpdatedAt.isNotEmpty) {
      body['expectedUpdatedAt'] = expectedUpdatedAt;
    }

    client.request('PATCH', path, body, (data, error) {
      if (error != null) {
        // Fallback retry without expectedUpdatedAt in case of timestamp mismatch
        if (error.status == 409) {
          client.request('PATCH', path, {}, (d2, err2) {
            if (err2 != null) {
              onError(err2);
            } else {
              onDone(true);
            }
          });
          return;
        }
        onError(error);
      } else {
        onDone(true);
      }
    });
  }

  void reCleanRoom(
    String hotelId,
    String roomId, {
    required void Function(bool success) onDone,
    required void Function(ApiError error) onError,
  }) {
    final path = '/hotels/${Uri.encodeComponent(hotelId)}/rooms/${Uri.encodeComponent(roomId)}/re-clean';
    client.request('POST', path, {}, (data, error) {
      if (error != null) {
        onError(error);
      } else {
        onDone(true);
      }
    });
  }
}
