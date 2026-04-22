import 'package:dio/dio.dart';

class AppErrorHandler {
  AppErrorHandler._();

  static String handle(Object error, {String context = ""}) {
    String userMessage;

    if (error is DioException) {
      final status  = error.response?.statusCode;
      final data    = error.response?.data;
      final server  = _extractMessage(data);

      // ignore: avoid_print
      print("🔴 [$context] status=$status | url=${error.requestOptions.path} | data=$data");

      switch (status) {
        case 400: userMessage = server ?? "Invalid request. Please check your input."; break;
        case 401: userMessage = "Session expired. Please log in again.";                break;
        case 403: userMessage = server ?? "You don't have permission for this action."; break;
        case 404: userMessage = "The requested item was not found.";                    break;
        case 429: userMessage = "Too many requests. Please wait a moment.";             break;
        case 500: userMessage = "Server error. Please try again later.";                break;
        default:
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            userMessage = "Connection timed out. Please check your internet.";
          } else if (error.type == DioExceptionType.connectionError) {
            userMessage = "No internet connection.";
          } else {
            userMessage = "Something went wrong. Please try again.";
          }
      }
    } else {
      // ignore: avoid_print
      print("🔴 [$context] ${error.runtimeType}: $error");
      userMessage = "An unexpected error occurred.";
    }

    return userMessage;
  }

  static String? _extractMessage(dynamic data) {
    if (data == null) return null;
    try {
      if (data is Map) {
        return (data["message"] ?? data["detail"] ?? data["error"])?.toString();
      }
    } catch (_) {}
    return null;
  }
}