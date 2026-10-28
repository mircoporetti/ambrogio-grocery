import 'dart:convert';

import 'package:ambrogio_grocery/recipes/domain/photo_file.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_picker_port.dart';

class FakePhotoPickerAdapter implements PhotoPickerPort {
  String? nextPhoto;

  static List<int> bytesOf(String photo) => utf8.encode('photo of $photo');

  @override
  Future<PhotoFile?> pick() async => switch (nextPhoto) {
    null => null,
    final photo => PhotoFile(bytes: bytesOf(photo), contentType: 'image/jpeg'),
  };
}
