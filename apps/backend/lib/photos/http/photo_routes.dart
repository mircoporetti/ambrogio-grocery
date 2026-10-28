import 'dart:convert';

import 'package:ambrogio_api_contract/ambrogio_api_contract.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../accounts/application/authenticate.dart';
import '../../accounts/domain/account_exceptions.dart';
import '../../http/json.dart';
import '../application/get_photo_download_url.dart';
import '../application/get_photo_upload_url.dart';
import '../domain/photo_exceptions.dart';
import '../domain/photo_id.dart';
import '../domain/photo_upload.dart';
import '../domain/presigned_request.dart';

class PhotoRoutes {
  PhotoRoutes(this._authenticate, this._uploadUrl, this._downloadUrl);

  final Authenticate _authenticate;
  final GetPhotoUploadUrl _uploadUrl;
  final GetPhotoDownloadUrl _downloadUrl;

  Router get router => Router()
    ..post(photoUploadUrlPath('<photoId>'), _guard(_signUpload))
    ..get(photoDownloadUrlPath('<photoId>'), _guard(_signDownload));

  Future<Response> _signUpload(Request request) async {
    final account = _authenticate(bearerToken(request));
    final photo = _photoId(request);
    final body = PhotoUploadUrlRequest.fromJson(
      jsonDecode(await request.readAsString()),
    );
    final upload = _parse(
      () =>
          PhotoUpload(contentType: body.contentType, size: body.contentLength),
    );
    return _presigned(_uploadUrl(account, photo, upload));
  }

  Future<Response> _signDownload(Request request) async {
    final account = _authenticate(bearerToken(request));
    return _presigned(await _downloadUrl(account, _photoId(request)));
  }

  PhotoId _photoId(Request request) =>
      _parse(() => PhotoId(request.params['photoId']!));

  Response _presigned(PresignedRequest presigned) => jsonResponse(
    200,
    PresignedRequestResponse(
      method: presigned.method,
      url: presigned.url.toString(),
      headers: presigned.headers,
      expiresAt: presigned.expiresAt,
    ).toJson(),
  );

  T _parse<T>(T Function() create) {
    try {
      return create();
    } on ArgumentError {
      throw const InvalidRequestException();
    }
  }

  Handler _guard(Handler handler) => (request) async {
    try {
      return await handler(request);
    } on FormatException {
      return errorResponse(400, ErrorCodes.invalidRequest);
    } on InvalidRequestException {
      return errorResponse(400, ErrorCodes.invalidRequest);
    } on NotAuthenticatedException {
      return errorResponse(
        401,
        ErrorCodes.unauthorized,
        headers: {'www-authenticate': 'Bearer'},
      );
    } on PhotoException catch (e) {
      return switch (e) {
        PhotoNotFoundException() => errorResponse(
          404,
          ErrorCodes.photoNotFound,
        ),
        PhotoTooLargeException() => errorResponse(
          413,
          ErrorCodes.photoTooLarge,
        ),
        UnsupportedPhotoTypeException() => errorResponse(
          415,
          ErrorCodes.unsupportedPhotoType,
        ),
      };
    }
  };
}
