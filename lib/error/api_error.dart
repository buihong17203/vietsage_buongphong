class ApiError {
  int status;
  String message;
  String errorType;
  int timestamp;

  ApiError({
    this.status = 0,
    this.message = '',
    String? errorType,
    int? timestamp,
  })  : errorType = errorType ?? resolveErrorType(status),
        timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  static String resolveErrorType(int status) {
    if (status == 0) return 'NETWORK_ERROR';
    if (status == 400) return 'BAD_REQUEST';
    if (status == 401) return 'UNAUTHORIZED';
    if (status == 403) return 'FORBIDDEN';
    if (status == 404) return 'NOT_FOUND';
    if (status >= 500) return 'SERVER_ERROR';
    return 'UNKNOWN_ERROR';
  }

  bool get isAuthError => status == 401;
  bool get isForbidden => status == 403;
  bool get isNetworkError => status == 0;
  bool get isServerError => status >= 500;

  String get friendlyMessage {
    if (status == 0) {
      return 'Không thể kết nối máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.';
    }
    if (status == 401) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }
    if (status == 403) {
      return 'Bạn không có quyền truy cập chức năng này.';
    }
    if (status == 404) {
      return 'Dữ liệu yêu cầu không tìm thấy.';
    }
    if (status >= 500) {
      return 'Máy chủ đang gặp sự cố ($status). Vui lòng thử lại sau.';
    }
    return message.isNotEmpty ? message : 'Đã có lỗi xảy ra. Mã lỗi: $status';
  }

  @override
  String toString() {
    return 'ApiError{status=$status, message="$message", type="$errorType"}';
  }
}
