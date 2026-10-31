import 'dart:developer';

import '../application/should_suggest_home_screen.dart';

class HomeScreenHintViewModel {
  HomeScreenHintViewModel(this._shouldSuggest);

  final ShouldSuggestHomeScreen _shouldSuggest;

  Future<bool> shouldSuggest() async {
    try {
      return await _shouldSuggest();
    } on Exception catch (e, stackTrace) {
      log('Checking the Home Screen failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
