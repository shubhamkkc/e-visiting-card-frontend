import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';

import '../services/file_saver.dart';
import '../providers/business_provider.dart';
import '../widgets/section_title.dart';

class ShareSection extends StatefulWidget {
  const ShareSection({super.key});

  @override
  State<ShareSection> createState() => _ShareSectionState();
}

class _ShareSectionState extends State<ShareSection> {
  final TextEditingController phoneController = TextEditingController();

  String _currentProfileUrl() {
    final biz = context.read<BusinessProvider>().business;
    final link = (biz?.profileUrl ?? '').trim();
    return link.isNotEmpty ? link : Uri.base.toString();
  }

  void _copyLink() {
    final link = _currentProfileUrl();
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Link copied to clipboard!")),
    );
  }

  // Share profile URL (web shows a quick chooser; mobile opens native share sheet)
  Future<void> _shareProfile() async {
    final link = _currentProfileUrl();

    if (kIsWeb) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: const Text('Share to WhatsApp'),
                onTap: () async {
                  final u = Uri.parse(
                      'https://wa.me/?text=${Uri.encodeComponent(link)}');
                  await launchUrl(u, webOnlyWindowName: '_blank');
                  if (mounted) Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.send, color: Colors.blueAccent),
                title: const Text('Share to Telegram'),
                onTap: () async {
                  final u = Uri.parse(
                      'https://t.me/share/url?url=${Uri.encodeComponent(link)}');
                  await launchUrl(u, webOnlyWindowName: '_blank');
                  if (mounted) Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sms, color: Colors.deepPurple),
                title: const Text('Share via SMS'),
                onTap: () async {
                  final u = Uri.parse('sms:?body=${Uri.encodeComponent(link)}');
                  await launchUrl(u);
                  if (mounted) Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy link'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: link));
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: const Text('Open link'),
                onTap: () async {
                  await launchUrl(Uri.parse(link), webOnlyWindowName: '_blank');
                  if (mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      );
      return;
    }

    await Share.share(link); // Android/iOS/Desktop: native share sheet
  }

  bool _looksLikeUrl(String v) {
    final s = v.trim().toLowerCase();
    return s.startsWith('http://') || s.startsWith('https://');
  }

  String _digitsOnly(String v) => v.replaceAll(RegExp(r'[^0-9]'), '');

  // Use an online QR generator for saving/downloading
  String _buildQrUrl(String data, {int size = 1024, int margin = 2}) {
    final d = Uri.encodeComponent(data);
    return 'https://api.qrserver.com/v1/create-qr-code/?size=${size}x$size&format=png&margin=$margin&data=$d';
  }

  // Download/save the QR PNG
  Future<void> _saveQr() async {
    try {
      final link = _currentProfileUrl();
      final qrUrl = _buildQrUrl(link, size: 1024);

      final resp = await http.get(Uri.parse(qrUrl));
      if (resp.statusCode != 200) {
        throw Exception('QR HTTP ${resp.statusCode}');
      }
      final bytes = resp.bodyBytes;
      final ts = DateTime.now().millisecondsSinceEpoch;

      if (kIsWeb) {
        // Browser download
        await saveBytes('profile_qr_$ts.png', bytes, mimeType: 'image/png');
      } else {
        // Save to Gallery (Android/iOS). If not supported, fallback to share/save.
        final res = await ImageGallerySaver.saveImage(
          bytes,
          quality: 100,
          name: 'profile_qr_$ts',
        );
        if (!(res is Map && res['isSuccess'] == true)) {
          await saveBytes('profile_qr_$ts.png', bytes, mimeType: 'image/png');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR saved/downloaded successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save QR: $e')),
        );
      }
    }
  }

  void _shareToWhatsApp() async {
    final input = phoneController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter a mobile number or paste a URL.")),
      );
      return;
    }

    // If user pasted a URL, share that URL to a new chat
    // Else treat input as phone number and send the profile URL to that number
    final String message = _looksLikeUrl(input) ? input : _currentProfileUrl();
    final String? phone = _looksLikeUrl(input) ? null : _digitsOnly(input);

    final encoded = Uri.encodeComponent(message);
    final Uri primary = phone == null || phone.isEmpty
        ? Uri.parse('https://wa.me/?text=$encoded')
        : Uri.parse('https://wa.me/$phone?text=$encoded');

    bool opened = await launchUrl(
      primary,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );

    if (!opened) {
      final Uri fallback = phone == null || phone.isEmpty
          ? Uri.parse('https://api.whatsapp.com/send?text=$encoded')
          : Uri.parse(
              'https://api.whatsapp.com/send?phone=$phone&text=$encoded');

      opened = await launchUrl(
        fallback,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    }

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
    } else if (opened && mounted) {
      phoneController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final biz = context.watch<BusinessProvider>().business;
    final profileUrl = (() {
      final link = (biz?.profileUrl ?? '').trim();
      return link.isNotEmpty ? link : Uri.base.toString();
    })();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Share"),
          const SizedBox(height: 16),
          // Profile link with copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    profileUrl,
                    style: const TextStyle(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.black54),
                  onPressed: _copyLink,
                  tooltip: "Copy link",
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Scan below QR to open profile:",
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: profileUrl,
                version: QrVersions.auto,
                size: 140,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text("Share"),
                  onPressed: _shareProfile, // UPDATED
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.save_alt),
                  label: const Text("Save QR"),
                  onPressed: _saveQr, // UPDATED
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            "Share profile to any whatsapp number:",
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(4)),
                ),
                child: const Text(
                  "🇮🇳",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: "Enter mobile number",
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.horizontal(right: Radius.circular(4)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text("Share"),
                onPressed: _shareToWhatsApp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
