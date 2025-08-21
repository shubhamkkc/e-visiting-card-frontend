// Non-web fallback (Android/iOS/Desktop builds)
bool pwaCanInstall() => false;
void pwaInit() {}
Future<bool> pwaPrompt() async => false;