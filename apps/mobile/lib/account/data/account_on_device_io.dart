import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../domain/account_api_port.dart';
import '../domain/session_storage_port.dart';
import 'http_account_api_adapter.dart';
import 'secure_storage_session_adapter.dart';

({AccountApiPort accountApi, SessionStoragePort sessionStorage})
accountOnDevice(Uri apiUrl, http.Client client) => (
  accountApi: HttpAccountApiAdapter(apiUrl, client),
  sessionStorage: SecureStorageSessionAdapter(const FlutterSecureStorage()),
);
