import '../../accounts/domain/account_id.dart';
import '../../shared/domain/clock_port.dart';
import '../domain/photo_id.dart';
import '../domain/photo_storage_port.dart';
import '../domain/photo_upload.dart';
import '../domain/presigned_request.dart';

class GetPhotoUploadUrl {
  GetPhotoUploadUrl(this._photos, this._clock);

  final PhotoStoragePort _photos;
  final ClockPort _clock;

  PresignedRequest call(AccountId account, PhotoId photo, PhotoUpload upload) =>
      _photos.signUpload(account, photo, upload, _clock.now());
}
