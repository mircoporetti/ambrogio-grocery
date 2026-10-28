import '../../accounts/domain/account_id.dart';
import 'photo_id.dart';
import 'photo_upload.dart';
import 'presigned_request.dart';

abstract interface class PhotoStoragePort {
  PresignedRequest signUpload(
    AccountId account,
    PhotoId photo,
    PhotoUpload upload,
    DateTime now,
  );

  PresignedRequest signDownload(AccountId account, PhotoId photo, DateTime now);

  Future<bool> exists(AccountId account, PhotoId photo);

  Future<void> delete(AccountId account, PhotoId photo);
}
