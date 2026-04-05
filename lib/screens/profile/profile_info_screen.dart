import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/notification_service.dart';
import '../../core/theme/app_theme.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  static const routeName = '/profile-info';

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track which section is expanded
  int? _expandedIndex;

  // Check if profile is created
  bool _isProfileCreated = false;
  bool _isLoading = false;

  int _selectedIndex = 2; // Profile tab selected

  // Text Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _linkedinController = TextEditingController();

  // Education Controllers (up to 3)
  List<Map<String, TextEditingController>> _educations = [];
  int _educationCount = 1;

  // Experience Controllers (up to 5)
  List<Map<String, TextEditingController>> _experiences = [];
  int _experienceCount = 1;

  final _skillsController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _referencesController = TextEditingController();
  final _achievementsController = TextEditingController();
  final _interestsController = TextEditingController();

  // Projects Controllers (up to 5, starts with 1)
  List<Map<String, TextEditingController>> _projects = [];
  int _projectCount = 1;

  @override
  void initState() {
    super.initState();
    _initializeEducationControllers();
    _initializeExperienceControllers();
    _initializeProjectControllers();
    _loadProfileData();
  }

  void _initializeEducationControllers() {
    _educations = List.generate(_educationCount, (index) {
      return {
        'course': TextEditingController(),
        'university': TextEditingController(),
        'grade': TextEditingController(),
        'year': TextEditingController(),
      };
    });
  }

  void _addEducation() {
    if (_educationCount < 3) {
      setState(() {
        _educationCount++;
        _educations.add({
          'course': TextEditingController(),
          'university': TextEditingController(),
          'grade': TextEditingController(),
          'year': TextEditingController(),
        });
      });
    }
  }

  void _removeEducation(int index) {
    if (_educationCount > 1) {
      setState(() {
        _educations[index]['course']?.dispose();
        _educations[index]['university']?.dispose();
        _educations[index]['grade']?.dispose();
        _educations[index]['year']?.dispose();
        _educations.removeAt(index);
        _educationCount--;
      });
    }
  }

  void _initializeExperienceControllers() {
    _experiences = List.generate(_experienceCount, (index) {
      return {
        'jobTitle': TextEditingController(),
        'company': TextEditingController(),
        'duration': TextEditingController(),
        'description': TextEditingController(),
      };
    });
  }

  void _addExperience() {
    if (_experienceCount < 5) {
      setState(() {
        _experienceCount++;
        _experiences.add({
          'jobTitle': TextEditingController(),
          'company': TextEditingController(),
          'duration': TextEditingController(),
          'description': TextEditingController(),
        });
      });
    }
  }

  void _removeExperience(int index) {
    if (_experienceCount > 1) {
      setState(() {
        _experiences[index]['jobTitle']?.dispose();
        _experiences[index]['company']?.dispose();
        _experiences[index]['duration']?.dispose();
        _experiences[index]['description']?.dispose();
        _experiences.removeAt(index);
        _experienceCount--;
      });
    }
  }

  void _initializeProjectControllers() {
    _projects = List.generate(_projectCount, (index) {
      return {
        'name': TextEditingController(),
        'description': TextEditingController(),
        'technologies': TextEditingController(),
        'link': TextEditingController(),
      };
    });
  }

  void _addProject() {
    if (_projectCount < 5) {
      setState(() {
        _projectCount++;
        _projects.add({
          'name': TextEditingController(),
          'description': TextEditingController(),
          'technologies': TextEditingController(),
          'link': TextEditingController(),
        });
      });
    }
  }

  void _removeProject(int index) {
    if (_projectCount > 1) {
      setState(() {
        _projects[index]['name']?.dispose();
        _projects[index]['description']?.dispose();
        _projects[index]['technologies']?.dispose();
        _projects[index]['link']?.dispose();
        _projects.removeAt(index);
        _projectCount--;
      });
    }
  }

  String? _validateFields() {
    // Personal Details Validation
    if (_fullNameController.text.trim().isEmpty) {
      return 'Full Name is required';
    }
    if (_fullNameController.text.trim().length < 2) {
      return 'Full Name must be at least 2 characters';
    }

    if (_emailController.text.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(_emailController.text.trim())) {
      return 'Please enter a valid email address';
    }

    if (_phoneController.text.trim().isEmpty) {
      return 'Phone Number is required';
    }
    if (!RegExp(r'^[0-9]{10,}$').hasMatch(_phoneController.text.trim())) {
      return 'Phone Number must be at least 10 digits';
    }

    if (_addressController.text.trim().isEmpty) {
      return 'Address is required';
    }
    if (_dobController.text.trim().isEmpty) {
      return 'Date of Birth is required';
    }

    if (_linkedinController.text.trim().isEmpty) {
      return 'LinkedIn URL is required';
    }
    if (!_linkedinController.text.trim().contains('linkedin')) {
      return 'Please enter a valid LinkedIn URL';
    }

    // Education Validation (at least one required)
    for (int i = 0; i < _educations.length; i++) {
      final edu = _educations[i];
      if (edu['course']!.text.trim().isEmpty) {
        return 'Education ${i + 1}: Course/Degree is required';
      }
      if (edu['university']!.text.trim().isEmpty) {
        return 'Education ${i + 1}: University is required';
      }
      if (edu['grade']!.text.trim().isEmpty) {
        return 'Education ${i + 1}: Grade/CGPA is required';
      }
      try {
        final grade = double.parse(edu['grade']!.text.trim());
        if (grade < 0 || grade > 10) {
          return 'Education ${i + 1}: Grade/CGPA must be between 0 and 10';
        }
      } catch (e) {
        return 'Education ${i + 1}: Grade/CGPA must be a valid number';
      }
      if (edu['year']!.text.trim().isEmpty) {
        return 'Education ${i + 1}: Year of Completion is required';
      }
      try {
        final year = int.parse(edu['year']!.text.trim());
        if (year < 1900 || year > DateTime.now().year + 5) {
          return 'Education ${i + 1}: Please enter a valid year';
        }
      } catch (e) {
        return 'Education ${i + 1}: Year must be a valid number';
      }
    }

    // Experience Validation (at least one required)
    for (int i = 0; i < _experiences.length; i++) {
      final exp = _experiences[i];
      if (exp['jobTitle']!.text.trim().isEmpty) {
        return 'Experience ${i + 1}: Job Title is required';
      }
      if (exp['company']!.text.trim().isEmpty) {
        return 'Experience ${i + 1}: Company Name is required';
      }
      if (exp['duration']!.text.trim().isEmpty) {
        return 'Experience ${i + 1}: Duration is required';
      }
      if (exp['description']!.text.trim().isEmpty) {
        return 'Experience ${i + 1}: Job Description is required';
      }
      if (exp['description']!.text.trim().length < 100) {
        return 'Experience ${i + 1}: Job Description must be at least 100 characters (currently ${exp['description']!.text.trim().length})';
      }
    }

    // Skills, Objective, References
    if (_skillsController.text.trim().isEmpty) {
      return 'Skills are required';
    }
    // Count skills (comma or newline separated)
    final skillsList = _skillsController.text
        .trim()
        .split(RegExp(r'[,\n]'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (skillsList.length < 5) {
      return 'Please add at least 5 skills (currently ${skillsList.length}). Separate with commas or new lines';
    }

    if (_objectiveController.text.trim().isEmpty) {
      return 'Career Objective is required';
    }
    if (_objectiveController.text.trim().length < 100) {
      return 'Career Objective must be at least 100 characters (currently ${_objectiveController.text.trim().length})';
    }

    // References are optional - no validation needed
    // Achievements and Interests are also optional - no validation needed

    return null;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _linkedinController.dispose();
    _skillsController.dispose();
    _objectiveController.dispose();
    _referencesController.dispose();
    _achievementsController.dispose();
    _interestsController.dispose();

    // Dispose education controllers
    for (var edu in _educations) {
      edu['course']?.dispose();
      edu['university']?.dispose();
      edu['grade']?.dispose();
      edu['year']?.dispose();
    }

    // Dispose experience controllers
    for (var exp in _experiences) {
      exp['jobTitle']?.dispose();
      exp['company']?.dispose();
      exp['duration']?.dispose();
      exp['description']?.dispose();
    }

    // Dispose project controllers
    for (var project in _projects) {
      project['name']?.dispose();
      project['description']?.dispose();
      project['technologies']?.dispose();
      project['link']?.dispose();
    }

    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final profileData = data?['profileData'] as Map<String, dynamic>?;

        if (profileData != null) {
          setState(() {
            _fullNameController.text = profileData['fullName'] ?? '';
            _emailController.text = profileData['email'] ?? user.email ?? '';
            _phoneController.text = profileData['phone'] ?? '';
            _addressController.text = profileData['address'] ?? '';
            _dobController.text = profileData['dob'] ?? '';
            _linkedinController.text = profileData['linkedin'] ?? '';

            _skillsController.text = profileData['skills'] ?? '';
            _objectiveController.text = profileData['objective'] ?? '';
            _referencesController.text = profileData['references'] ?? '';
            _achievementsController.text = profileData['achievements'] ?? '';
            _interestsController.text = profileData['interests'] ?? '';

            // Load educations
            final educationsList =
                profileData['educations'] as List<dynamic>? ?? [];
            if (educationsList.isNotEmpty) {
              _educationCount = educationsList.length.clamp(1, 3);
              _educations = List.generate(_educationCount, (i) {
                return {
                  'course': TextEditingController(),
                  'university': TextEditingController(),
                  'grade': TextEditingController(),
                  'year': TextEditingController(),
                };
              });
              for (int i = 0; i < educationsList.length && i < 3; i++) {
                final edu = educationsList[i] as Map<String, dynamic>;
                _educations[i]['course']!.text = edu['course'] ?? '';
                _educations[i]['university']!.text = edu['university'] ?? '';
                _educations[i]['grade']!.text = edu['grade'] ?? '';
                _educations[i]['year']!.text = edu['year'] ?? '';
              }
            }

            // Load experiences
            final experiencesList =
                profileData['experiences'] as List<dynamic>? ?? [];
            if (experiencesList.isNotEmpty) {
              _experienceCount = experiencesList.length.clamp(1, 5);
              _experiences = List.generate(_experienceCount, (i) {
                return {
                  'jobTitle': TextEditingController(),
                  'company': TextEditingController(),
                  'duration': TextEditingController(),
                  'description': TextEditingController(),
                };
              });
              for (int i = 0; i < experiencesList.length && i < 5; i++) {
                final exp = experiencesList[i] as Map<String, dynamic>;
                _experiences[i]['jobTitle']!.text = exp['jobTitle'] ?? '';
                _experiences[i]['company']!.text = exp['company'] ?? '';
                _experiences[i]['duration']!.text = exp['duration'] ?? '';
                _experiences[i]['description']!.text = exp['description'] ?? '';
              }
            }

            // Load projects
            final projectsList =
                profileData['projects'] as List<dynamic>? ?? [];
            for (int i = 0; i < projectsList.length && i < 5; i++) {
              final project = projectsList[i] as Map<String, dynamic>;
              _projects[i]['name']!.text = project['name'] ?? '';
              _projects[i]['description']!.text = project['description'] ?? '';
              _projects[i]['technologies']!.text =
                  project['technologies'] ?? '';
              _projects[i]['link']!.text = project['link'] ?? '';
            }

            _isProfileCreated = data?['profileComplete'] ?? false;
          });
        } else {
          // Pre-fill email from Firebase Auth
          _emailController.text = user.email ?? '';
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Validate required fields
    final validationError = _validateFields();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Build educations list
      List<Map<String, String>> educationsList = [];
      for (var edu in _educations) {
        if (edu['course']!.text.isNotEmpty) {
          educationsList.add({
            'course': edu['course']!.text,
            'university': edu['university']!.text,
            'grade': edu['grade']!.text,
            'year': edu['year']!.text,
          });
        }
      }

      // Build experiences list
      List<Map<String, String>> experiencesList = [];
      for (var exp in _experiences) {
        if (exp['jobTitle']!.text.isNotEmpty) {
          experiencesList.add({
            'jobTitle': exp['jobTitle']!.text,
            'company': exp['company']!.text,
            'duration': exp['duration']!.text,
            'description': exp['description']!.text,
          });
        }
      }

      // Build projects list (only include non-empty projects)
      List<Map<String, String>> projectsList = [];
      for (var project in _projects) {
        if (project['name']!.text.isNotEmpty) {
          projectsList.add({
            'name': project['name']!.text,
            'description': project['description']!.text,
            'technologies': project['technologies']!.text,
            'link': project['link']!.text,
          });
        }
      }

      await _firestore.collection('users').doc(user.uid).set({
        'profileComplete': true,
        'profileData': {
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'dob': _dobController.text,
          'linkedin': _linkedinController.text,
          'educations': educationsList,
          'experiences': experiencesList,
          'skills': _skillsController.text,
          'objective': _objectiveController.text,
          'references': _referencesController.text,
          'achievements': _achievementsController.text,
          'interests': _interestsController.text,
          'projects': projectsList,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _isProfileCreated = true;
      });
      
      // Cancel incomplete profile notifications since profile is now complete
      if (!kIsWeb) {
        await NotificationService().cancelIncompleteProfileNotifications();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: Color(0xFF0e5bbc),
          ),
        );

        // Navigate to dashboard after save
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _isProfileCreated ? 'Edit Profile' : 'Create Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
                      onTap: () => setState(() =>
                          _expandedIndex = _expandedIndex == 0 ? null : 0),
                      child: _PersonalDetailsForm(
                        fullNameController: _fullNameController,
                        emailController: _emailController,
                        phoneController: _phoneController,
                        addressController: _addressController,
                        dobController: _dobController,
                        linkedinController: _linkedinController,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Education Details Section
                    _ProfileSection(
                      icon: Icons.school_outlined,
                      title: 'Education Details',
                      isExpanded: _expandedIndex == 1,
                      onTap: () => setState(() =>
                          _expandedIndex = _expandedIndex == 1 ? null : 1),
                      child: _EducationsForm(
                        educations: _educations,
                        onAddEducation: _addEducation,
                        onRemoveEducation: _removeEducation,
                        canAddMore: _educationCount < 3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Experience Section
                    _ProfileSection(
                      icon: Icons.work_outline,
                      title: 'Experience',
                      isExpanded: _expandedIndex == 2,
                      onTap: () => setState(() =>
                          _expandedIndex = _expandedIndex == 2 ? null : 2),
                      child: _ExperiencesForm(
                        experiences: _experiences,
                        onAddExperience: _addExperience,
                        onRemoveExperience: _removeExperience,
                        canAddMore: _experienceCount < 5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Skills Section
                    _ProfileSection(
                      icon: Icons.lightbulb_outline,
                      title: 'Skills',
                      isExpanded: _expandedIndex == 3,
                      onTap: () => setState(() =>
                          _expandedIndex = _expandedIndex == 3 ? null : 3),
                      child: _SkillsForm(controller: _skillsController),
                    ),
                    const SizedBox(height: 12),

                    // Projects Section
                    _ProfileSection(
                      icon: Icons.folder_outlined,
                      title: 'Projects (Optional)',
                      isExpanded: _expandedIndex == 4,
                      onTap: () => setState(() =>
                          _expandedIndex = _expandedIndex == 4 ? null : 4),
                      child: _ProjectsForm(
                        projects: _projects,
                        onAddProject: _addProject,
                        onRemoveProject: _removeProject,
                        canAddMore: _projectCount < 5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Objective Section
                    _ProfileSection(
                      icon: Icons.flag_outlined,
                      title: 'Objective',
                      isExpanded: _expandedIndex == 5,
                      onTap: () => setState(() =>
                          _expandedIndex = _expandedIndex == 5 ? null : 5),
                      child: _ObjectiveForm(controller: _objectiveController),
                    ),
                    const SizedBox(height: 12),

                    // References Section (Optional)
                    _ProfileSection(
                      icon: Icons.contact_mail_outlined,
                      title: 'References (Optional)',
                      isExpanded: _expandedIndex == 6,
                      onTap: () => setState(() =>
                          _expandedIndex = _expandedIndex == 6 ? null : 6),
                      child: _ReferencesForm(controller: _referencesController),
                    ),
                    const SizedBox(height: 12),

                    // Achievements Section (Optional)
                    _ProfileSection(
                      icon: Icons.emoji_events_outlined,
                      title: 'Achievements (Optional)',
                      isExpanded: _expandedIndex == 7,
                      onTap: () => setState(() =>
                          _expandedIndex = _expandedIndex == 7 ? null : 7),
                      child: _AchievementsForm(controller: _achievementsController),
                    ),
                    const SizedBox(height: 12),

                    // Interests Section (Optional)
                    _ProfileSection(
                      icon: Icons.interests_outlined,
                      title: 'Other Interests (Optional)',
                      isExpanded: _expandedIndex == 8,
                      onTap: () => setState(() =>
                          _expandedIndex = _expandedIndex == 8 ? null : 8),
                      child: _InterestsForm(controller: _interestsController),
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
                color: AppColors.bgPrimary,
                border: const Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
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
        decoration: const BoxDecoration(
          color: AppColors.bgPrimary,
          border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index != _selectedIndex) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/ats-checker');
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(context, '/settings');
                }
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.document_scanner_outlined),
                activeIcon: Icon(Icons.document_scanner),
                label: 'ATS',
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
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.radiusLg),
        border: Border.all(
          color: isExpanded ? AppColors.accent : AppColors.borderSubtle,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentTint,
                      borderRadius: BorderRadius.circular(AppRadius.radiusSm),
                    ),
                    child: Icon(icon, color: AppColors.accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isExpanded ? AppColors.accent : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isExpanded ? AppColors.accent : AppColors.textTertiary,
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
class _PersonalDetailsForm extends StatefulWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController dobController;
  final TextEditingController linkedinController;

  const _PersonalDetailsForm({
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.dobController,
    required this.linkedinController,
  });

  @override
  State<_PersonalDetailsForm> createState() => _PersonalDetailsFormState();
}

class _PersonalDetailsFormState extends State<_PersonalDetailsForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Full Name', Icons.person, widget.fullNameController),
        const SizedBox(height: 12),
        _buildTextField('Email', Icons.email, widget.emailController),
        const SizedBox(height: 12),
        _buildTextField('Phone Number', Icons.phone, widget.phoneController,
            inputType: TextInputType.phone),
        const SizedBox(height: 12),
        _buildTextField('Address', Icons.location_on, widget.addressController),
        const SizedBox(height: 12),
        _buildDateField(
          label: 'Date of Birth',
          controller: widget.dobController,
          context: context,
        ),
        const SizedBox(height: 12),
        _buildTextField('LinkedIn URL', Icons.link, widget.linkedinController),
      ],
    );
  }
}

// Education Details Form
class _EducationsForm extends StatelessWidget {
  final List<Map<String, TextEditingController>> educations;
  final VoidCallback onAddEducation;
  final Function(int) onRemoveEducation;
  final bool canAddMore;

  const _EducationsForm({
    required this.educations,
    required this.onAddEducation,
    required this.onRemoveEducation,
    required this.canAddMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: educations.length,
          separatorBuilder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Colors.grey.shade300),
          ),
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Education ${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0e5bbc),
                      ),
                    ),
                    if (educations.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => onRemoveEducation(index),
                        tooltip: 'Remove Education',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField('Course/Degree', Icons.school, educations[index]['course']!),
                const SizedBox(height: 12),
                _buildTextField('University/Institution', Icons.business, educations[index]['university']!),
                const SizedBox(height: 12),
                _buildTextField('Grade/CGPA (0-10)', Icons.grade, educations[index]['grade']!,
                    inputType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 12),
                _buildTextField('Year of Completion', Icons.date_range, educations[index]['year']!,
                    inputType: TextInputType.number),
              ],
            );
          },
        ),
        if (canAddMore) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onAddEducation,
            icon: const Icon(Icons.add),
            label: Text('Add Another Education (${educations.length}/3)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0e5bbc),
            ),
          ),
        ],
      ],
    );
  }
}

