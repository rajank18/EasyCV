import 'package:flutter/material.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  static const routeName = '/profile-info';

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  // Track which section is expanded
  int? _expandedIndex;
  
  // Check if profile is created (will be replaced with actual state management)
  bool _isProfileCreated = false;
  
  int _selectedIndex = 2; // Profile tab selected

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _isProfileCreated ? 'Edit Profile' : 'Create Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Details Section
                    _ProfileSection(
                      icon: Icons.person_outline,
                      title: 'Personal Details',
                      isExpanded: _expandedIndex == 0,
                      onTap: () => setState(() => _expandedIndex = _expandedIndex == 0 ? null : 0),
                      child: _PersonalDetailsForm(),
                    ),
                    const SizedBox(height: 12),
                    
                    // Education Details Section
                    _ProfileSection(
                      icon: Icons.school_outlined,
                      title: 'Education Details',
                      isExpanded: _expandedIndex == 1,
                      onTap: () => setState(() => _expandedIndex = _expandedIndex == 1 ? null : 1),
                      child: _EducationDetailsForm(),
                    ),
                    const SizedBox(height: 12),
                    
                    // Experience Section
                    _ProfileSection(
                      icon: Icons.work_outline,
                      title: 'Experience',
                      isExpanded: _expandedIndex == 2,
                      onTap: () => setState(() => _expandedIndex = _expandedIndex == 2 ? null : 2),
                      child: _ExperienceForm(),
                    ),
                    const SizedBox(height: 12),
                    
                    // Skills Section
                    _ProfileSection(
                      icon: Icons.lightbulb_outline,
                      title: 'Skills',
                      isExpanded: _expandedIndex == 3,
                      onTap: () => setState(() => _expandedIndex = _expandedIndex == 3 ? null : 3),
                      child: _SkillsForm(),
                    ),
                    const SizedBox(height: 12),
                    
                    // Objective Section
                    _ProfileSection(
                      icon: Icons.flag_outlined,
                      title: 'Objective',
                      isExpanded: _expandedIndex == 4,
                      onTap: () => setState(() => _expandedIndex = _expandedIndex == 4 ? null : 4),
                      child: _ObjectiveForm(),
                    ),
                    const SizedBox(height: 12),
                    
                    // References Section
                    _ProfileSection(
                      icon: Icons.contact_mail_outlined,
                      title: 'References',
                      isExpanded: _expandedIndex == 5,
                      onTap: () => setState(() => _expandedIndex = _expandedIndex == 5 ? null : 5),
                      child: _ReferencesForm(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Save Button at Bottom
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Save profile logic
                    setState(() {
                      _isProfileCreated = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile saved successfully!'),
                        backgroundColor: Color(0xFF0e5bbc),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0e5bbc),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isProfileCreated ? 'Update Profile' : 'Save Profile',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
              if (index != _selectedIndex) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                } else if (index == 1) {
                  // Navigator.pushReplacementNamed(context, '/explore');
                }
                setState(() {
                  _selectedIndex = index;
                });
              }
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

// Profile Section Widget with Expansion
class _ProfileSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget child;

  const _ProfileSection({
    required this.icon,
    required this.title,
    required this.isExpanded,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? const Color(0xFF0e5bbc) : Colors.grey.shade300,
          width: isExpanded ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0e5bbc).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: const Color(0xFF0e5bbc), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isExpanded ? const Color(0xFF0e5bbc) : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: isExpanded ? const Color(0xFF0e5bbc) : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: child,
            ),
        ],
      ),
    );
  }
}

// Personal Details Form
class _PersonalDetailsForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Full Name', Icons.person),
        const SizedBox(height: 12),
        _buildTextField('Email', Icons.email),
        const SizedBox(height: 12),
        _buildTextField('Phone Number', Icons.phone),
        const SizedBox(height: 12),
        _buildTextField('Address', Icons.location_on),
        const SizedBox(height: 12),
        _buildTextField('Date of Birth', Icons.calendar_today),
        const SizedBox(height: 12),
        _buildTextField('LinkedIn URL', Icons.link),
      ],
    );
  }
}

// Education Details Form
class _EducationDetailsForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Course/Degree', Icons.school),
        const SizedBox(height: 12),
        _buildTextField('University/Institution', Icons.business),
        const SizedBox(height: 12),
        _buildTextField('Grade/CGPA', Icons.grade),
        const SizedBox(height: 12),
        _buildTextField('Year of Completion', Icons.date_range),
      ],
    );
  }
}

// Experience Form
class _ExperienceForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Job Title', Icons.work),
        const SizedBox(height: 12),
        _buildTextField('Company Name', Icons.business),
        const SizedBox(height: 12),
        _buildTextField('Duration (e.g., 2020-2023)', Icons.access_time),
        const SizedBox(height: 12),
        _buildTextField('Job Description', Icons.description, maxLines: 4),
      ],
    );
  }
}

// Skills Form
class _SkillsForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Skills (comma separated)', Icons.star, maxLines: 3),
        const SizedBox(height: 8),
        Text(
          'Example: Python, JavaScript, React, Node.js',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// Objective Form
class _ObjectiveForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Career Objective', Icons.flag, maxLines: 5),
        const SizedBox(height: 8),
        Text(
          'Write a brief summary of your career goals',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// References Form
class _ReferencesForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Reference Name', Icons.person),
        const SizedBox(height: 12),
        _buildTextField('Position/Title', Icons.work),
        const SizedBox(height: 12),
        _buildTextField('Contact Information', Icons.contact_phone),
      ],
    );
  }
}

// Reusable Text Field Builder
Widget _buildTextField(String label, IconData icon, {int maxLines = 1}) {
  return TextField(
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF0e5bbc)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0e5bbc), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    ),
  );
}
