import '../domain/photo_storage_port.dart';
import 'indexed_db_photo_storage_adapter.dart';

Future<({PhotoStoragePort photoStorage, String documentsDir})>
photoStorageOnDevice() async => (
  photoStorage: IndexedDbPhotoStorageAdapter(),
  documentsDir: IndexedDbPhotoStorageAdapter.root,
);
