import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'vcard_saver_stub.dart'
  if (dart.library.io) 'vcard_saver_io.dart'
  if (dart.library.html) 'vcard_saver_web.dart';

class VCardService {
  static String buildVCard({
    required String ownerName,
    required String email,
    required String phone1,
    String? phone2,
    required String address,
    required String org,
  }) {
    String esc(String v) => v.replaceAll('\\', '\\\\').replaceAll(',', '\\,');
    final now = DateTime.now().toUtc().toIso8601String();
    final sb = StringBuffer()
      ..writeln('BEGIN:VCARD')
      ..writeln('VERSION:3.0')
      ..writeln('FN;CHARSET=UTF-8:${esc(ownerName)}')
      ..writeln('N;CHARSET=UTF-8:${esc(ownerName)};;;;')
      ..writeln('EMAIL;CHARSET=UTF-8;type=HOME,INTERNET:${esc(email)}')
      ..writeln('TEL;TYPE=CELL:${esc(phone1)}');
    if ((phone2 ?? '').trim().isNotEmpty) {
      sb.writeln('TEL;TYPE=WORK,VOICE:${esc(phone2!.trim())}');
    }
    sb
      ..writeln('TEL;TYPE=WORK,VOICE:')
      ..writeln('ADR;CHARSET=UTF-8;TYPE=WORK:;;${esc(address)};;;;')
      ..writeln('ORG;CHARSET=UTF-8:${esc(org)}')
      ..writeln('REV:$now')
      ..writeln('END:VCARD');
    return sb.toString();
  }

  static Future<void> saveVCard({
    required BuildContext context,
    required String filename,
    required String vcardContent,
  }) async {
    await saveVCardFile(filename, utf8.encode(vcardContent), context);
    if (!kIsWeb) {
      // On mobile Share sheet opens; on web it downloads directly.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact card ready. Import to Contacts.')),
      );
    }
  }
}