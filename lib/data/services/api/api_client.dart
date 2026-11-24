// ─── API Client ───────────────────────────────────────────────────
// JSON over HTTPS to the DomEase Node.js API (PRD 8.2). Every error leaves
// here as a domain Failure, so no screen ever handles a DioException.
import 'package:dio/dio.dart';

import 'package:domease/domain/models/failure.dart';

class ApiClient {
  ApiClient(String apiRoot, {String? Function()? token})
      : _dio = Dio(BaseOptions(
          baseUrl: apiRoot,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          contentType: Headers.jsonContentType,
        )) {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      final t = token?.call();
      if (t != null) options.headers['Authorization'] = 'Bearer $t';
      handler.next(options);
    }));
  }

  final Dio _dio;

  Future<dynamic> get(String path) => _send(() => _dio.get<dynamic>(path));
  Future<dynamic> post(String path, [Object? body]) => _send(() => _dio.post<dynamic>(path, data: body));
  Future<dynamic> put(String path, Object? body) => _send(() => _dio.put<dynamic>(path, data: body));
  Future<dynamic> patch(String path, Object? body) => _send(() => _dio.patch<dynamic>(path, data: body));
  Future<dynamic> delete(String path) => _send(() => _dio.delete<dynamic>(path));

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return (await call()).data;
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  Failure _failure(DioException e) {
    final status = e.response?.statusCode;
    if (status == null) return const NetworkFailure();
    if (status == 404) return const NotFoundFailure();
    final data = e.response?.data;
    final message = data is Map && data['message'] is String ? data['message'] as String : null;
    return message == null ? const ServerFailure() : ServerFailure(message);
  }
}
