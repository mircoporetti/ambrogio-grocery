import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ambrogio_api_contract/ambrogio_api_contract.dart';
import 'package:http/http.dart' as http;

import '../../account/domain/account_exceptions.dart';
import '../domain/photo_file.dart';
import '../domain/photo_id.dart';
import '../domain/photo_sync_api_port.dart';
import '../domain/recipe_sync_exceptions.dart';

class HttpPhotoSyncApiAdapter implements PhotoSyncApiPort {
  HttpPhotoSyncApiAdapter(this._baseUrl, this._client);

  final Uri _baseUrl;
  final http.Client _client;

  static const _apiTimeout = Duration(seconds: 30);
  static const _transferTimeout = Duration(minutes: 2);

  @override
  Future<void> upload(String accessToken, PhotoId id, PhotoFile file) async {
    final request =
        http.Request('POST', _baseUrl.resolve(photoUploadUrlPath(id.value)))
          ..headers['content-type'] = 'application/json'
          ..body = jsonEncode(
            PhotoUploadUrlRequest(
              contentType: file.contentType,
              contentLength: file.bytes.length,
            ).toJson(),
          );
    final presigned =
        await _presign(request, accessToken) ??
        (throw const UnexpectedSyncResponseException());
    final response = await _transfer(presigned, body: file.bytes);
    final status = response.statusCode;
    if (status >= 400 && status < 500) throw const PhotoRejectedException();
    if (status != 200) throw const PhotoTransferFailedException();
  }

  @override
  Future<PhotoFile?> download(String accessToken, PhotoId id) async {
    final presigned = await _presign(
      http.Request('GET', _baseUrl.resolve(photoDownloadUrlPath(id.value))),
      accessToken,
    );
    if (presigned == null) return null;
    final response = await _transfer(presigned);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      throw const PhotoTransferFailedException();
    }
    return PhotoFile(
      bytes: response.bodyBytes,
      contentType:
          response.headers['content-type'] ?? 'application/octet-stream',
    );
  }

  Future<PresignedRequestResponse?> _presign(
    http.Request request,
    String accessToken,
  ) async {
    request.headers
      ..['accept'] = 'application/json'
      ..['authorization'] = 'Bearer $accessToken';
    final response = await _send(request, _apiTimeout);
    switch (response.statusCode) {
      case 200:
        try {
          return PresignedRequestResponse.fromJson(jsonDecode(response.body));
        } on FormatException {
          throw const UnexpectedSyncResponseException();
        }
      case 401:
        throw const AccessTokenRejectedException();
      case 404:
        return null;
      case 400 || 413 || 415:
        throw const PhotoRejectedException();
      default:
        throw const UnexpectedSyncResponseException();
    }
  }

  Future<http.Response> _transfer(
    PresignedRequestResponse presigned, {
    List<int>? body,
  }) async {
    final Uri url;
    try {
      url = Uri.parse(presigned.url);
    } on FormatException {
      throw const UnexpectedSyncResponseException();
    }
    // http sets the length from the body; sending the signed one too would
    // repeat the header.
    final request = http.Request(presigned.method, url)
      ..headers.addAll({...presigned.headers}..remove('content-length'));
    if (body != null) request.bodyBytes = body;
    try {
      return await _send(request, _transferTimeout);
    } on SyncServerUnreachableException {
      throw const PhotoTransferFailedException();
    }
  }

  Future<http.Response> _send(http.Request request, Duration timeout) async {
    try {
      return await http.Response.fromStream(
        await _client.send(request),
      ).timeout(timeout);
    } on http.ClientException {
      throw const SyncServerUnreachableException();
    } on SocketException {
      throw const SyncServerUnreachableException();
    } on TimeoutException {
      throw const SyncServerUnreachableException();
    }
  }
}
