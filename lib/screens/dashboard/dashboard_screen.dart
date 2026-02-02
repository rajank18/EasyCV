import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _profileComplete = data?['profileComplete'] ?? false;
          _userName = data?['profileData']?['fullName'] ?? data?['name'] ?? 'User';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 249, 251, 255),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0e5bbc),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 251, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  'Hey, $_userName',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Profile incomplete warning
                if (!_profileComplete) _ProfileIncompleteCard(),
                if (!_profileComplete) const SizedBox(height: 24),
                
                // Create New Resume Card
                _CreateNewResumeCard(profileComplete: _profileComplete),
                const SizedBox(height: 32),
                
                // Past Resumes Section
                Text(
                  'Your Resumes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _PastResumesSection(userId: _auth.currentUser?.uid ?? ''),
                const SizedBox(height: 32),
                
                // Explore Themes Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Explore Resume Themes',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    _ThemeCarouselControls(),
                  ],
                ),
                const SizedBox(height: 16),
                _ExploreThemesSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _profileComplete ? () {
          // Navigate to template selection
          Navigator.of(context).pushNamed('/template-selection');
        } : () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete your profile first'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        backgroundColor: const Color(0xFF0e5bbc),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              // Handle navigation based on index
              if (index == 2) {
                Navigator.pushNamed(context, '/profile-info');
              } else if (index == 3) {
                Navigator.pushNamed(context, '/settings');
              }
              // if (index == 1) Navigator.pushNamed(context, '/explore');
            },
            selectedItemColor: const Color(0xFF0e5bbc),
            unselectedItemColor: const Color.fromARGB(255, 80, 80, 80),
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile Incomplete Warning Card
class _ProfileIncompleteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please complete your profile to create resumes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/profile-info');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}

// Create New Resume Card Widget
class _CreateNewResumeCard extends StatelessWidget {
  final bool profileComplete;
  
  const _CreateNewResumeCard({this.profileComplete = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0e5bbc), Color(0xFF1976d2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: profileComplete ? () {
            // Navigate to template selection
            Navigator.of(context).pushNamed('/template-selection');
          } : () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please complete your profile first'),
                backgroundColor: Colors.orange,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Resume',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start building your professional resume',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Past Resumes Section
class _PastResumesSection extends StatelessWidget {
  final String userId;
  
  const _PastResumesSection({required this.userId});
  
  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return _EmptyResumesWidget();
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: Color(0xFF0e5bbc),
              ),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Error loading resumes',
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _EmptyResumesWidget();
        }
        
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _ResumeCard(
              resumeId: doc.id,
              title: data['title'] ?? 'Untitled Resume',
              date: _formatDate(data['createdAt']),
              atsScore: data['atsScore'] ?? 0,
              templateType: data['templateType'] ?? 'default',
            );
          }).toList(),
        );
      },
    );
  }
  
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    try {
      final date = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}

// Empty Resumes Widget
class _EmptyResumesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.description_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No resumes yet',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create your first resume to get started',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Resume Card Widget
class _ResumeCard extends StatelessWidget {
  final String resumeId;
  final String title;
  final String date;
  final int atsScore;
  final String templateType;
  
  const _ResumeCard({
    required this.resumeId,
    required this.title,
    required this.date,
    required this.atsScore,
    required this.templateType,
  });
  
  Color _getScoreColor() {
    if (atsScore >= 80) return Colors.green;
    if (atsScore >= 60) return Colors.orange;
    return Colors.red;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Open resume details/edit
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening resume: $title'),
                backgroundColor: const Color(0xFF0e5bbc),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0e5bbc).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Color(0xFF0e5bbc),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.grid_view, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            templateType,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (atsScore > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getScoreColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getScoreColor(), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.speed, size: 16, color: _getScoreColor()),
                        const SizedBox(width: 4),
                        Text(
                          '$atsScore',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _getScoreColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  onSelected: (value) {
                    if (value == 'edit') {
                      // Edit resume
                    } else if (value == 'delete') {
                      _deleteResume(context);
                    } else if (value == 'download') {
                      // Download resume
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Download feature coming soon!'),
                          backgroundColor: Color(0xFF0e5bbc),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 20),
                          SizedBox(width: 12),
                          Text('Download'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _deleteResume(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('resumes')
              .doc(resumeId)
              .delete();
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Resume deleted successfully'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting resume: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// Explore Themes Section (Placeholder for future template dataset)
// Explore Themes Section
class _ExploreThemesSection extends StatefulWidget {
  @override
  State<_ExploreThemesSection> createState() => _ExploreThemesSectionState();
}

class _ExploreThemesSectionState extends State<_ExploreThemesSection> {
  static final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final themes = [
      {'name': 'Modern Professional', 'color': const Color(0xFF0e5bbc)},
      {'name': 'Classic Elegant', 'color': const Color(0xFF2e7d32)},
      {'name': 'Creative Bold', 'color': const Color(0xFFd84315)},
      {'name': 'Minimal Clean', 'color': const Color(0xFF5e35b1)},
      {'name': 'Corporate Style', 'color': const Color(0xFF6a1b9a)},
      {'name': 'Tech Savvy', 'color': const Color(0xFF00838f)},
    ];
    
    return SizedBox(
      height: 180,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: themes.length,
        itemBuilder: (context, index) {
          final theme = themes[index];
          return Padding(
            padding: EdgeInsets.only(right: index < themes.length - 1 ? 12.0 : 0),
            child: SizedBox(
              width: 160,
              child: _ThemeCard(
                name: theme['name'] as String,
                color: theme['color'] as Color,
              ),
            ),
          );
        },
      ),
    );
  }

  static void scrollNext() {
    _scrollController.animateTo(
      _scrollController.offset + 172,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  static void scrollPrevious() {
    _scrollController.animateTo(
      _scrollController.offset - 172,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

// Theme Carousel Controls
class _ThemeCarouselControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _ExploreThemesSectionState.scrollPrevious(),
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF0e5bbc),
            padding: const EdgeInsets.all(8),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _ExploreThemesSectionState.scrollNext(),
          icon: const Icon(Icons.arrow_forward_ios, size: 18),
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF0e5bbc),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }
}


// Theme Card Widget
class _ThemeCard extends StatelessWidget {
  final String name;
  final Color color;
  
  const _ThemeCard({
    required this.name,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Preview theme
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.article,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
