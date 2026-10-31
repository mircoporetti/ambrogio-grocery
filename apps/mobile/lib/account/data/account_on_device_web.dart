import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/account_api_port.dart';
import '../domain/session_storage_port.dart';
import 'browser_session_adapter.dart';
import 'http_account_api_adapter.dart';
import 'web_lock_account_api_adapter.dart';

({AccountApiPort accountApi, SessionStoragePort sessionStorage})
accountOnDevice(Uri apiUrl, http.Client _) => (
  accountApi: WebLockAccountApiAdapter(
    HttpAccountApiAdapter(
      apiUrl,
      BrowserClient()..withCredentials = true,
      refreshInCookie: true,
    ),
  ),
  sessionStorage: BrowserSessionAdapter(SharedPreferencesAsync()),
);
