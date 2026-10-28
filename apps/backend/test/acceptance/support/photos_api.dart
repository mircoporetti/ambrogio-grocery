import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'api_client.dart';

class PhotosApi {
  PhotosApi(this.api) {
    addTearDown(_storage.close);
  }

  final ApiClient api;
  final _storage = http.Client();

  Future<ApiResponse> uploadUrl(
    String? token,
    String photoId, {
    String contentType = 'image/jpeg',
    required int contentLength,
  }) => api.post('/photos/$photoId/upload-url', {
    'contentType': contentType,
    'contentLength': contentLength,
  }, token: token);

  Future<ApiResponse> downloadUrl(String? token, String photoId) =>
      api.get('/photos/$photoId/download-url', token: token);

  Future<http.Response> send(
    ApiResponse presigned, {
    List<int>? body,
    Uri? url,
    Map<String, String> headers = const {},
  }) async {
    final request = http.Request(
      presigned['method']! as String,
      url ?? Uri.parse(presigned['url']! as String),
    );
    final signed = (presigned['headers']! as Map).cast<String, String>();
    // The length comes from the body, so a longer body breaks the signature.
    request.headers.addAll({...signed, ...headers}..remove('content-length'));
    if (body != null) request.bodyBytes = body;
    return http.Response.fromStream(await _storage.send(request));
  }

  Future<void> upload(String token, String photoId, List<int> bytes) async {
    final url = await uploadUrl(token, photoId, contentLength: bytes.length);
    expect(url.status, 200, reason: 'upload URL for $photoId');
    final response = await send(url, body: bytes);
    expect(response.statusCode, 200, reason: 'upload of $photoId');
  }

  Future<List<int>?> download(String token, String photoId) async {
    final url = await downloadUrl(token, photoId);
    if (url.status == 404) return null;
    expect(url.status, 200, reason: 'download URL for $photoId');
    final response = await send(url);
    expect(response.statusCode, 200, reason: 'download of $photoId');
    return response.bodyBytes;
  }
}

const photoA = '6f1c8a52-3c1e-4f0a-9d47-1a2b3c4d5e6f';
const photoB = '7a2d9b63-4d2f-4a1b-8e58-2b3c4d5e6f70';

final jpegBytes = [0xFF, 0xD8, 0xFF, 0xE0, ...'pasta photo'.codeUnits];
final otherJpegBytes = [0xFF, 0xD8, 0xFF, 0xE0, ...'salad photo'.codeUnits];
