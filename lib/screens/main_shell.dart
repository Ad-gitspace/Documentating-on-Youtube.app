import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/docs_nav_bar.dart';
import 'tabs/home_tab.dart';
import 'tabs/videos_tab.dart';
import 'tabs/account_tab.dart';

/// The main application shell after login.
///
/// Contains three tabs (Home · Videos · Account) managed by a
/// [PageView] and the floating [DocsNavBar].
///
/// Adapts to landscape by collapsing the nav bar and adjusting layout.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // ── Page Content ──────────────────────────────────────────────
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              children: const [
                HomeTab(),
                VideosTab(),
                AccountTab(),
              ],
            ),

            // ── Floating Docs Nav Bar ─────────────────────────────────────
            // In landscape, use a compact nav bar closer to the bottom edge
            // to avoid overlapping the limited vertical space.
            DocsNavBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              compact: isLandscape,
            ),
          ],
        ),
      ),
    );
  }
}
