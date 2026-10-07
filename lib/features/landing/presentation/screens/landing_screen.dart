import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/landing_header.dart';
import '../widgets/sections/hero_section.dart';
import '../widgets/sections/editor_mockup_section.dart';
import '../widgets/sections/features_section.dart';
import '../widgets/sections/genres_section.dart';
import '../widgets/sections/manifesto_section.dart';
import '../widgets/sections/donate_section.dart';
import '../widgets/sections/final_cta_section.dart';
import '../widgets/sections/footer_section.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _featuresKey = GlobalKey();
  final _genresKey = GlobalKey();
  final _manifestoKey = GlobalKey();
  final _donateKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header sticky
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              minHeight: 56,
              maxHeight: 56,
              child: LandingHeader(
                onStartPressed: () => context.go('/auth'),
                onFeaturesPressed: () => _scrollTo(_featuresKey),
                onGenresPressed: () => _scrollTo(_genresKey),
                onManifestoPressed: () => _scrollTo(_manifestoKey),
                onDonatePressed: () => _scrollTo(_donateKey),
              ),
            ),
          ),

          // Hero
          SliverToBoxAdapter(
            child: HeroSection(
              onStartPressed: () => context.go('/auth'),
              onSeeMorePressed: () => _scrollTo(_featuresKey),
            ),
          ),

          // Mockup del editor
          const SliverToBoxAdapter(
            child: EditorMockupSection(),
          ),

          // Features
          SliverToBoxAdapter(
            key: _featuresKey,
            child: const FeaturesSection(),
          ),

          // Géneros
          SliverToBoxAdapter(
            key: _genresKey,
            child: const GenresSection(),
          ),

          // Manifiesto
          SliverToBoxAdapter(
            key: _manifestoKey,
            child: const ManifestoSection(),
          ),

          // Apoyar
          SliverToBoxAdapter(
            key: _donateKey,
            child: const DonateSection(),
          ),

          // CTA final
          SliverToBoxAdapter(
            child: FinalCtaSection(onStartPressed: () {}),
          ),

          // Footer
          const SliverToBoxAdapter(
            child: FooterSection(),
          ),
        ],
      ),
    );
  }
}

/// Delegate para hacer el header pegajoso.
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.child != child;
  }
}