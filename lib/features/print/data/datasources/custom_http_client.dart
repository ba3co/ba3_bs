import 'dart:convert';

import 'package:http/http.dart';

import '../../../../core/classes/datasources/http_client_base.dart';

class CustomHttpClient<T> implements HttpClientBase<T> {
  final Client client;

  CustomHttpClient(this.client);

  @override
  Future<T> post(String url, {Map<String, String>? headers, Object? body}) async {
    final response = await client.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }
}
