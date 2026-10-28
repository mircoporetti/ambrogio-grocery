import 'photo_file.dart';

abstract interface class PhotoPickerPort {
  Future<PhotoFile?> pick();
}
