import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../widgets/section_title.dart';

class ProductsSection extends StatelessWidget {
  const ProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final products =
        context.watch<BusinessProvider>().business?.products ?? const [];
    if (products.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Products / Services"),
          const SizedBox(height: 20),
          ...products.map((p) {
            final src = p.image;
            final isUrl = src.startsWith('http') || src.startsWith('data:');

            final imageWidget = isUrl
                ? Image.network(
                    src,
                    fit: BoxFit.contain, // no crop
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                    loadingBuilder: (c, w, progress) => progress == null
                        ? w
                        : const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : Image.asset(
                    src,
                    fit: BoxFit.contain, // no crop
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                  );

            return Container(
              margin: const EdgeInsets.only(bottom: 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFDEDE3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 16),
                  // Letterboxed container so full image is visible
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      color: const Color(0xFFFDEDE3),
                      alignment: Alignment.center,
                      child: imageWidget,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
