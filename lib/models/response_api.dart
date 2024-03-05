import 'dart:convert';

ResponseApi responseApiFromJson(String str) => ResponseApi.fromJson(json.decode(str));

String responseApiToJson(ResponseApi data) => json.encode(data.toJson());

class ResponseApi {
  bool success;
  String error;
  String message;
  dynamic data;

  ResponseApi({
    required this.success,
    required this.message,
    required this.error,
    required this.data,
  });

  factory ResponseApi.fromJson(Map<String, dynamic> json) {
    return ResponseApi(
      success: json["success"] ?? false, // Ensure it defaults to false if null
      message: json["message"] ?? "",
      error: json["error"] ?? "",
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "error": error,
    "data": data,
  };
}
