import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/theme/app_animations.dart';
import '../../core/theme/app_theme.dart';
import '../login/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  final _slides = const [
    _OnboardSlide(title: 'Build resumes that feel premium.', subtitle: 'Elegant structure, ATS-ready output, and clean exports.', step: 'STEP 1 OF 3'),
    _OnboardSlide(title: 'Know your ATS score instantly.', subtitle: 'Scan your PDF, surface gaps, and improve with clear suggestions.', step: 'STEP 2 OF 3'),
    _OnboardSlide(title: 'Design once, apply everywhere.', subtitle: 'Use curated layouts and export confidently in one tap.', step: 'STEP 3 OF 3'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _slides.length - 1) {
      _controller.nextPage(duration: AppAnimations.dur400, curve: AppAnimations.smoothOut);
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed(LoginScreen.routeName),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _current = index),
                itemBuilder: (context, index) {
                  return _SlideView(
                    index: index,
                    slide: _slides[index],
                    isActive: index == _current,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _slides.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: AppColors.accent,
                      dotColor: AppColors.borderMid,
                      dotHeight: 6,
                      dotWidth: 6,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(_current == _slides.length - 1 ? 'Get Started' : 'Next'),
                    ),
                  ),
                ],
                ),
              ),
          ],
            ),
          
          
        ),
      );
  
  }
}

class _OnboardSlide {
  final String title;
  final String subtitle;
  final String step;

  const _OnboardSlide({
    required this.title,
    required this.subtitle,
    required this.step,
  });
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.index, required this.isActive});

  final int index;
  final _OnboardSlide slide;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: AppAnimations.dur400,
                switchInCurve: AppAnimations.smoothOut,
                switchOutCurve: AppAnimations.gentleFade,
                child: _illustration(context, index),
              ),
            ),
          ),
          Text(
            slide.step,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.accent,
                ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(duration: AppAnimations.dur300, delay: AppAnimations.dur100)
              .slideY(begin: 0.3, curve: AppAnimations.smoothOut),
          const SizedBox(height: 8),
          Text(
            slide.title,
            style: Theme.of(context).textTheme.displayMedium,
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(duration: AppAnimations.dur300, delay: AppAnimations.dur200)
              .slideY(begin: 0.2, curve: AppAnimations.smoothOut),
          const SizedBox(height: 10),
          Text(
            slide.subtitle,
            style: Theme.of(context).textTheme.bodyLarge,
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(duration: AppAnimations.dur300, delay: AppAnimations.dur300)
              .slideY(begin: 0.2, curve: AppAnimations.smoothOut),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _illustration(BuildContext context, int index) {
    if (index == 0) {
      return SizedBox(
        key: const ValueKey('bars'),
        width: 290,
        height: 230,
        child: CustomPaint(painter: _BarsPainter()),
      )
          .animate()
          .fadeIn(duration: AppAnimations.dur500)
          .scale(begin: const Offset(0.92, 0.92), curve: AppAnimations.easeOutBack);
    }
    if (index == 1) {
      return SizedBox(
        key: const ValueKey('score'),
        width: 290,
        height: 230,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 190,
              height: 190,
              decoration: const BoxDecoration(
                color: AppColors.bgSurfaceRaised,
                shape: BoxShape.circle,
              ),
            ),
            Positioned(
              right: 38,
              bottom: 22,
              child: Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 85),
              duration: AppAnimations.dur900,
              curve: AppAnimations.smoothOut,
              builder: (context, value, _) {
                return Text(
                  value.toInt().toString(),
                  style: AppText.monoLarge(AppColors.textPrimary).copyWith(fontSize: 48),
                );
              },
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: AppAnimations.dur500)
          .scale(begin: const Offset(0.92, 0.92), curve: AppAnimations.easeOutBack);
    }
    return SizedBox(
      key: const ValueKey('cards'),
      width: 290,
      height: 230,
      child: Stack(
        children: [
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, i) {
              final c = i.isEven ? AppColors.bgSurface : AppColors.bgSurfaceRaised;
              return Container(
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
              );
            },
          ),
          Center(
            child: Transform.rotate(
              angle: -math.pi / 8,
              child: Text(
                'EasyCV',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AppAnimations.dur500)
        .scale(begin: const Offset(0.92, 0.92), curve: AppAnimations.easeOutBack);
  }
}

class _BarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 90);
    canvas.translate(-center.dx, -center.dy);

    final r1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(44, 62, 200, 28),
      const Radius.circular(16),
    );
    final r2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(58, 102, 186, 28),
      const Radius.circular(16),
    );
    final r3 = RRect.fromRectAndRadius(
      Rect.fromLTWH(72, 142, 172, 28),
      const Radius.circular(16),
    );

    canvas.drawRRect(r1, Paint()..color = AppColors.accent);
    canvas.drawRRect(r2, Paint()..color = AppColors.accentTint);
    canvas.drawRRect(r3, Paint()..color = AppColors.borderSubtle);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
