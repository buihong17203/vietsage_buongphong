class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.message = '',
    this.data,
    this.statusCode = 200,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    final status = json['statusCode'] is int
        ? json['statusCode'] as int
        : int.tryParse(json['statusCode']?.toString() ?? '200') ?? 200;
    final success = json['success'] is bool
        ? json['success'] as bool
        : (status >= 200 && status < 300);

    final rawData = json['data'] ?? json;
    T? parsedData;
    if (rawData != null && fromJsonT != null) {
      parsedData = fromJsonT(rawData);
    }

    return ApiResponse<T>(
      success: success,
      message: (json['message'] ?? '').toString(),
      data: parsedData,
      statusCode: status,
    );
  }
}
