import '../domain/photo.dart';
import '../domain/photo_id.dart';
import '../domain/photo_picker_port.dart';
import '../domain/photo_storage_port.dart';

class PickRecipePhoto {
  PickRecipePhoto(this._photoPicker, this._photos);

  final PhotoPickerPort _photoPicker;
  final PhotoStoragePort _photos;

  Future<Photo?> call() async {
    final file = await _photoPicker.pick();
    if (file == null) return null;
    final id = PhotoId.generate();
    return Photo(id: id, path: await _photos.save(id, file));
  }
}
