import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class ApiClient {
  late final Dio dio;
  late final Dio _refreshDio;
  final TokenStorage tokenStorage;

  bool _isRefreshing = false;
  final List<_PendingRequest> _queue = [];
//http://10.119.116.175:8000/api/v1/
  static const _baseUrl = "http://127.0.0.1:8000/api/v1/";
  // ✅ للـ production غير لـ:
  // static const _baseUrl = "https://api.medixpro.com/api/v1/";

  static const _publicPaths = ["auth/login/", "auth/register/", "auth/refresh/"];

  ApiClient(this.tokenStorage) {
    final opts = BaseOptions(
      baseUrl:        _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "Accept":       "application/json",
        "Content-Type": "application/json",
      },
    );

    dio         = Dio(opts);
    _refreshDio = Dio(opts.copyWith());

    _addTokenInterceptor();
    _addLogInterceptor();
    _addRefreshInterceptor();
  }

  void _addTokenInterceptor() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final isPublic = _publicPaths.any((p) => options.path.contains(p));
        if (!isPublic) {
          final token = await tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
        }
        handler.next(options);
      },
    ));
  }

  void _addLogInterceptor() {
    dio.interceptors.add(LogInterceptor(
      request:        true,
      requestHeader:  true,
      requestBody:    true,
      responseHeader: false,
      responseBody:   true,
      error:          true,
      // ignore: avoid_print
      logPrint: (o) => print(o),
    ));
  }

  void _addRefreshInterceptor() {
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final path   = error.requestOptions.path;

        if (status != 401 || path.contains("auth/")) {
          return handler.next(error);
        }

        if (_isRefreshing) {
          _queue.add(_PendingRequest(error.requestOptions, handler));
          return;
        }

        _isRefreshing = true;

        try {
          final refresh = await tokenStorage.getRefreshToken();
          if (refresh == null || refresh.isEmpty) {
            _isRefreshing = false;
            return handler.next(error);
          }

          final res  = await _refreshDio.post(
            "auth/refresh/",
            data: {"refresh": refresh},
          );

          final body      = res.data as Map<String, dynamic>;
          final newAccess = body["data"]?["access"] as String?
                         ?? body["access"]           as String?;

          if (newAccess == null || newAccess.isEmpty) {
            _isRefreshing = false;
            _flushQueue(error);
            return handler.next(error);
          }

          await tokenStorage.saveAccessToken(newAccess);

          // تنفيذ الطلبات المعلقة
          for (final p in _queue) {
            p.options.headers["Authorization"] = "Bearer $newAccess";
            try {
              handler.resolve(await dio.fetch(p.options));
            } catch (e) {
              p.handler.next(error);
            }
          }
          _queue.clear();
          _isRefreshing = false;

          // إعادة الطلب الأصلي
          error.requestOptions.headers["Authorization"] = "Bearer $newAccess";
          return handler.resolve(await dio.fetch(error.requestOptions));

        } catch (e) {
          _isRefreshing = false;
          _flushQueue(error);
          return handler.next(error);
        }
      },
    ));
  }

  void _flushQueue(DioException error) {
    for (final p in _queue) {
      p.handler.next(error);
    }
    _queue.clear();
  }
}

class _PendingRequest {
  final RequestOptions          options;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.options, this.handler);
}