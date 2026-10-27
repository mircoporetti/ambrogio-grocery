import '../domain/photo.dart';
import '../domain/photo_picker_port.dart';

class PickRecipePhoto {
  PickRecipePhoto(this._photoPicker);

  final PhotoPickerPort _photoPicker;

  Future<Photo?> call() async {
    final path = await _photoPicker.pick();
    return path == null ? null : Photo(path: path);
  }
}
