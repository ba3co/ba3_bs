import 'package:dio/dio.dart';

import '../../../../core/classes/datasources/api_client_base.dart';

class DioClient<T> implements APiClientBase<T> {
  final Dio dio;

  DioClient(this.dio);

  @override
  Future<T> post(String url, {Map<String, String>? headers, Object? body}) async {
    final response = await dio.post(url, options: Options(headers: headers), data: body);

    if (response.statusCode == 200) {
      return response.data as T;
    } else {
      throw Exception('Dio Error: ${response.statusCode}');
    }
  }
}
