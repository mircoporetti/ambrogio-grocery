import '../domain/photo_picker_port.dart';

class PickRecipePhoto {
  PickRecipePhoto(this._photoPicker);

  final PhotoPickerPort _photoPicker;

  Future<String?> call() => _photoPicker.pick();
}
