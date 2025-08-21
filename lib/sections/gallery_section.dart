import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../widgets/section_title.dart';
import '../providers/business_provider.dart';

class GallerySection extends StatelessWidget {
  const GallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    final biz = context.watch<BusinessProvider>().business;
    final images = (biz?.galleryImages != null && biz!.galleryImages.isNotEmpty)
        ? biz.galleryImages
        : AppConstants.galleryImages;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Stack(
        children: [
          // Orange corners
          Positioned(top: 0, left: 0, child: _corner()),
          Positioned(top: 0, right: 0, child: _corner()),
          Positioned(bottom: 0, left: 0, child: _corner()),
          Positioned(bottom: 0, right: 0, child: _corner()),
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: "Gallery"),
              const SizedBox(height: 20),
              if (images.isEmpty)
                const Text("No images yet.")
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: images.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1, // square tiles
                  ),
                  itemBuilder: (context, index) {
                    final src = images[index].toString().trim();
                    final isUrl = src.startsWith('http') || src.startsWith('data:');

                    final imageWidget = isUrl
                        ? Image.network(
                            src,
                            fit: BoxFit.contain, // no crop
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                            loadingBuilder: (c, w, p) =>
                                p == null ? w : const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : Image.asset(
                            src,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          );

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: const Color(0xFFF5F5F5),
                        alignment: Alignment.center,
                        child: imageWidget,
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _corner() => Container(width: 40, height: 8, color: Colors.orange);
}
