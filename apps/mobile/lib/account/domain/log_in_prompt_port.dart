abstract interface class LogInPromptPort {
  Future<bool> wasAnswered();

  Future<void> markAnswered();
}
