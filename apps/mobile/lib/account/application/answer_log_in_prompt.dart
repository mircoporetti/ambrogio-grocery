import '../domain/log_in_prompt_port.dart';

class AnswerLogInPrompt {
  AnswerLogInPrompt(this._prompt);

  final LogInPromptPort _prompt;

  Future<void> call() => _prompt.markAnswered();
}
