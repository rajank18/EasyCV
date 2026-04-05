import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_animations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../services/notification_service.dart';
import '../ats/ats_checker_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _profileComplete = false;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _checkProfileStatus();
  }

  Future<void> _checkProfileStatus() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      final isComplete = data?['profileComplete'] ?? false;
      setState(() {
        _profileComplete = isComplete;
        _userName = data?['profileData']?['fullName'] ?? data?['name'] ?? 'User';
        _isLoading = false;
      });

      if (!kIsWeb) {
        if (!isComplete) {
          await NotificationService().scheduleDailyIncompleteProfileNotifications();
        } else {
          await NotificationService().cancelIncompleteProfileNotifications();
        }
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String get _initials {
    final parts = _userName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _onTapBottom(int index) {
    if (index == _selectedIndex) return;

    if (index == 1) {
      Navigator.pushReplacementNamed(context, ATSCheckerScreen.routeName);
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/profile-info');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/settings');
    }

    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      floatingActionButton: PressableScale(
        onTap: _profileComplete
            ? () => Navigator.of(context).pushNamed('/template-selection')
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please complete your profile first')),
                );
              },
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.bgPrimary,
          onPressed: _profileComplete
              ? () => Navigator.of(context).pushNamed('/template-selection')
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please complete your profile first')),
                  );
                },
          child: const Icon(Icons.add),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting.toUpperCase(),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                        PressableScale(
                          scale: 0.95,
                          onTap: () => Navigator.of(context).pushNamed('/profile-info'),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.accentTint,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _initials,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.accent),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: AppAnimations.dur300),
                    const SizedBox(height: 24),
                    Text('YOUR RESUMES', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ResumesStrip(profileComplete: _profileComplete, userId: _auth.currentUser?.uid ?? ''),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOOLS', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 12),
                    OpenContainer(
                      closedElevation: 0,
                      openElevation: 0,
                      transitionDuration: AppAnimations.dur400,
                      closedColor: Colors.transparent,
                      openColor: AppColors.bgPrimary,
                      openBuilder: (_, __) => const ATSCheckerScreen(),
                      closedBuilder: (_, openContainer) {
                        return PressableScale(
                          onTap: openContainer,
                          scale: 0.985,
                          child: AnimatedContainer(
                            duration: AppAnimations.dur200,
                            curve: AppAnimations.gentleFade,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.bgSurface,
                              borderRadius: BorderRadius.circular(AppRadius.radiusLg),
                              border: Border.all(color: AppColors.borderSubtle),
                              boxShadow: AppShadows.shadowSm,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentTint,
                                    borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                                  ),
                                  child: const Icon(Icons.document_scanner_outlined, color: AppColors.accent),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('ATS Score Checker', style: Theme.of(context).textTheme.titleSmall),
                                      const SizedBox(height: 2),
                                      Text('Upload your resume PDF', style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                        .animate()
                        .fadeIn(duration: AppAnimations.dur300, delay: AppAnimations.dur200)
                        .slideY(begin: 0.06),
                  ],
                ),
              ),
            ),
          ],
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
            onTap: _onTapBottom,
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

class _ResumesStrip extends StatelessWidget {
  const _ResumesStrip({required this.profileComplete, required this.userId});

  final bool profileComplete;
  final String userId;

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return const _EmptyResumes();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('resumes')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) {
                return Container(
                  width: 130,
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.radiusXl),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                );
              },
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const _EmptyResumes();
        }

        return SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _NewResumeCard(profileComplete: profileComplete);
              }
              final data = docs[index - 1].data() as Map<String, dynamic>;
              final title = data['title']?.toString() ?? 'Untitled Resume';
              final ats = (data['atsScore'] as num?)?.toInt() ?? 0;
              return _ResumeItemCard(
                title: title,
                atsScore: ats,
                editedText: _dateText(data['createdAt']),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening resume: $title')),
                  );
                },
                onLongPress: () => _showResumeSheet(context, docs[index - 1].id, title),
              ).animate().fadeIn(duration: AppAnimations.dur300, delay: Duration(milliseconds: 60 * index)).slideX(begin: 0.15);
            },
          ),
        );
      },
    );
  }

  String _dateText(dynamic timestamp) {
    if (timestamp is! Timestamp) return 'Edited recently';
    final d = DateTime.now().difference(timestamp.toDate());
    if (d.inDays <= 0) return 'Edited today';
    if (d.inDays == 1) return 'Edited 1d ago';
    return 'Edited ${d.inDays}d ago';
  }

  Future<void> _showResumeSheet(BuildContext context, String id, String title) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radiusXl)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Rename'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Duplicate'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                onTap: () async {
                  Navigator.pop(context);
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId == null) return;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('resumes')
                      .doc(id)
                      .delete();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyResumes extends StatelessWidget {
  const _EmptyResumes();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.radiusXl),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.shadowSm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description_outlined, size: 32, color: AppColors.textTertiary),
          const SizedBox(height: 10),
          Text('No resumes yet', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text('Tap + to create your first', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(begin: 0, end: -6, duration: const Duration(seconds: 3), curve: Curves.easeInOut);
  }
}

class _NewResumeCard extends StatelessWidget {
  const _NewResumeCard({required this.profileComplete});

  final bool profileComplete;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: profileComplete
          ? () => Navigator.of(context).pushNamed('/template-selection')
          : () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete your profile first')));
            },
      child: Container(
        width: 130,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.radiusXl),
          border: Border.all(color: AppColors.borderMid, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgSurfaceRaised,
                borderRadius: BorderRadius.circular(AppRadius.radiusMd),
              ),
              child: const Icon(Icons.add, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 8),
            Text('New', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ResumeItemCard extends StatelessWidget {
  const _ResumeItemCard({
    required this.title,
    required this.editedText,
    required this.atsScore,
    required this.onTap,
    required this.onLongPress,
  });

  final String title;
  final String editedText;
  final int atsScore;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: PressableScale(
        scale: 0.96,
        onTap: onTap,
        child: Container(
          width: 130,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.radiusXl),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.shadowSm,
          ),
          child: Column(
            children: [
              Expanded(
                flex: 65,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurfaceRaised,
                    borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                  ),
                  alignment: Alignment.center,
                  child: Text('EasyCV', style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
              Expanded(
                flex: 35,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                      Text(editedText, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                      if (atsScore > 0)
                        Text('ATS $atsScore', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
