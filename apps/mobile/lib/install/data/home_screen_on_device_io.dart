import '../domain/home_screen_port.dart';

HomeScreenPort homeScreenOnDevice() => const InstalledAppHomeScreenAdapter();

class InstalledAppHomeScreenAdapter implements HomeScreenPort {
  const InstalledAppHomeScreenAdapter();

  @override
  Future<bool> canBeAddedToHomeScreen() async => false;
}
