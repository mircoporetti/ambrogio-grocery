import 'json.dart';

String photoUploadUrlPath(String photoId) => '/photos/$photoId/upload-url';

String photoDownloadUrlPath(String photoId) => '/photos/$photoId/download-url';

class PhotoUploadUrlRequest {
  const PhotoUploadUrlRequest({
    required this.contentType,
    required this.contentLength,
  });

  factory PhotoUploadUrlRequest.fromJson(Object? json) {
    final object = asObject(json);
    return PhotoUploadUrlRequest(
      contentType: readString(object, 'contentType'),
      contentLength: readInt(object, 'contentLength'),
    );
  }

  final String contentType;
  final int contentLength;

  Map<String, Object?> toJson() => {
    'contentType': contentType,
    'contentLength': contentLength,
  };
}

class PresignedRequestResponse {
  PresignedRequestResponse({
    required this.method,
    required this.url,
    required this.headers,
    required DateTime expiresAt,
  }) : expiresAt = expiresAt.toUtc();

  factory PresignedRequestResponse.fromJson(Object? json) {
    final object = asObject(json);
    return PresignedRequestResponse(
      method: readString(object, 'method'),
      url: readString(object, 'url'),
      headers: {
        for (final MapEntry(:key, :value) in asObject(
          object['headers'],
        ).entries)
          key: switch (value) {
            final String value => value,
            _ => throw const FormatException('Expected string headers'),
          },
      },
      expiresAt: readUtcTime(object, 'expiresAt'),
    );
  }

  final String method;
  final String url;
  final Map<String, String> headers;
  final DateTime expiresAt;

  Map<String, Object?> toJson() => {
    'method': method,
    'url': url,
    'headers': headers,
    'expiresAt': expiresAt.toIso8601String(),
  };
}
