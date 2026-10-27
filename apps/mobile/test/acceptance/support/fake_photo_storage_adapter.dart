import 'package:ambrogio_grocery/recipes/domain/photo.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_storage_port.dart';

class FakePhotoStorageAdapter implements PhotoStoragePort {
  final deleted = <String>[];

  @override
  Future<void> delete(Photo photo) async => deleted.add(photo.path!);
}
