import 'package:ambrogio_grocery/account/domain/account_exceptions.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_file.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_id.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_sync_api_port.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_sync_exceptions.dart';

import 'fake_account_api_adapter.dart';

class FakePhotoSyncApiAdapter implements PhotoSyncApiPort {
  FakePhotoSyncApiAdapter(this._accounts);

  final FakeAccountApiAdapter _accounts;
  final _stored = <String, Map<PhotoId, PhotoFile>>{};
  bool unreachable = false;
  bool storageDown = false;
  bool rejectPhotos = false;
  Future<void> Function()? whileDownloading;
  var uploadAttempts = 0;

  void givenPhoto(String email, PhotoId id, List<int> bytes) =>
      _stored.putIfAbsent(email, () => {})[id] = PhotoFile(
        bytes: bytes,
        contentType: 'image/jpeg',
      );

  List<int>? photoOf(String email, PhotoId id) => _stored[email]?[id]?.bytes;

  int photoCountOf(String email) => _stored[email]?.length ?? 0;

  @override
  Future<void> upload(String accessToken, PhotoId id, PhotoFile file) async {
    final email = _authenticate(accessToken);
    uploadAttempts++;
    if (rejectPhotos) throw const PhotoRejectedException();
    if (storageDown) throw const PhotoTransferFailedException();
    _stored.putIfAbsent(email, () => {})[id] = file;
  }

  @override
  Future<PhotoFile?> download(String accessToken, PhotoId id) async {
    final email = _authenticate(accessToken);
    if (storageDown) throw const PhotoTransferFailedException();
    await whileDownloading?.call();
    return _stored[email]?[id];
  }

  String _authenticate(String accessToken) {
    if (unreachable) throw const SyncServerUnreachableException();
    return _accounts.emailFor(accessToken) ??
        (throw const AccessTokenRejectedException());
  }
}
