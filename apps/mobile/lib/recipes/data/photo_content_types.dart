import 'package:path/path.dart' as p;

const _contentTypes = {
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.heic': 'image/heic',
  '.webp': 'image/webp',
};

String photoContentTypeOf(String path) =>
    _contentTypes[p.extension(path).toLowerCase()] ??
    'application/octet-stream';

String photoExtensionFor(String contentType) =>
    _contentTypes.entries
        .where((type) => type.value == contentType)
        .firstOrNull
        ?.key ??
    '';
