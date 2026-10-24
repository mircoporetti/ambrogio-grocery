import 'package:ambrogio_grocery/recipes/domain/photo_picker_port.dart';

class FakePhotoPickerAdapter implements PhotoPickerPort {
  String? nextPhoto;

  @override
  Future<String?> pick() async => nextPhoto;
}
