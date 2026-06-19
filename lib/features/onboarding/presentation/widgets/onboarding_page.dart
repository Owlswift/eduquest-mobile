import 'package:flutter/material.dart';
import '../../models/onboarding_model.dart';

class OnboardingPage extends StatefulWidget {
  final OnboardingModel page;

  const OnboardingPage({
    super.key,
    required this.page,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  late final Animation<double> fade;

  late final Animation<Offset> slide;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    fade = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );

    slide = Tween(
      begin: const Offset(0, .08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.page.accentColor;

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              //------------------------------------------------
              // Illustration Section
              //------------------------------------------------

              SizedBox(
                height: 340,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(.08),
                      ),
                    ),

                    Positioned(
                      top: 18,
                      right: 40,
                      child: _FloatingBubble(
                        icon: Icons.star_rounded,
                        color: Colors.orange,
                      ),
                    ),

                    Positioned(
                      left: 25,
                      top: 90,
                      child: _FloatingBubble(
                        icon: Icons.lightbulb,
                        color: Colors.amber,
                      ),
                    ),

                    Positioned(
                      bottom: 35,
                      right: 18,
                      child: _FloatingBubble(
                        icon: Icons.school,
                        color: accent,
                      ),
                    ),

                    Hero(
                      tag: widget.page.title,
                      child: Image.asset(
                        widget.page.illustration,
                        height: 270,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              //------------------------------------------------
              // Round Icon Badge
              //------------------------------------------------

              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(.08),
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Icon(
                  widget.page.icon,
                  size: 36,
                  color: accent,
                ),
              ),

              const SizedBox(height: 28),

              //------------------------------------------------
              // Title
              //------------------------------------------------

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 34,
                    color: Color(0xff1E293B),
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text: widget.page.title.replaceAll(
                        widget.page.highlighted,
                        "",
                      ),
                    ),
                    TextSpan(
                      text: widget.page.highlighted,
                      style: TextStyle(
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //------------------------------------------------
              // Description
              //------------------------------------------------

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  widget.page.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey.shade600,
                    height: 1.7,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingBubble extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _FloatingBubble({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -6, end: 6),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (_, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: child,
        );
      },
      onEnd: () {},
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              color: Colors.black.withOpacity(.08),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
    );
  }
}