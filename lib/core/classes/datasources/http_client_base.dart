abstract class HttpClientBase<T> {
  Future<T> post(String url, {Map<String, String>? headers, Object? body});
}
