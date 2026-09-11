import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../../../auth/controllers/auth_controller.dart';
import 'dashboard_page.dart';
import 'subjects_page.dart';
import 'competitions_page.dart';
import 'rewards_page.dart';
import 'profile_page.dart';

class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({super.key});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  int _currentIndex = 0;

  final _pages = const [
    DashboardPage(),
    SubjectsPage(),
    CompetitionsPage(),
    RewardsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    final authState = ref.read(authControllerProvider);
    if (authState.token != null) {
      await ref.read(dashboardControllerProvider.notifier).loadUserProfile();
      final updatedAuthState = ref.read(authControllerProvider);
      final dashboardState = ref.read(dashboardControllerProvider);
      if (dashboardState.user == null && updatedAuthState.user == null) {
        await ref.read(authControllerProvider.notifier).logout();
      }
    }
  }

  void _onTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _EduQuestNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _EduQuestNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _EduQuestNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.menu_book_rounded, label: 'Learn'),
    _NavItem(
      icon: Icons.sports_martial_arts_rounded,
      assetPath: 'assets/illustrations/crossed_swords.png',
      label: 'Arena',
    ),
    _NavItem(icon: Icons.card_giftcard_rounded, label: 'Rewards'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = index == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withAlpha(30)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: item.assetPath != null
                            ? ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  isActive
                                      ? AppColors.primary
                                      : AppColors.subtitle,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  item.assetPath!,
                                  width: 24,
                                  height: 24,
                                ),
                              )
                            : Icon(
                                item.icon,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.subtitle,
                                size: 24,
                              ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.subtitle,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String? assetPath;
  final String label;
  const _NavItem({required this.icon, this.assetPath, required this.label});
}