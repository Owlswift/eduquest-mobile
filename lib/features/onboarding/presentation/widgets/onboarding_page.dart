import 'package:flutter/material.dart';
import '../../models/onboarding_model.dart';
import '../../../../core/widgets/animations/floating_bubble.dart';

class OnboardingPage extends StatefulWidget {
  final OnboardingModel page;

  const OnboardingPage({super.key, required this.page});

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

    fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);

    slide = Tween(
      begin: const Offset(0, .08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

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
              const Spacer(flex: 3),

              //------------------------------------------------
              // Illustration Section
              //------------------------------------------------
              SizedBox(
                height: 360,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.08),
                      ),
                    ),

                    Positioned(
                      top: 18,
                      right: 40,
                      child: FloatingBubble(
                        icon: Icons.star_rounded,
                        color: Colors.orange,
                        phase: 0,
                      ),
                    ),

                    Positioned(
                      left: 25,
                      top: 90,
                      child: FloatingBubble(
                        icon: Icons.lightbulb,
                        color: Colors.amber,
                        phase: 0.3,
                      ),
                    ),

                    Positioned(
                      bottom: 35,
                      right: 18,
                      child: FloatingBubble(
                        icon: Icons.school,
                        color: accent,
                        phase: 0.7,
                      ),
                    ),

                    Hero(
                      tag: widget.page.title,
                      child: Transform.scale(
                        scale: 2,
                        child: Image.asset(widget.page.illustration),
                      ),
                    ),
                    // Hero(
                    //   tag: widget.page.title,
                    //   child: Image.asset(
                    //     widget.page.illustration,
                    //     height: 270,
                    //     fit: BoxFit.contain,
                    //   ),
                    // ),
                  ],
                ),
              ),

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
                      color: Colors.black.withValues(alpha: 0.08),
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(widget.page.icon, size: 36, color: accent),
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
                      style: TextStyle(color: accent),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //------------------------------------------------
              // Description
              //------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
