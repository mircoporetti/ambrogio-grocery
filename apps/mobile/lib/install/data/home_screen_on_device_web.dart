import '../domain/home_screen_port.dart';
import 'browser_home_screen_adapter.dart';

HomeScreenPort homeScreenOnDevice() => BrowserHomeScreenAdapter();
