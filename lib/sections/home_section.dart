import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/business_provider.dart';
import '../services/vcard_service.dart';
import '../services/pwa_install.dart';

class HomeSection extends StatelessWidget {
  const HomeSection({super.key});

  void _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BusinessProvider>();
    final currentViews = bp.views ?? bp.business?.views; // NEW
    final viewsText = currentViews?.toString() ?? '...'; // NEW

    final biz = bp.business;
    final name = biz?.businessName ?? "businessName";
    final tagline = biz?.tagline ?? "tagline";
    final owner = biz?.ownerName ?? "ownerName";
    final phone1 = biz?.phone1 ?? "phone1";
    final phone2 = biz?.phone2 ?? "phone2";
    final email = biz?.email ?? "email";
    final mapLink = biz?.googleMapLink ?? "googleMapLink";
    final whatsapp =
        (biz?.whatsappNumber ?? "whatsappNumber").replaceAll('+', '');

    // ADD THESE (used by the VCard button below)
    final ownerName = biz?.ownerName ?? "ownerName";
    final address = biz?.address ?? "address";
    final org = biz?.businessName ?? "businessName";

    // NEW: logo url from API (supports both logoUrl or logo fields)
    final logoUrl = (biz?.logoUrl ?? '').trim();

    return Center(
      child: Container(
        // constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.fromLTRB(0, 7, 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Views (dynamic)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.remove_red_eye,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text("Views: ",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                    viewsText, // NEW
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Logo
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  height: 80,
                  width: 120,
                  child: ClipRRect(
                    // ensures rounded corners apply to the image
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      logoUrl,
                      width: double.infinity, // expand to container
                      height: double.infinity, // expand to container
                      fit: BoxFit.fill, // fill nicely, may crop edges
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 32),
                    ),
                  ),
                )),
            // Business Name & Tagline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tagline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    biz?.ownerName ?? "ownerName",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const Text(
                    "(Owner)",
                    style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _ActionButton(
                    icon: Icons.call,
                    label: "Call",
                    onTap: () => _launchUrl("tel:$phone1"),
                  ),
                  _ActionButton(
                    icon: Icons.chat_bubble,
                    label: "Whatsapp",
                    onTap: () => _launchUrl("https://wa.me/$whatsapp"),
                  ),
                  _ActionButton(
                    icon: Icons.location_on,
                    label: "Direction",
                    onTap: () => _launchUrl(mapLink),
                  ),
                  _ActionButton(
                    icon: Icons.mail,
                    label: "Mail",
                    onTap: () => _launchUrl("mailto:$email"),
                  ),
                ],
              ),
            ),
            // Orange wave & info
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 24),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: const BorderRadius.only(
                  // bottomLeft: Radius.circular(16),
                  // bottomRight: Radius.circular(16),
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.location_on,
                    text: address, // uses DB value via BusinessProvider
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.email,
                    text: email,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.phone,
                    text: "$phone1\n$phone2",
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: _DownloadButton(
                            onTap: () async {
                              final vcf = VCardService.buildVCard(
                                ownerName: ownerName,
                                email: email,
                                phone1: phone1,
                                phone2: phone2.isEmpty ? null : phone2,
                                address: address,
                                org: org.isEmpty ? 'Business' : org,
                              );
                              final safeOrg = (org.isEmpty ? 'contact' : org)
                                  .replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '_');
                              final filename = '${safeOrg}_card.vcf';
                              await VCardService.saveVCard(
                                context: context,
                                filename: filename,
                                vcardContent: vcf,
                              );
                            },
                            icon: Icons.person_add,
                            label: "Add to Phone Book",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DownloadButton(
                            icon: Icons.cloud_download,
                            label: "Save Card",
                            onTap: () async {
                              if (PwaInstall.canInstall) {
                                final ok = await PwaInstall.prompt();
                                if (!ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Install dismissed.")),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Install not available. Open in Chrome/Edge and use 'Add to Home screen'.",
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Download Buttons (example)
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110, // Set your desired fixed width
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          elevation: 0,
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14),
          softWrap: true,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DownloadButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140, // Set your desired fixed width
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(221, 173, 86, 36),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          elevation: 0,
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14),
          softWrap: true,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
