import 'package:ambrogio_grocery/account/data/secure_storage_session_adapter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

SecureStorageSessionAdapter emptySecureStorage() {
  FlutterSecureStorage.setMockInitialValues({});
  return reopenedSecureStorage();
}

/// What the app opens after a restart: the same storage as before.
SecureStorageSessionAdapter reopenedSecureStorage() =>
    SecureStorageSessionAdapter(const FlutterSecureStorage());
