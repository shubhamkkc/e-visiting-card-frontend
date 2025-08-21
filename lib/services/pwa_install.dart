// Facade with conditional imports
import 'pwa_install_stub.dart'
  if (dart.library.html) 'pwa_install_web.dart';

class PwaInstall {
  static void init() => pwaInit();
  static bool get canInstall => pwaCanInstall();
  static Future<bool> prompt() => pwaPrompt();
}