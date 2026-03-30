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
            baseUrl: "http://127.0.0.1:8000/api/v1/",
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
            baseUrl: "http://127.0.0.1:8000/api/v1/",
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
          ),
        ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    /// 🔐 Attach Token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getAccessToken();

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },
      ),
    );

    /// 📡 Logging (Debug فقط)
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    /// 🔄 Refresh Logic 
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode != 401) {
            return handler.next(error);
          }

          final requestOptions = error.requestOptions;

          ///  لا تعيد محاولة refresh endpoint نفسه
          if (requestOptions.path.contains("auth/refresh")) {
            return handler.next(error);
          }

          /// إذا في refresh شغال → دخّل بالqueue
          if (_isRefreshing) {
            return _enqueueRequest(requestOptions, handler);
          }

          _isRefreshing = true;

          try {
            final refreshToken = await tokenStorage.getRefreshToken();

            if (refreshToken == null) {
              _isRefreshing = false;
              return handler.next(error);
            }

            final response = await _refreshDio.post(
              "auth/refresh/",
              data: {"refresh": refreshToken},
            );

            final newAccess = response.data["access"];

            await tokenStorage.saveAccessToken(newAccess);

            /// نفّذ كل الطلبات المعلقة
            for (var retry in _retryQueue) {
              retry(newAccess);
            }
            _retryQueue.clear();

            /// إعادة الطلب الحالي
            requestOptions.headers["Authorization"] = "Bearer $newAccess";
            final retryResponse = await dio.fetch(requestOptions);

            _isRefreshing = false;

            return handler.resolve(retryResponse);
          } catch (e) {
            _isRefreshing = false;
            _retryQueue.clear();

            ///  لا تمسح التوكن هنا
            return handler.next(error);
          }
        },
      ),
    );
  }

  /// 🧠 Queue للطلبات أثناء refresh
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