import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../application/create_account.dart';
import '../application/log_in.dart';
import 'account_error.dart';

enum AccountFormMode { logIn, createAccount }

class LogInViewModel extends ChangeNotifier {
  LogInViewModel(this._logIn, this._createAccount);

  final LogIn _logIn;
  final CreateAccount _createAccount;

  AccountFormMode _mode = AccountFormMode.logIn;
  AccountFormMode get mode => _mode;

  bool _submitting = false;
  bool get submitting => _submitting;

  AccountError? _error;
  AccountError? get error => _error;

  void switchMode() {
    _mode = _mode == AccountFormMode.logIn
        ? AccountFormMode.createAccount
        : AccountFormMode.logIn;
    _error = null;
    notifyListeners();
  }

  /// Returns true when the user is logged in and the page can close.
  Future<bool> submit({required String email, required String password}) async {
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      switch (_mode) {
        case AccountFormMode.logIn:
          await _logIn(email: email, password: password);
        case AccountFormMode.createAccount:
          await _createAccount(email: email, password: password);
      }
      return true;
    } on Exception catch (e, stackTrace) {
      log('Logging in failed', error: e, stackTrace: stackTrace);
      _error = AccountError.from(e);
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
