import '../../accounts/domain/account_id.dart';
import '../../shared/domain/clock_port.dart';
import '../domain/photo_exceptions.dart';
import '../domain/photo_id.dart';
import '../domain/photo_storage_port.dart';
import '../domain/presigned_request.dart';

class GetPhotoDownloadUrl {
  GetPhotoDownloadUrl(this._photos, this._clock);

  final PhotoStoragePort _photos;
  final ClockPort _clock;

  Future<PresignedRequest> call(AccountId account, PhotoId photo) async {
    if (!await _photos.exists(account, photo)) {
      throw const PhotoNotFoundException();
    }
    return _photos.signDownload(account, photo, _clock.now());
  }
}
