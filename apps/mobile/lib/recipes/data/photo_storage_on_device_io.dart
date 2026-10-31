import 'package:path_provider/path_provider.dart';

import '../domain/photo_storage_port.dart';
import 'file_photo_storage_adapter.dart';

Future<({PhotoStoragePort photoStorage, String documentsDir})>
photoStorageOnDevice() async {
  final documents = await getApplicationDocumentsDirectory();
  return (
    photoStorage: FilePhotoStorageAdapter(documents.path),
    documentsDir: documents.path,
  );
}
