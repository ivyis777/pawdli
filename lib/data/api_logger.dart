void logRequest({
  required String method,
  required String url,
  Map<String, String>? headers,
  dynamic body,
}) {
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📡 [$method] → $url');
  if (headers != null && headers.isNotEmpty) {
    print('🧾 Headers: $headers');
  }
  if (body != null) {
    print('📤 Body: $body');
  }
}

void logResponse({
  required int statusCode,
  required String url,
  required String body,
}) {
  print('📦 Response [$statusCode] ← $url');
  print('💬 Body: $body');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
