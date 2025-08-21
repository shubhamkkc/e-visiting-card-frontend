import 'file_saver_stub.dart'
  if (dart.library.io) 'file_saver_io.dart'
  if (dart.library.html) 'file_saver_web.dart';

Future<void> saveBytes(String filename, List<int> bytes, {String mimeType = 'application/octet-stream'}) {
  return saveBytesImpl(filename, bytes, mimeType: mimeType);
}