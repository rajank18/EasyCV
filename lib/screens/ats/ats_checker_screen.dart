import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_animations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../services/ats_scorer.dart';
import '../../services/ats_service.dart';

class ATSCheckerScreen extends StatefulWidget {
  const ATSCheckerScreen({super.key});

  static const routeName = '/ats-checker';

  @override
  State<ATSCheckerScreen> createState() => _ATSCheckerScreenState();
}

class _ATSCheckerScreenState extends State<ATSCheckerScreen> {
  final TextEditingController _jobDescController = TextEditingController();

  ATSResult? _result;
  String? _fileName;
  Uint8List? _fileBytes;
  bool _isAnalyzing = false;
  int _selectedIndex = 1;

  @override
  void dispose() {
    _jobDescController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (picked == null || picked.files.isEmpty) {
      return;
    }

    final selected = picked.files.single;
    final bytes = selected.bytes;
    if (bytes == null || bytes.isEmpty) {
      return;
    }

    setState(() {
      _fileName = selected.name;
      _fileBytes = bytes;
      _result = null;
    });
  }

  Future<void> _analyze() async {
    if (_fileBytes == null) return;

    setState(() => _isAnalyzing = true);
    try {
      final result = await ATSService.scoreFromBytes(
        _fileBytes!,
        jobDescription: _jobDescController.text.trim().isEmpty ? null : _jobDescController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ATS analysis failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _handleBottomNav(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/profile-info');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/settings');
    }

    setState(() => _selectedIndex = index);
  }

  Color _scoreColor(int score) {
    if (score >= 70) return AppColors.success;
    if (score >= 40) return AppColors.warning;
    return AppColors.danger;
  }

  Color _scoreTint(int score) {
    if (score >= 70) return AppColors.successTint;
    if (score >= 40) return AppColors.warningTint;
    return AppColors.dangerTint;
  }

  @override
  Widget build(BuildContext context) {
    final score = _result?.totalScore ?? 0;
    final color = _scoreColor(score);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text('ATS Checker', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              PressableScale(
                onTap: _pickResume,
                child: AnimatedContainer(
                  duration: AppAnimations.dur200,
                  curve: AppAnimations.gentleFade,
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.radiusXl),
                    border: Border.all(
                      color: _fileName == null ? AppColors.borderMid : AppColors.accent,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: _fileName == null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.upload_file_outlined, size: 32, color: AppColors.textTertiary),
                                  const SizedBox(height: 12),
                                  Text('Upload Resume PDF', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
                                  Text('Tap to browse - PDF only', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.task_alt, size: 28, color: AppColors.success),
                                  const SizedBox(height: 10),
                                  Text(
                                    _fileName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text('Ready to analyze', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              )
                                .animate()
                                .fadeIn(duration: AppAnimations.dur300)
                                .scale(begin: const Offset(0.8, 0.8), curve: AppAnimations.springSnappy),
                      ),
                      if (_fileName != null)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _fileName = null;
                                _fileBytes = null;
                                _result = null;
                              });
                            },
                            icon: const Icon(Icons.close, color: AppColors.textTertiary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _jobDescController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Job Description (Optional)',
                  hintText: 'Paste JD for better keyword matching',
                ),
              ),
              const SizedBox(height: 24),
              PressableScale(
                onTap: _fileBytes != null && !_isAnalyzing ? _analyze : null,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _fileBytes != null && !_isAnalyzing ? _analyze : null,
                    child: _isAnalyzing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 8),
                              Text('Analyzing...'),
                            ],
                          )
                        : const Text('Analyze Resume'),
                  ),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 22),
                AnimatedContainer(
                  duration: AppAnimations.dur500,
                  curve: AppAnimations.smoothOut,
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: _scoreTint(score),
                    borderRadius: BorderRadius.circular(AppRadius.radiusXl),
                    border: Border.all(color: color),
                    boxShadow: AppShadows.shadowMd,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: score / 100),
                          duration: AppAnimations.dur900,
                          curve: AppAnimations.smoothOut,
                          builder: (context, value, _) {
                            return CustomPaint(
                              painter: _RingPainter(progress: value, color: color),
                            );
                          },
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: score.toDouble()),
                            duration: AppAnimations.dur900,
                            curve: AppAnimations.smoothOut,
                            builder: (context, value, _) {
                              return RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: value.toInt().toString(),
                                      style: AppText.monoLarge(color).copyWith(fontSize: 56),
                                    ),
                                    TextSpan(text: '/100', style: AppText.monoMedium(AppColors.textTertiary)),
                                  ],
                                ),
                              );
                            },
                          ),
                          Text(_result!.grade, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: AppAnimations.dur500).slideY(begin: 0.1),
                const SizedBox(height: 16),
                Text('SCORE BREAKDOWN', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                ..._result!.breakdown.values.toList().asMap().entries.map((entry) {
                  final section = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(section.label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
                            ),
                            Text('${section.earned.toStringAsFixed(0)}/${section.max.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: section.earned / section.max),
                          duration: AppAnimations.dur600,
                          curve: AppAnimations.smoothOut,
                          builder: (context, value, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.radiusPill),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 3,
                                color: color,
                                backgroundColor: AppColors.borderSubtle,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 80 * entry.key));
                }),
                const SizedBox(height: 12),
                Text('SUGGESTIONS', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                ..._result!.suggestions.asMap().entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                      border: Border(left: BorderSide(color: color, width: 6)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(entry.value, style: Theme.of(context).textTheme.bodyMedium),
                  ).animate().fadeIn(delay: Duration(milliseconds: 60 * entry.key)).slideX(begin: -0.05);
                }),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgPrimary,
          border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _handleBottomNav,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.document_scanner_outlined), activeIcon: Icon(Icons.document_scanner), label: 'ATS'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
              BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = color.withOpacity(0.15);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..color = color;

    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57,
      6.28 * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
