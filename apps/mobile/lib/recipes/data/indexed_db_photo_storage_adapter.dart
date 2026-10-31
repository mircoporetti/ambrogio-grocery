import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../domain/photo.dart';
import '../domain/photo_file.dart';
import '../domain/photo_id.dart';
import '../domain/photo_storage_port.dart';
import 'photo_content_types.dart';

class IndexedDbPhotoStorageAdapter implements PhotoStoragePort {
  static const root = '/';
  static const _database = 'ambrogio_photos';
  static const _store = 'photos';

  static Future<web.IDBDatabase>? _opened;

  @override
  Future<PhotoFile?> read(Photo photo) async {
    final path = photo.path;
    return path == null ? null : readPath(path);
  }

  static Future<PhotoFile?> readPath(String path) async {
    final blob = await _request<web.Blob?>(
      'readonly',
      (store) => store.get(path.toJS),
    );
    if (blob == null || blob.size == 0) return null;
    final bytes = (await blob.arrayBuffer().toDart).toDart.asUint8List();
    return PhotoFile(
      bytes: bytes,
      contentType: blob.type.isEmpty ? photoContentTypeOf(path) : blob.type,
    );
  }

  @override
  Future<String> save(PhotoId id, PhotoFile file) async {
    final path =
        '${root}photos/${id.value}${photoExtensionFor(file.contentType)}';
    final blob = web.Blob(
      [Uint8List.fromList(file.bytes).toJS].toJS,
      web.BlobPropertyBag(type: file.contentType),
    );
    await _request<JSAny?>('readwrite', (store) => store.put(blob, path.toJS));
    return path;
  }

  @override
  Future<void> delete(Photo photo) async {
    final path = photo.path;
    if (path == null) return;
    await _request<JSAny?>('readwrite', (store) => store.delete(path.toJS));
  }

  static Future<T> _request<T extends JSAny?>(
    String mode,
    web.IDBRequest Function(web.IDBObjectStore store) send,
  ) async {
    final db = await (_opened ??= _open());
    final transaction = db.transaction(_store.toJS, mode);
    final request = send(transaction.objectStore(_store));
    final done = Completer<T>();
    transaction
      ..oncomplete = ((web.Event _) => done.complete(request.result as T)).toJS
      ..onerror = ((web.Event _) => done.completeError(
        StateError('IndexedDB: ${transaction.error?.message}'),
      )).toJS;
    return done.future;
  }

  static Future<web.IDBDatabase> _open() {
    final request = web.window.indexedDB.open(_database, 1);
    final opened = Completer<web.IDBDatabase>();
    request
      ..onupgradeneeded = ((web.Event _) {
        (request.result as web.IDBDatabase).createObjectStore(_store);
      }).toJS
      ..onsuccess = ((web.Event _) {
        opened.complete(request.result as web.IDBDatabase);
      }).toJS
      ..onerror = ((web.Event _) => opened.completeError(
        StateError('IndexedDB: ${request.error?.message}'),
      )).toJS;
    return opened.future;
  }
}
