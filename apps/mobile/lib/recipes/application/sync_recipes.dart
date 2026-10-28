import 'dart:developer';

import '../../account/application/call_with_session.dart';
import '../../account/domain/account_exceptions.dart';
import '../domain/photo.dart';
import '../domain/photo_file.dart';
import '../domain/photo_id.dart';
import '../domain/photo_storage_port.dart';
import '../domain/photo_sync_api_port.dart';
import '../domain/recipe_change.dart';
import '../domain/recipe_sync_api_port.dart';
import '../domain/recipe_sync_exceptions.dart';
import '../domain/recipe_sync_storage_port.dart';

class SyncRecipes {
  SyncRecipes(
    this._storage,
    this._api,
    this._photoFiles,
    this._photoApi,
    this._callWithSession,
  );

  static const _pushBatch = 1000;

  final RecipeSyncStoragePort _storage;
  final RecipeSyncApiPort _api;
  final PhotoStoragePort _photoFiles;
  final PhotoSyncApiPort _photoApi;
  final CallWithSession _callWithSession;

  Future<void> call() async {
    try {
      await _callWithSession((accessToken) async {
        final notUploaded = await _uploadPhotos(accessToken);
        await _push(accessToken, notUploaded);
        await _pull(accessToken);
        await _downloadPhotos(accessToken);
      });
    } on RecipeSyncException catch (e, stackTrace) {
      log('Syncing recipes failed', error: e, stackTrace: stackTrace);
    } on AccountException catch (e, stackTrace) {
      log('Syncing recipes failed', error: e, stackTrace: stackTrace);
    }
  }

  Future<Set<PhotoId>> _uploadPhotos(String accessToken) async {
    final notUploaded = <PhotoId>{};
    for (final photo in await _storage.photosToUpload()) {
      final file = await _photoFiles.read(photo);
      try {
        if (file != null) await _photoApi.upload(accessToken, photo.id, file);
      } on PhotoRejectedException catch (e, stackTrace) {
        log('The server refused a photo', error: e, stackTrace: stackTrace);
      } on PhotoTransferFailedException catch (e, stackTrace) {
        log('Uploading a photo failed', error: e, stackTrace: stackTrace);
        notUploaded.add(photo.id);
        continue;
      }
      await _storage.stopUploadingPhoto(photo.id);
    }
    return notUploaded;
  }

  Future<void> _push(String accessToken, Set<PhotoId> notUploaded) async {
    // Other phones must never get a recipe whose photo isn't on the server.
    final pending = [
      for (final change in await _storage.pendingChanges())
        if (!notUploaded.contains(change.recipe?.photo?.id)) change,
    ];
    for (var start = 0; start < pending.length; start += _pushBatch) {
      final batch = pending.sublist(
        start,
        (start + _pushBatch).clamp(0, pending.length),
      );
      await _api.push(accessToken, batch);
      await _storage.markPushed(batch);
    }
  }

  Future<void> _pull(String accessToken) async {
    RecipeChangesPage page;
    do {
      page = await _api.pull(accessToken, since: await _storage.cursor());
      for (final photo in await _storage.applyPulled(page)) {
        await _deleteFile(photo);
      }
    } while (page.hasMore);
  }

  Future<void> _downloadPhotos(String accessToken) async {
    for (final id in await _storage.photosToDownload()) {
      final PhotoFile? file;
      try {
        file = await _photoApi.download(accessToken, id);
      } on PhotoTransferFailedException catch (e, stackTrace) {
        log('Downloading a photo failed', error: e, stackTrace: stackTrace);
        continue;
      }
      if (file == null) continue;
      final path = await _photoFiles.save(id, file);
      if (!await _storage.savePhotoPath(id, path)) {
        await _deleteFile(Photo(id: id, path: path));
      }
    }
  }

  Future<void> _deleteFile(Photo photo) async {
    try {
      await _photoFiles.delete(photo);
    } on Exception catch (e, stackTrace) {
      log('Deleting a photo failed', error: e, stackTrace: stackTrace);
    }
  }
}
