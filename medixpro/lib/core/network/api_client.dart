import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class ApiClient {
  final Dio dio;
  final Dio _refreshDio;
  final TokenStorage tokenStorage;

  bool _isRefreshing = false;
  final List<Function(String)> _retryQueue = [];

  ApiClient(this.tokenStorage)
      : dio = Dio(
          BaseOptions(
            baseUrl: "http://127.0.0.1:8000//api/v1/",
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
          ),
        ),
        _refreshDio = Dio(
          BaseOptions(
            baseUrl: "http://127.0.0.1:8000//api/v1/",
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
          ),
        ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // ─── 1. Attach Access Token ───────────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // مسارات لا تحتاج توكن
          final publicPaths = ["auth/login/", "auth/register/", "auth/refresh/"];
          final isPublic = publicPaths.any((p) => options.path.contains(p));

          if (!isPublic) {
            final token = await tokenStorage.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            }
          }

          handler.next(options);
        },
      ),
    );

    // ─── 2. Logging (debug only) ──────────────────────────────────────────────
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    // ─── 3. Auto Refresh on 401 ───────────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final path = error.requestOptions.path;

          // لا تعالج غير 401، ولا تعيد محاولة refresh endpoint نفسه
          if (statusCode != 401 || path.contains("auth/refresh/")) {
            return handler.next(error);
          }

          if (_isRefreshing) {
            return _enqueueRequest(error.requestOptions, handler);
          }

          _isRefreshing = true;

          try {
            final refreshToken = await tokenStorage.getRefreshToken();

            if (refreshToken == null || refreshToken.isEmpty) {
              _isRefreshing = false;
              return handler.next(error);
            }

            final response = await _refreshDio.post(
              "auth/refresh/",
              data: {"refresh": refreshToken},
            );

            // ✅ البيانات داخل response.data["data"]["access"]
            final responseBody = response.data as Map<String, dynamic>;
            final newAccess = responseBody["data"]["access"] as String;

            await tokenStorage.saveAccessToken(newAccess);

            // تنفيذ الطلبات المعلقة
            for (final retry in _retryQueue) {
              retry(newAccess);
            }
            _retryQueue.clear();
            _isRefreshing = false;

            // إعادة الطلب الأصلي
            final retryOptions = error.requestOptions;
            retryOptions.headers["Authorization"] = "Bearer $newAccess";
            final retryResponse = await dio.fetch(retryOptions);
            return handler.resolve(retryResponse);
          } catch (e) {
            _isRefreshing = false;
            _retryQueue.clear();
            await tokenStorage.clear();
            return handler.next(error);
          }
        },
      ),
    );
  }

  Future<void> _enqueueRequest(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    _retryQueue.add((token) async {
      try {
        requestOptions.headers["Authorization"] = "Bearer $token";
        final response = await dio.fetch(requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.reject(e as DioException);
      }
    });
  }
}