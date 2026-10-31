import 'package:ambrogio_grocery/install/domain/home_screen_port.dart';

class FakeHomeScreenAdapter implements HomeScreenPort {
  FakeHomeScreenAdapter({required this.inIphoneBrowserTab});

  final bool inIphoneBrowserTab;

  @override
  Future<bool> canBeAddedToHomeScreen() async => inIphoneBrowserTab;
}
