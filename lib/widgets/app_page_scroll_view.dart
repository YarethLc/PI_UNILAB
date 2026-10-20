import 'package:flutter/material.dart';
import 'custom_footer.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;
    final bannerHeight = isDesktop ? 150.0 : 110.0;

    return Container(
      width: double.infinity,
      height: bannerHeight,
      color: const Color(0xFF050506),
      child: Image.asset(
        'assets/images/banner_sistemas.jpeg',
        width: double.infinity,
        height: bannerHeight,
        fit: BoxFit.fill,
        semanticLabel: 'Banner de la Facultad de Ingeniería de Sistemas',
      ),
    );
  }
}

class AppPageScrollView extends StatelessWidget {
  final Widget child;

  const AppPageScrollView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 960) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: child,
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: AppBanner()),
        SliverToBoxAdapter(child: child),
        const SliverToBoxAdapter(child: CustomFooter()),
      ],
    );
  }
}
