import 'package:dio/dio.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    dio = Dio(BaseOptions(
      baseUrl: "https://api.example.com", // Set your API base URL
      connectTimeout: const Duration(seconds: 10), // Timeout settings
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Add interceptors (Optional: For logging, token handling)
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("Request: ${options.method} ${options.path}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("Response: ${response.statusCode}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("Error: ${e.message}");
        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? params}) async {
    return await dio.get(endpoint, queryParameters: params);
  }

  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    return await dio.post(endpoint, data: data);
  }
}
