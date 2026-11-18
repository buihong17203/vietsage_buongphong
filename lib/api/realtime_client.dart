import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../session_store.dart';
import 'api_client.dart';

typedef RealtimeEventListener = void Function(String eventName, Map<String, dynamic> payload);

class RealtimeClient {
  io.Socket? _socket;
  RealtimeEventListener? _listener;

  void connect(SessionStore session, RealtimeEventListener listener) {
    _listener = listener;
    close();

    final client = ApiClient(
      baseUrl: session.baseUrl,
      token: session.accessToken,
      sessionStore: session,
    );

    final hotelIdEncoded = Uri.encodeComponent(session.hotelId);
    client.request('POST', '/hotels/$hotelIdEncoded/request-realtime-ticket', null, (data, error) {
      if (error != null || data == null) {
        debugPrint('[RealtimeClient] Failed to get ticket: ${error?.message}');
        return;
      }

      final ticket = data['ticket']?.toString() ?? '';
      if (ticket.isEmpty) {
        debugPrint('[RealtimeClient] Empty ticket received.');
        return;
      }

      try {
        final socketUrl = '${session.baseUrl}/request-realtime';
        _socket = io.io(
          socketUrl,
          io.OptionBuilder()
              .setPath('/socket.io')
              .setTransports(['websocket', 'polling'])
              .disableAutoConnect()
              .setAuth({'mode': 'owner', 'ticket': ticket})
              .build(),
        );

        final events = [
          'request_realtime.ready',
          'room_status.updated',
          'housekeeping_task.created',
          'housekeeping_task.claimed',
          'housekeeping_task.started',
          'housekeeping_task.blocked',
          'housekeeping_task.completed',
          'housekeeping_task.reopened',
        ];

        for (final event in events) {
          _socket!.on(event, (data) {
            Map<String, dynamic> payload = {};
            if (data is Map<String, dynamic>) {
              payload = data;
            } else if (data is Map) {
              payload = Map<String, dynamic>.from(data);
            }
            _listener?.call(event, payload);
          });
        }

        _socket!.on('request_realtime.error', (_) {
          close();
          _listener?.call('request_realtime.error', {});
        });

        _socket!.onConnect((_) {
          debugPrint('[RealtimeClient] Socket connected successfully to $socketUrl');
        });

        _socket!.onDisconnect((_) {
          debugPrint('[RealtimeClient] Socket disconnected');
        });

        _socket!.connect();
      } catch (e) {
        debugPrint('[RealtimeClient] Error initializing socket: $e');
        close();
      }
    });
  }

  void close() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }
}
