// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';

Future<void> saveVCardFile(
  String filename,
  List<int> bytes,
  BuildContext context,
) async {
  final blob = html.Blob(<Uint8List>[Uint8List.fromList(bytes)], 'text/vcard');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}