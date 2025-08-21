import 'web_share_stub.dart'
  if (dart.library.html) 'web_share_web.dart';

Future<bool> tryWebShare({String? title, String? text, required String url}) {
  return webShare(title: title, text: text, url: url);
}