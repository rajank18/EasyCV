import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'E:/github/EasyCV/assets/images/logowithoutbg.png';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;

  final _slides = const [
    _OnboardSlide(
      icon: Icons.assignment_turned_in_outlined,
      title: 'Welcome to EasyCV',
      subtitle: 'Create ATS-friendly resumes with a simple form.',
    ),
    _OnboardSlide(
      icon: Icons.view_quilt_outlined,
      title: 'Amazing Templates',
      subtitle: 'Choose from multiple professional veryfied resume templates.',
    ),
    _OnboardSlide(
      icon: Icons.speed_outlined,
      title: 'ATS Score & Export',
      subtitle: 'Get your resume ATS score.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CarouselSlider.builder(
                carouselController: _controller,
                itemCount: _slides.length,
                itemBuilder: (context, index, realIdx) => _SlideView(slide: _slides[index]),
                options: CarouselOptions(
                  viewportFraction: 1.0,
                  height: double.infinity,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) => setState(() => _current = index),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(_slides.length, (i) {
                      final isActive = i == _current;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: isActive ? 20 : 8,
                        decoration: BoxDecoration(
                          color: isActive ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                  ),
                  if (_current < _slides.length - 1)
                    TextButton(
                      onPressed: () => _controller.nextPage(),
                      child: const Text('Next'),
                    )
                  else
                    FilledButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
                      child: const Text('Start'),
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
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardSlide({required this.icon, required this.title, required this.subtitle});
}

class _SlideView extends StatelessWidget {
  final _OnboardSlide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(slide.icon, size: 120, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
