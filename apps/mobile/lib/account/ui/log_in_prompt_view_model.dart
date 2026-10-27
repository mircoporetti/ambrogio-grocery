import 'dart:developer';

import '../application/answer_log_in_prompt.dart';
import '../application/should_ask_to_log_in.dart';

class LogInPromptViewModel {
  LogInPromptViewModel(this._shouldAsk, this._answer);

  final ShouldAskToLogIn _shouldAsk;
  final AnswerLogInPrompt _answer;

  Future<bool> shouldAsk() async {
    try {
      return await _shouldAsk();
    } on Exception catch (e, stackTrace) {
      log(
        'Checking the log-in prompt failed',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> answered() async {
    try {
      await _answer();
    } on Exception catch (e, stackTrace) {
      log('Saving the log-in prompt failed', error: e, stackTrace: stackTrace);
    }
  }
}
