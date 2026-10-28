import 'dart:io';

import 'package:http/http.dart' as http;

import '../../accounts/domain/account_id.dart';
import '../domain/photo_id.dart';
import '../domain/photo_storage_port.dart';
import '../domain/photo_upload.dart';
import '../domain/presigned_request.dart';
import 's3_signer.dart';

class S3PhotoStorageAdapter implements PhotoStoragePort {
  S3PhotoStorageAdapter(
    this._signer, {
    required this.bucket,
    http.Client? client,
  }) : _http = client ?? http.Client();

  static const urlLifetime = Duration(minutes: 15);

  final S3Signer _signer;
  final String bucket;
  final http.Client _http;

  @override
  PresignedRequest signUpload(
    AccountId account,
    PhotoId photo,
    PhotoUpload upload,
    DateTime now,
  ) {
    final headers = {
      'content-type': upload.contentType,
      'content-length': '${upload.size}',
    };
    return PresignedRequest(
      method: 'PUT',
      url: _signer.presign(
        'PUT',
        _path(account, photo),
        now: now,
        expiresIn: urlLifetime,
        headers: headers,
      ),
      headers: headers,
      expiresAt: now.add(urlLifetime),
    );
  }

  @override
  PresignedRequest signDownload(
    AccountId account,
    PhotoId photo,
    DateTime now,
  ) => PresignedRequest(
    method: 'GET',
    url: _signer.presign(
      'GET',
      _path(account, photo),
      now: now,
      expiresIn: urlLifetime,
    ),
    headers: const {},
    expiresAt: now.add(urlLifetime),
  );

  @override
  Future<bool> exists(AccountId account, PhotoId photo) async {
    final response = await _http.head(_signed('HEAD', account, photo));
    return switch (response.statusCode) {
      200 => true,
      404 => false,
      final status => throw HttpException(
        'Photo storage answered $status to HEAD',
      ),
    };
  }

  @override
  Future<void> delete(AccountId account, PhotoId photo) async {
    final response = await _http.delete(_signed('DELETE', account, photo));
    if (response.statusCode >= 300) {
      throw HttpException(
        'Photo storage answered ${response.statusCode} to DELETE',
      );
    }
  }

  // The storage checks the signature time against its own clock.
  Uri _signed(String method, AccountId account, PhotoId photo) =>
      _signer.presign(
        method,
        _path(account, photo),
        now: DateTime.now(),
        expiresIn: const Duration(minutes: 1),
      );

  String _path(AccountId account, PhotoId photo) =>
      '/$bucket/accounts/${account.value}/photos/${photo.value}';

  void close() => _http.close();
}
