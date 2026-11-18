class ApiConfig {
  ApiConfig._();

  static const String defaultBaseUrl = 'https://vietsage.com';

  static String normalizeBaseUrl(String? value) {
    String url = (value == null) ? '' : value.trim();
    if (url.isEmpty) return defaultBaseUrl;
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (url.startsWith('http://')) {
      throw ArgumentError('Insecure HTTP API URL is rejected: $url');
    }
    if (!url.startsWith('https://')) {
      url = 'https://$url';
    }
    return url;
  }
}
