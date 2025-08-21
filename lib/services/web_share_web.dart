// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<bool> webShare({String? title, String? text, required String url}) async {
  final nav = (html.window.navigator as dynamic);
  try {
    if (nav.share != null) {
      await nav.share({
        if (title != null) 'title': title,
        if (text != null) 'text': text,
        'url': url,
      });
      return true;
    }
  } catch (_) {}
  return false;
}