import 'package:shared_preferences/shared_preferences.dart';

import '../domain/log_in_prompt_port.dart';

class SharedPreferencesLogInPromptAdapter implements LogInPromptPort {
  SharedPreferencesLogInPromptAdapter(this._preferences);

  static const _key = 'logInPromptAnswered';

  final SharedPreferencesAsync _preferences;

  @override
  Future<bool> wasAnswered() async => await _preferences.getBool(_key) ?? false;

  @override
  Future<void> markAnswered() => _preferences.setBool(_key, true);
}
