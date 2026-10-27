import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../recipes/application/upload_pending_recipes.dart';
import '../application/log_out.dart';
import '../application/watch_session.dart';
import '../domain/session.dart';

class AccountViewModel extends ChangeNotifier {
  AccountViewModel(
    WatchSession watchSession,
    this._logOut,
    this._uploadPendingRecipes,
  ) {
    _subscription = watchSession().listen((session) {
      _session = session;
      _loading = false;
      notifyListeners();
    });
  }

  final LogOut _logOut;
  final UploadPendingRecipes _uploadPendingRecipes;
  late final StreamSubscription<Session?> _subscription;

  Session? _session;
  Session? get session => _session;

  bool _loading = true;
  bool get loading => _loading;

  Future<bool> logOut() async {
    if (!await _uploadPendingRecipes()) return false;
    await _logOut();
    return true;
  }

  Future<void> logOutAnyway() => _logOut();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
