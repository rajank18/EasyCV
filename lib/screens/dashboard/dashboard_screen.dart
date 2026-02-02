import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                  'Hey, User',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Create New Resume Card
                _CreateNewResumeCard(),
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
                _PastResumesSection(),
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
        onPressed: () {
          // Navigate to resume creation page
          // Navigator.of(context).pushNamed('/create-resume');
        },
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.add, color: Color.fromARGB(255, 67, 83, 228)),
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
              }
              // if (index == 1) Navigator.pushNamed(context, '/explore');
              // if (index == 3) Navigator.pushNamed(context, '/settings');
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

// Create New Resume Card Widget
class _CreateNewResumeCard extends StatelessWidget {
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
          onTap: () {
            // Navigate to resume creation
            // Navigator.of(context).pushNamed('/create-resume');
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
  @override
  Widget build(BuildContext context) {
    // Sample data - replace with actual data later
    final resumes = [
      {'title': 'Software Developer Resume', 'date': 'Jan 20, 2026', 'atsScore': 85},
      {'title': 'Product Manager Resume', 'date': 'Jan 15, 2026', 'atsScore': 78},
    ];
    
    if (resumes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.description_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No resumes yet',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: resumes.map((resume) => _ResumeCard(
        title: resume['title'] as String,
        date: resume['date'] as String,
        atsScore: resume['atsScore'] as int,
      )).toList(),
    );
  }
}

// Resume Card Widget
class _ResumeCard extends StatelessWidget {
  final String title;
  final String date;
  final int atsScore;
  
  const _ResumeCard({
    required this.title,
    required this.date,
    required this.atsScore,
  });
  
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
            // Open resume details
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: atsScore >= 80 ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ATS: $atsScore%',
                    style: TextStyle(
                      color: atsScore >= 80 ? Colors.green.shade700 : Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
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
