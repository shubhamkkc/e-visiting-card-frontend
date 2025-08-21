import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../widgets/section_title.dart';
import '../providers/business_provider.dart';
import '../constants.dart';

class EnquirySection extends StatefulWidget {
  const EnquirySection({super.key});

  @override
  State<EnquirySection> createState() => _EnquirySectionState();
}

class _EnquirySectionState extends State<EnquirySection> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // Clean phone to digits for wa.me format
  String _cleanPhone(String raw) => raw.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _openWhatsApp() async {
    final name = nameController.text.trim();
    final msg = messageController.text.trim();

    if (name.isEmpty || msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name and message')),
      );
      return;
    }

    final biz = context.read<BusinessProvider>().business;
    final target = (biz?.whatsappNumber ?? AppConstants.whatsappNumber).trim();
    final phone = _cleanPhone(target);

    final text = 'Name: $name\n\nMessage: $msg';
    final encoded = Uri.encodeComponent(text);

    final url = phone.isNotEmpty
        ? Uri.parse('https://wa.me/$phone?text=$encoded')
        : Uri.parse('https://wa.me/?text=$encoded');

    bool opened = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );

    if (!opened && mounted) {
      final fallback = phone.isNotEmpty
          ? Uri.parse('https://api.whatsapp.com/send?phone=$phone&text=$encoded')
          : Uri.parse('https://api.whatsapp.com/send?text=$encoded');

      opened = await launchUrl(
        fallback,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }

    if (opened && mounted) {
      // Clear inputs after successful open
      nameController.clear();
      messageController.clear();
      FocusScope.of(context).unfocus();
      // Optional: feedback
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening WhatsApp...')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Enquiry Form"),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Your Name"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: messageController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: "Your Message"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _openWhatsApp,
            child: const Text("Send Enquiry on WhatsApp"),
          ),
        ],
      ),
    );
  }
}
