import 'package:dio/dio.dart';

class AppErrorHandler {
  /// يُرجع رسالة مناسبة للمستخدم ويطبع التفاصيل في الـ console
  static String handle(Object error, {String context = ""}) {
    String userMessage;
    String devLog;

    if (error is DioException) {
      devLog = "[DIO ERROR] $context | "
          "status=${error.response?.statusCode} | "
          "url=${error.requestOptions.path} | "
          "data=${error.response?.data}";

      switch (error.response?.statusCode) {
        case 400:
          final msg = _extractServerMessage(error.response?.data);
          userMessage = msg ?? "Invalid request. Please check your input.";
          break;
        case 401:
          userMessage = "Your session has expired. Please log in again.";
          break;
        case 403:
          final msg = _extractServerMessage(error.response?.data);
          userMessage = msg ?? "You don't have permission to perform this action.";
          break;
        case 404:
          userMessage = "The requested resource was not found.";
          break;
        case 500:
          userMessage = "Server error. Please try again later.";
          break;
        default:
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            userMessage = "Connection timed out. Please check your internet.";
          } else if (error.type == DioExceptionType.connectionError) {
            userMessage = "No internet connection. Please check your network.";
          } else {
            userMessage = "Something went wrong. Please try again.";
          }
      }
    } else {
      devLog    = "[APP ERROR] $context | ${error.runtimeType}: $error";
      userMessage = "An unexpected error occurred. Please try again.";
    }

    // ✅ طباعة التفاصيل في الـ console فقط
    // ignore: avoid_print
    print("🔴 $devLog");

    return userMessage;
  }

  static String? _extractServerMessage(dynamic data) {
    if (data == null) return null;
    try {
      if (data is Map) {
        return data["message"]?.toString() ??
               data["detail"]?.toString() ??
               data["error"]?.toString();
      }
    } catch (_) {}
    return null;
  }
}