// Experiences Form
class _ExperiencesForm extends StatelessWidget {
  final List<Map<String, TextEditingController>> experiences;
  final VoidCallback onAddExperience;
  final Function(int) onRemoveExperience;
  final bool canAddMore;

  const _ExperiencesForm({
    required this.experiences,
    required this.onAddExperience,
    required this.onRemoveExperience,
    required this.canAddMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: experiences.length,
          separatorBuilder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Colors.grey.shade300),
          ),
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Experience ${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0e5bbc),
                      ),
                    ),
                    if (experiences.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => onRemoveExperience(index),
                        tooltip: 'Remove Experience',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField('Job Title', Icons.work, experiences[index]['jobTitle']!),
                const SizedBox(height: 12),
                _buildTextField('Company Name', Icons.business, experiences[index]['company']!),
                const SizedBox(height: 12),
                _buildTextField('Duration (e.g., 2020-2023)', Icons.access_time, experiences[index]['duration']!),
                const SizedBox(height: 12),
                _buildTextField('Job Description', Icons.description, experiences[index]['description']!, maxLines: 4),
                const SizedBox(height: 8),
                Text(
                  '⚠️ Minimum 100 characters required for detailed description',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        if (canAddMore) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onAddExperience,
            icon: const Icon(Icons.add),
            label: Text('Add Another Experience (${experiences.length}/5)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0e5bbc),
            ),
          ),
        ],
      ],
    );
  }
}

