import '../domain/log_in_prompt_port.dart';
import '../domain/session_storage_port.dart';

class ShouldAskToLogIn {
  ShouldAskToLogIn(this._prompt, this._sessions);

  final LogInPromptPort _prompt;
  final SessionStoragePort _sessions;

  Future<bool> call() async =>
      !await _prompt.wasAnswered() && await _sessions.load() == null;
}
