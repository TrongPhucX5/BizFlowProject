class ApiResponse<T> {
  final int code;
  final String message;
  final T? result;
  final List<String>? errors;

  ApiResponse({
    this.code = 1000,
    this.message = '',
    this.result,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, [T Function(dynamic)? fromJsonT]) {
    return ApiResponse(
      code: json['code'] ?? 1000,
      message: json['message'] ?? '',
      result: json['result'] != null && fromJsonT != null 
          ? fromJsonT(json['result']) 
          : (json['result'] as T?), // Cast fallback if T is dynamic/map
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }

  bool get isSuccess => code == 1000;
}
