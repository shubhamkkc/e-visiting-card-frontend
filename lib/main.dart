import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'constants.dart';
import 'providers/business_provider.dart';
import 'sections/home_section.dart';
import 'sections/about_section.dart';
import 'sections/products_section.dart';
import 'sections/gallery_section.dart';
import 'sections/feedback_section.dart';
import 'sections/enquiry_section.dart';
import 'sections/share_section.dart';
import 'services/pwa_install.dart';

void main() {
  PwaInstall.init(); // initialize install prompt capture on web
  runApp(const EVisitingCardApp());
}

class EVisitingCardApp extends StatelessWidget {
  const EVisitingCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BusinessProvider()..loadForCurrentUrl(),
      child: Consumer<BusinessProvider>(
        builder: (context, bp, _) {
          // Resolve primary color from API theme hex or fallback
          Color primary = AppConstants.primaryColor;
          final hex = bp.business?.primaryColorHex;
          if (hex != null && hex.isNotEmpty) {
            try {
              primary = Color(int.parse(hex.replaceFirst('#', '0xff')));
            } catch (_) {}
          }

          return MaterialApp(
            title: bp.business?.businessName ?? "businessName",
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: primary),
              useMaterial3: true,
            ),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ItemScrollController _scrollController = ItemScrollController();

  // NEW: controller + flags for scroll cues
  final ScrollController _navScrollController = ScrollController();
  bool _navCanScrollLeft = false;
  bool _navCanScrollRight = false;
  bool _showSwipeHint = true;

  @override
  void initState() {
    super.initState();
    _navScrollController.addListener(_updateNavScrollCues);
    // After first layout, update cues and auto-hide hint after a few seconds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNavScrollCues();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showSwipeHint = false);
      });
    });
  }

  void _updateNavScrollCues() {
    if (!_navScrollController.hasClients) return;
    final pos = _navScrollController.position;
    if (!pos.hasContentDimensions) return;
    final canLeft = pos.pixels > 0.0;
    final canRight = pos.pixels < (pos.maxScrollExtent - 1);
    if (canLeft != _navCanScrollLeft || canRight != _navCanScrollRight) {
      setState(() {
        _navCanScrollLeft = canLeft;
        _navCanScrollRight = canRight;
      });
    }
  }

  @override
  void dispose() {
    _navScrollController.dispose();
    super.dispose();
  }

  final List<Widget> _sections = const [
    HomeSection(),
    AboutSection(),
    ProductsSection(),
    GallerySection(),
    FeedbackSection(),
    EnquirySection(),
    ShareSection(),
  ];

  // ADD: nav items matching _sections order
  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home, label: "HOME"),
    _NavItem(icon: Icons.business_center, label: "ABOUT US"),
    _NavItem(icon: Icons.inventory, label: "PRODUCTS"),
    _NavItem(icon: Icons.image, label: "GALLERY"),
    _NavItem(icon: Icons.star, label: "FEEDBACK"),
    _NavItem(icon: Icons.contact_mail, label: "ENQUIRY"),
    _NavItem(icon: Icons.share, label: "SHARE"),
  ];

  int _selectedIndex = 0;

  void scrollToSection(int index) {
    setState(() => _selectedIndex = index);
    _scrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BusinessProvider>();
    if (bp.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (bp.error != null && bp.business == null) {
      return Scaffold(
        body: Center(child: Text("Failed to load: ${bp.error}")),
      );
    }

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            repeat: ImageRepeat.repeat,
            fit: BoxFit.none,
          ),
        ),
        child: ScrollablePositionedList.builder(
          itemCount: _sections.length,
          itemBuilder: (context, index) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 15),
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 500 ? 32 : 8,
                ),
                child: _sections[index],
              ),
            ),
          ),
          itemScrollController: _scrollController,
        ),
      ),
      // REPLACE: BottomNavigationBar -> scrollable but same look (icon above label)
      bottomNavigationBar: SafeArea(
        child: Material(
          elevation: 8,
          color: Theme.of(context).colorScheme.surface,
          child: SizedBox(
            height: 64,
            // Wrap in a Stack to add fades and a brief "Swipe" hint
            child: Stack(
              children: [
                // Scrollbar + scrollable row (same icons/labels as before)
                Scrollbar(
                  controller: _navScrollController,
                  thumbVisibility:
                      true, // show a small thumb to imply scrolling
                  child: SingleChildScrollView(
                    controller: _navScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: List.generate(_navItems.length, (i) {
                        final item = _navItems[i];
                        final selected = _selectedIndex == i;
                        final primary = Theme.of(context).colorScheme.primary;

                        return InkResponse(
                          radius: 28,
                          onTap: () {
                            setState(() => _showSwipeHint = false);
                            scrollToSection(i);
                          },
                          onHighlightChanged: (_) {
                            if (_showSwipeHint)
                              setState(() => _showSwipeHint = false);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 22,
                                  color: selected ? primary : Colors.black54,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow
                                      .visible, // keep full text, rely on scroll
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: selected ? primary : Colors.black54,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // LEFT fade (appears when there's content to the left)
                if (_navCanScrollLeft)
                  IgnorePointer(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Theme.of(context).colorScheme.surface,
                              Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // RIGHT fade (appears when there's content to the right)
                if (_navCanScrollRight)
                  IgnorePointer(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 48, // a bit wider so it's noticeable
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Color.fromARGB(
                                  115, 0, 0, 0), // semi-transparent black
                              Colors.transparent,
                            ],
                            stops: [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Brief “Swipe →” hint (auto-hides; hides on tap/scroll)
                if (_showSwipeHint && _navCanScrollRight)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AnimatedOpacity(
                            opacity: 0.85,
                            duration: const Duration(milliseconds: 250),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Swipe',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_right,
                                    color: Colors.black45),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
