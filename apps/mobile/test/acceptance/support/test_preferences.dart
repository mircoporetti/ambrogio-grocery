import 'package:ambrogio_grocery/account/data/shared_preferences_log_in_prompt_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

SharedPreferencesAsync inMemoryPreferences() {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  return SharedPreferencesAsync();
}

/// The prompt as on a phone where the user already answered it, so tests
/// that don't care about it start on the recipe list.
Future<SharedPreferencesLogInPromptAdapter> answeredLogInPrompt() async {
  final prompt = SharedPreferencesLogInPromptAdapter(inMemoryPreferences());
  await prompt.markAnswered();
  return prompt;
}
