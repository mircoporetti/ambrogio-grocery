import '../domain/account_api_port.dart';
import 'log_in.dart';

class CreateAccount {
  CreateAccount(this._api, this._logIn);

  final AccountApiPort _api;
  final LogIn _logIn;

  Future<void> call({required String email, required String password}) async {
    await _api.register(email: email, password: password);
    await _logIn(email: email, password: password);
  }
}
