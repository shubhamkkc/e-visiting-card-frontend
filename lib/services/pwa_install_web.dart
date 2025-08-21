// Web-only: handle beforeinstallprompt and show prompt on demand
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

dynamic _deferredPrompt;

void pwaInit() {
  // Listen once and stash the event
  html.window.addEventListener('beforeinstallprompt', (event) {
    try {
      // Prevent default mini-infobar
      (event as dynamic).preventDefault();
      _deferredPrompt ??= event;
    } catch (_) {}
  });
}

bool pwaCanInstall() => _deferredPrompt != null;

// Returns true if user accepted installation
Future<bool> pwaPrompt() async {
  final prompt = _deferredPrompt;
  if (prompt == null) return false;
  _deferredPrompt = null; // can only prompt once per capture
  try {
    final result = await (prompt as dynamic).prompt();
    // Some browsers expose a userChoice promise; try to await it
    final choice = await (prompt as dynamic).userChoice;
    final outcome = (choice?.outcome ?? '').toString().toLowerCase();
    return outcome == 'accepted';
  } catch (_) {
    return false;
  }
}