// Skills Form
class _SkillsForm extends StatelessWidget {
  final TextEditingController controller;

  const _SkillsForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Skills (comma separated)', Icons.star, controller,
            maxLines: 3),
        const SizedBox(height: 8),
        Text(
          '⚠️ Minimum 5 skills required | Example: Python, JavaScript, React, Node.js, MongoDB',
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Projects Form
class _ProjectsForm extends StatelessWidget {
  final List<Map<String, TextEditingController>> projects;
  final VoidCallback onAddProject;
  final Function(int) onRemoveProject;
  final bool canAddMore;

  const _ProjectsForm({
    required this.projects,
    required this.onAddProject,
    required this.onRemoveProject,
    required this.canAddMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: projects.length,
          separatorBuilder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Colors.grey.shade300),
          ),
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Project ${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (projects.length > 1)
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.red, size: 20),
                        onPressed: () => onRemoveProject(index),
                        tooltip: 'Remove project',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                    'Project Name', Icons.folder, projects[index]['name']!,
                    isRequired: false),
                const SizedBox(height: 12),
                _buildTextField('Description', Icons.description,
                    projects[index]['description']!,
                    maxLines: 3, isRequired: false),
                const SizedBox(height: 12),
                _buildTextField('Technologies Used', Icons.code,
                    projects[index]['technologies']!,
                    maxLines: 2, isRequired: false),
                const SizedBox(height: 12),
                _buildTextField(
                    'Project Link/URL', Icons.link, projects[index]['link']!,
                    isRequired: false),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        if (canAddMore)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddProject,
              icon: const Icon(Icons.add),
              label: const Text('Add Project'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0e5bbc),
                side: const BorderSide(color: Color(0xFF0e5bbc)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        if (!canAddMore)
          Text(
            'Maximum 5 projects allowed',
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
  final TextEditingController controller;

  const _ObjectiveForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Career Objective', Icons.flag, controller,
            maxLines: 5),
        const SizedBox(height: 8),
        Text(
          '⚠️ Minimum 100 characters required | Write a detailed summary of your career goals',
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// References Form
class _ReferencesForm extends StatelessWidget {
  final TextEditingController controller;

  const _ReferencesForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('References', Icons.contact_mail, controller,
            maxLines: 5, isRequired: false),
        const SizedBox(height: 8),
        Text(
          'Optional | Format: Name, Position, Contact (one per line)',
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

// Achievements Form
class _AchievementsForm extends StatelessWidget {
  final TextEditingController controller;

  const _AchievementsForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Achievements', Icons.emoji_events, controller,
            maxLines: 5, isRequired: false),
        const SizedBox(height: 8),
        Text(
          'Optional | Add hackathons, awards, certifications (one per line with bullet points)',
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

// Interests Form
class _InterestsForm extends StatelessWidget {
  final TextEditingController controller;

  const _InterestsForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Other Interests', Icons.favorite, controller,
            maxLines: 3, isRequired: false),
        const SizedBox(height: 8),
        Text(
          'Optional | Add your hobbies, interests (comma separated)',
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

// Reusable Text Field Builder
Widget _buildTextField(
    String label, IconData icon, TextEditingController controller,
    {int maxLines = 1,
    bool isRequired = true,
    TextInputType inputType = TextInputType.text}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: inputType,
    decoration: InputDecoration(
      labelText: isRequired ? '$label *' : label,
      prefixIcon: Icon(icon, color: AppColors.accent),
      filled: true,
      fillColor: AppColors.bgSurface,
    ),
  );
}

// Date Picker Field Builder
Widget _buildDateField({
  required String label,
  required TextEditingController controller,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: () async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: controller.text.isNotEmpty
            ? DateTime.parse(controller.text)
            : DateTime(2000),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (pickedDate != null) {
        controller.text = pickedDate.toString().split(' ')[0];
      }
    },
    child: TextField(
      controller: controller,
      enabled: false,
      decoration: InputDecoration(
        labelText: '$label *',
        prefixIcon: const Icon(Icons.calendar_today, color: AppColors.accent),
        suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.accent),
        filled: true,
        fillColor: AppColors.bgSurface,
      ),
    ),
  );
}
