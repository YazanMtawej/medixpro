import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class ApiClient {
  late final Dio dio;
  late final Dio _refreshDio;
  final TokenStorage tokenStorage;

  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingQueue = [];

  ApiClient(this.tokenStorage) {
    final baseOptions = BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api/v1/",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "Accept":       "application/json",
        "Content-Type": "application/json",
      },
    );

    dio         = Dio(baseOptions);
    _refreshDio = Dio(baseOptions.copyWith());

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // ─── 1. Token Attachment ───────────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // مسارات عامة لا تحتاج token
          const publicPaths = ["auth/login/", "auth/register/", "auth/refresh/"];
          final isPublic    = publicPaths.any((p) => options.path.contains(p));

          if (!isPublic) {
            final token = await tokenStorage.getAccessToken();
            // ignore: avoid_print
            print("🔑 Attaching token: ${token != null ? '${token.substring(0, 20)}...' : 'NULL'}");

            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            }
          }

          handler.next(options);
        },
      ),
    );

    // ─── 2. Logging ────────────────────────────────────────────────────────
    dio.interceptors.add(LogInterceptor(
      request:         true,
      requestHeader:   true,
      requestBody:     true,
      responseHeader:  false,
      responseBody:    true,
      error:           true,
      // ignore: avoid_print
      logPrint: (obj) => print(obj),
    ));

    // ─── 3. Auto Refresh on 401 ────────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final path       = error.requestOptions.path;

          // فقط نعالج 401 وليس على endpoint الـ refresh نفسه
          if (statusCode != 401 || path.contains("auth/")) {
            return handler.next(error);
          }

          // ignore: avoid_print
          print("🔄 401 detected on $path — attempting token refresh...");

          // إذا كان الـ refresh جارياً، أضف الطلب للقائمة
          if (_isRefreshing) {
            // ignore: avoid_print
            print("⏳ Refresh in progress — queuing request: $path");
            _pendingQueue.add(_PendingRequest(error.requestOptions, handler));
            return;
          }

          _isRefreshing = true;

          try {
            final refreshToken = await tokenStorage.getRefreshToken();

            if (refreshToken == null || refreshToken.isEmpty) {
              // ignore: avoid_print
              print("❌ No refresh token — user must login again");
              _isRefreshing = false;
              return handler.next(error);
            }

            // ignore: avoid_print
            print("🔄 Sending refresh request...");

            final response = await _refreshDio.post(
              "auth/refresh/",
              data: {"refresh": refreshToken},
            );

            // ✅ يدعم هيكلين مختلفين للـ response
            final body      = response.data as Map<String, dynamic>;
            final newAccess = body["data"]?["access"] as String?
                           ?? body["access"]           as String?;

            if (newAccess == null || newAccess.isEmpty) {
              // ignore: avoid_print
              print("❌ Refresh returned no access token — body: $body");
              _isRefreshing = false;
              _failPending(error);
              return handler.next(error);
            }

            // ignore: avoid_print
            print("✅ Token refreshed successfully");
            await tokenStorage.saveAccessToken(newAccess);

            // تنفيذ الطلبات المعلقة
            for (final pending in _pendingQueue) {
              pending.options.headers["Authorization"] = "Bearer $newAccess";
              try {
                final retryRes = await dio.fetch(pending.options);
                pending.handler.resolve(retryRes);
              } catch (e) {
                pending.handler.next(error);
              }
            }
            _pendingQueue.clear();
            _isRefreshing = false;

            // إعادة الطلب الأصلي
            final retryOptions = error.requestOptions;
            retryOptions.headers["Authorization"] = "Bearer $newAccess";
            final retryResponse = await dio.fetch(retryOptions);
            return handler.resolve(retryResponse);

          } catch (e) {
            // ignore: avoid_print
            print("❌ Token refresh FAILED: $e");
            _isRefreshing = false;
            _failPending(error);
            // ✅ لا نمسح الـ token — المستخدم يقرر
            return handler.next(error);
          }
        },
      ),
    );
  }

  void _failPending(DioException error) {
    for (final pending in _pendingQueue) {
      pending.handler.next(error);
    }
    _pendingQueue.clear();
  }
}

class _PendingRequest {
  final RequestOptions         options;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.options, this.handler);
}