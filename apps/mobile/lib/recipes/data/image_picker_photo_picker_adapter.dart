import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/photo_picker_port.dart';

class ImagePickerPhotoPickerAdapter implements PhotoPickerPort {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pick() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
    );
    if (image == null) return null;

    final documents = await getApplicationDocumentsDirectory();
    final photos = Directory(p.join(documents.path, 'photos'));
    await photos.create(recursive: true);
    final target = p.join(
      photos.path,
      '${DateTime.now().microsecondsSinceEpoch}${p.extension(image.path)}',
    );
    await image.saveTo(target);
    return target;
  }
}
