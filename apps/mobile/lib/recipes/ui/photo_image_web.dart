import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../data/indexed_db_photo_storage_adapter.dart';

ImageProvider photoImage(String path) => _StoredPhotoImage(path);

class _StoredPhotoImage extends ImageProvider<_StoredPhotoImage> {
  const _StoredPhotoImage(this.path);

  final String path;

  @override
  Future<_StoredPhotoImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _StoredPhotoImage key,
    ImageDecoderCallback decode,
  ) => MultiFrameImageStreamCompleter(codec: _load(decode), scale: 1);

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final photo = await IndexedDbPhotoStorageAdapter.readPath(path);
    if (photo == null) throw StateError('No photo stored at $path');
    return decode(
      await ui.ImmutableBuffer.fromUint8List(Uint8List.fromList(photo.bytes)),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _StoredPhotoImage && other.path == path;

  @override
  int get hashCode => path.hashCode;
}
