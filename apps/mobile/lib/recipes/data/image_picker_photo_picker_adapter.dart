import 'package:image_picker/image_picker.dart';

import '../domain/photo_file.dart';
import '../domain/photo_picker_port.dart';
import 'photo_content_types.dart';

class ImagePickerPhotoPickerAdapter implements PhotoPickerPort {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<PhotoFile?> pick() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    if (image == null) return null;
    final bytes = await image.readAsBytes();
    if (bytes.isEmpty) return null;
    return PhotoFile(
      bytes: bytes,
      contentType: image.mimeType ?? photoContentTypeOf(image.path),
    );
  }
}
