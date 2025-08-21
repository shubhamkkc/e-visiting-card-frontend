import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

Future<void> saveVCardFile(
  String filename,
  List<int> bytes,
  BuildContext context,
) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'text/vcard', name: filename)],
    text: 'Save to your contacts',
  );
}