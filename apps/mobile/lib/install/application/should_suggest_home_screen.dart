import '../domain/home_screen_port.dart';

class ShouldSuggestHomeScreen {
  ShouldSuggestHomeScreen(this._homeScreen);

  final HomeScreenPort _homeScreen;

  Future<bool> call() => _homeScreen.canBeAddedToHomeScreen();
}
