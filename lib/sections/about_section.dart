import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../constants.dart';
import '../widgets/section_title.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final biz = context.watch<BusinessProvider>().business;
    final name = biz?.businessName ?? "businessName";
    final tagline = biz?.tagline ?? "businessTagline";
    final year = biz?.establishedYear ?? "businessEstablishedYear";
    final nature = biz?.natureOfBusiness ?? "businessNatureOfBusiness";
    final specialities = biz?.specialities ?? "businessSpecialities";

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "About Us"),
          const SizedBox(height: 24),
          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FixedColumnWidth(10),
              2: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: [
              TableRow(children: [
                const _AboutLabel(label: "Company Name"),
                const Text(":",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("$name ($tagline)", style: const TextStyle(fontSize: 16)),
              ]),
              const TableRow(
                  children: [SizedBox(height: 16), SizedBox(), SizedBox()]),
              TableRow(children: [
                const _AboutLabel(label: "Year of Est."),
                const Text(":",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(year, style: const TextStyle(fontSize: 16)),
              ]),
              const TableRow(
                  children: [SizedBox(height: 16), SizedBox(), SizedBox()]),
              TableRow(children: [
                const _AboutLabel(label: "Nature Of Business"),
                const Text(":",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(nature, style: const TextStyle(fontSize: 16)),
              ]),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Our Specialities",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Text(specialities, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _AboutLabel extends StatelessWidget {
  final String label;
  const _AboutLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
  }
}
