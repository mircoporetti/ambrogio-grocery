import 'dart:convert';

import 'package:ambrogio_grocery/account/domain/account_exceptions.dart';
import 'package:ambrogio_grocery/recipes/data/http_photo_sync_api_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_file.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_id.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_sync_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final baseUrl = Uri.parse('http://api.test:8080');
  final photoId = PhotoId('6f1c8a52-3c1e-4f0a-9d47-1a2b3c4d5e6f');
  final bytes = utf8.encode('jpeg bytes');
  const storageUrl = 'http://storage.test/photos/abc?X-Amz-Signature=sig';

  http.Response presigned(String method, {Map<String, String>? headers}) =>
      http.Response(
        jsonEncode({
          'method': method,
          'url': storageUrl,
          'headers': headers ?? <String, String>{},
          'expiresAt': '2026-10-20T09:15:00.000Z',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );

  test('uploads the photo with the request the backend signed', () async {
    final sent = <http.Request>[];
    final api = HttpPhotoSyncApiAdapter(
      baseUrl,
      MockClient((request) async {
        sent.add(request);
        return request.url.host == 'api.test'
            ? presigned(
                'PUT',
                headers: {
                  'content-type': 'image/jpeg',
                  'content-length': '${bytes.length}',
                },
              )
            : http.Response('', 200);
      }),
    );

    await api.upload(
      'the-access',
      photoId,
      PhotoFile(bytes: bytes, contentType: 'image/jpeg'),
    );

    final [sign, put] = sent;
    expect(sign.method, 'POST');
    expect(
      sign.url.toString(),
      'http://api.test:8080/photos/${photoId.value}/upload-url',
    );
    expect(sign.headers['authorization'], 'Bearer the-access');
    expect(jsonDecode(sign.body), {
      'contentType': 'image/jpeg',
      'contentLength': bytes.length,
    });
    expect(put.method, 'PUT');
    expect(put.url.toString(), storageUrl);
    expect(put.headers['content-type'], 'image/jpeg');
    expect(put.headers.containsKey('authorization'), isFalse);
    expect(put.bodyBytes, bytes);
  });

  test('downloads the photo from the URL the backend signed', () async {
    final sent = <http.Request>[];
    final api = HttpPhotoSyncApiAdapter(
      baseUrl,
      MockClient((request) async {
        sent.add(request);
        return request.url.host == 'api.test'
            ? presigned('GET')
            : http.Response.bytes(
                bytes,
                200,
                headers: {'content-type': 'image/png'},
              );
      }),
    );

    final file = await api.download('the-access', photoId);

    expect(file!.bytes, bytes);
    expect(file.contentType, 'image/png');
    expect(
      sent.first.url.toString(),
      'http://api.test:8080/photos/${photoId.value}/download-url',
    );
    expect(sent.last.url.toString(), storageUrl);
  });

  test('a photo the backend does not have is no photo', () async {
    final api = HttpPhotoSyncApiAdapter(
      baseUrl,
      MockClient(
        (_) async => http.Response('{"error":"photo_not_found"}', 404),
      ),
    );

    expect(await api.download('the-access', photoId), isNull);
  });

  test('reads the answers that stop a photo', () async {
    Future<void> uploadAnswered(int status) => HttpPhotoSyncApiAdapter(
      baseUrl,
      MockClient((_) async => http.Response('{"error":"x"}', status)),
    ).upload('a', photoId, PhotoFile(bytes: bytes, contentType: 'image/jpeg'));

    await expectLater(
      uploadAnswered(401),
      throwsA(isA<AccessTokenRejectedException>()),
    );
    for (final status in [413, 415]) {
      await expectLater(
        uploadAnswered(status),
        throwsA(isA<PhotoRejectedException>()),
      );
    }
    await expectLater(
      uploadAnswered(500),
      throwsA(isA<UnexpectedSyncResponseException>()),
    );
  });

  test('a storage that refuses the upload refuses the photo, one that fails '
      'only fails this transfer', () async {
    Future<void> uploadWithStorage(Future<http.Response> Function() storage) =>
        HttpPhotoSyncApiAdapter(
          baseUrl,
          MockClient(
            (request) async =>
                request.url.host == 'api.test' ? presigned('PUT') : storage(),
          ),
        ).upload(
          'a',
          photoId,
          PhotoFile(bytes: bytes, contentType: 'image/jpeg'),
        );

    await expectLater(
      uploadWithStorage(() async => http.Response('', 403)),
      throwsA(isA<PhotoRejectedException>()),
    );
    await expectLater(
      uploadWithStorage(() async => http.Response('', 503)),
      throwsA(isA<PhotoTransferFailedException>()),
    );
    await expectLater(
      uploadWithStorage(() async => throw http.ClientException('offline')),
      throwsA(isA<PhotoTransferFailedException>()),
    );
  });

  test('no connection means the server is unreachable', () async {
    final api = HttpPhotoSyncApiAdapter(
      baseUrl,
      MockClient((_) async => throw http.ClientException('offline')),
    );

    await expectLater(
      api.download('a', photoId),
      throwsA(isA<SyncServerUnreachableException>()),
    );
  });
}
