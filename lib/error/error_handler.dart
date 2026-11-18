import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'api_error.dart';
import 'api_exception.dart';

typedef ErrorListener = void Function(ApiError error);

class ErrorHandler {
  ErrorHandler._();

  static ErrorListener? _globalListener;

  static void setGlobalListener(ErrorListener? listener) {
    _globalListener = listener;
  }

  static ApiError fromThrowable(dynamic t) {
    if (t is ApiException) {
      return t.apiError;
    }
    if (t is ApiError) {
      return t;
    }
    if (t is TimeoutException) {
      return ApiError(
        status: 0,
        message: 'Kết nối tới máy chủ quá thời gian chờ (timeout). Vui lòng thử lại.',
        errorType: 'TIMEOUT',
      );
    }
    if (t is SocketException) {
      final msg = t.message.toLowerCase();
      if (msg.contains('failed host lookup') || msg.contains('no address associated')) {
        return ApiError(
          status: 0,
          message: 'Không thể kết nối máy chủ vietsage.com do lỗi mạng hoặc DNS. Vui lòng kiểm tra lại kết nối mạng.',
          errorType: 'DNS_NETWORK_ERROR',
        );
      }
      return ApiError(
        status: 0,
        message: 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại đường truyền internet.',
        errorType: 'NETWORK_ERROR',
      );
    }
    if (t is HttpException) {
      return ApiError(
        status: 0,
        message: 'Lỗi giao thức HTTP: ${t.message}',
        errorType: 'HTTP_ERROR',
      );
    }
    if (t is FormatException) {
      return ApiError(
        status: 0,
        message: 'Dữ liệu trả về từ máy chủ không đúng định dạng.',
        errorType: 'PARSE_ERROR',
      );
    }
    final message = (t != null && t.toString().isNotEmpty) ? t.toString() : 'Lỗi hệ thống không xác định';
    return ApiError(status: 0, message: message, errorType: 'UNKNOWN');
  }

  static void handle(BuildContext? context, ApiError? error, {bool showToast = true}) {
    if (error == null) return;
    debugPrint('[CentralErrorHandler] API Error: status=${error.status}, msg=${error.message}');

    _globalListener?.call(error);

    if (showToast && context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.friendlyMessage),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
