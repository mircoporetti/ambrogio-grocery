class PresignedRequest {
  PresignedRequest({
    required this.method,
    required this.url,
    required this.headers,
    required DateTime expiresAt,
  }) : expiresAt = expiresAt.toUtc();

  final String method;
  final Uri url;
  final Map<String, String> headers;
  final DateTime expiresAt;
}
