import 'package:flutter/material.dart';
import '../../models/onboarding_model.dart';
import '../widgets/onboarding_page.dart';
import '../../../auth/presentation/pages/login_page.dart';

import '../../../../core/widgets/common/decorative_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<OnboardingModel> pages = [
    OnboardingModel(
      title: "Learn Smarter",
      highlighted: "Smarter",
      description:
          "Prepare for WAEC, JAMB and NECO with thousands of CBT questions and expert explanations.",
      illustration: "assets/illustrations/onboarding1.png",
      icon: Icons.menu_book_rounded,
      accentColor: const Color(0xff1D4ED8),
    ),
    OnboardingModel(
      title: "Track Progress",
      highlighted: "Progress",
      description:
          "See your strengths, monitor your performance and build unstoppable study streaks.",
      illustration: "assets/illustrations/onboarding2.png",
      icon: Icons.trending_up_rounded,
      accentColor: const Color(0xff10B981),
    ),
    OnboardingModel(
      title: "Compete & Win",
      highlighted: "Win",
      description:
          "Earn XP, unlock badges, climb the leaderboard and win amazing prizes like airtime, books and scholarships.",
      illustration: "assets/illustrations/onboarding3.png",
      icon: Icons.emoji_events_rounded,
      accentColor: const Color(0xffF59E0B),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void skip() {
    _pageController.animateToPage(
      pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = pages[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Stack(
          children: [
            /// Decorative Background
            DecorativeBackground(
              color: page.accentColor.withValues(alpha: 0.06),
            ),

            Column(
              children: [
                const SizedBox(height: 10),

                /// Skip Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: skip,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xff1D4ED8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,

                    physics: const BouncingScrollPhysics(),

                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },

                    itemCount: pages.length,

                    itemBuilder: (context, index) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        child: OnboardingPage(
                          key: ValueKey(index),
                          page: pages[index],
                        ),
                      );
                    },
                  ),
                ),

                /// Bottom Controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 10, 28, 34),

                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: List.generate(pages.length, (index) {
                          bool active = index == _currentPage;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: active ? 12 : 10,
                            height: active ? 12 : 10,
                            decoration: BoxDecoration(
                              color: active
                                  ? page.accentColor
                                  : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: nextPage,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2563EB,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == pages.length - 1
                                      ? "Get Started"
                                      : "Next",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
