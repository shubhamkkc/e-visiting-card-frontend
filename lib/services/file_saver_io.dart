import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveBytesImpl(String filename, List<int> bytes, {String mimeType = 'application/octet-stream'}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  // Share the file so user can Save/Copy to Photos/Files
  await Share.shareXFiles([XFile(file.path, mimeType: mimeType, name: filename)]);
}