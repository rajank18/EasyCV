import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final _courseController = TextEditingController();
  final _universityController = TextEditingController();
  final _gradeController = TextEditingController();
  final _yearController = TextEditingController();

  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _skillsController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _referencesController = TextEditingController();

  // Projects Controllers (up to 5, starts with 1)
  List<Map<String, TextEditingController>> _projects = [];
  int _projectCount = 1;

  @override
  void initState() {
    super.initState();
    _initializeProjectControllers();
    _loadProfileData();
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

    // Education Validation
    if (_courseController.text.trim().isEmpty) {
      return 'Course/Degree is required';
    }
    if (_universityController.text.trim().isEmpty) {
      return 'University is required';
    }

    if (_gradeController.text.trim().isEmpty) {
      return 'Grade/CGPA is required';
    }
    try {
      final grade = double.parse(_gradeController.text.trim());
      if (grade < 0 || grade > 10) {
        return 'Grade/CGPA must be between 0 and 10';
      }
    } catch (e) {
      return 'Grade/CGPA must be a valid number';
    }

    if (_yearController.text.trim().isEmpty) {
      return 'Year of Completion is required';
    }
    try {
      final year = int.parse(_yearController.text.trim());
      if (year < 1900 || year > DateTime.now().year) {
        return 'Please enter a valid year';
      }
    } catch (e) {
      return 'Year must be a valid number';
    }

    // Experience Validation
    if (_jobTitleController.text.trim().isEmpty) {
      return 'Job Title is required';
    }
    if (_companyController.text.trim().isEmpty) {
      return 'Company Name is required';
    }
    if (_durationController.text.trim().isEmpty) {
      return 'Duration is required';
    }
    if (_descriptionController.text.trim().isEmpty) {
      return 'Job Description is required';
    }

    // Skills, Objective, References
    if (_skillsController.text.trim().isEmpty) {
      return 'Skills are required';
    }
    if (_objectiveController.text.trim().isEmpty) {
      return 'Career Objective is required';
    }
    if (_referencesController.text.trim().isEmpty) {
      return 'References are required';
    }
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
    _courseController.dispose();
    _universityController.dispose();
    _gradeController.dispose();
    _yearController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _objectiveController.dispose();
    _referencesController.dispose();

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

            _courseController.text = profileData['course'] ?? '';
            _universityController.text = profileData['university'] ?? '';
            _gradeController.text = profileData['grade'] ?? '';
            _yearController.text = profileData['year'] ?? '';

            _jobTitleController.text = profileData['jobTitle'] ?? '';
            _companyController.text = profileData['company'] ?? '';
            _durationController.text = profileData['duration'] ?? '';
            _descriptionController.text = profileData['description'] ?? '';

            _skillsController.text = profileData['skills'] ?? '';
            _objectiveController.text = profileData['objective'] ?? '';
            _referencesController.text = profileData['references'] ?? '';

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
          'course': _courseController.text,
          'university': _universityController.text,
          'grade': _gradeController.text,
          'year': _yearController.text,
          'jobTitle': _jobTitleController.text,
          'company': _companyController.text,
          'duration': _durationController.text,
          'description': _descriptionController.text,
          'skills': _skillsController.text,
          'objective': _objectiveController.text,
          'references': _referencesController.text,
          'projects': projectsList,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _isProfileCreated = true;
      });

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
                      child: _EducationDetailsForm(
                        courseController: _courseController,
                        universityController: _universityController,
                        gradeController: _gradeController,
                        yearController: _yearController,
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
                      child: _ExperienceForm(
                        jobTitleController: _jobTitleController,
                        companyController: _companyController,
                        durationController: _durationController,
                        descriptionController: _descriptionController,
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

                    // References Section
                    _ProfileSection(
                      icon: Icons.contact_mail_outlined,
                      title: 'References',
                      isExpanded: _expandedIndex == 6,
                      onTap: () => setState(() =>
                          _expandedIndex = _expandedIndex == 6 ? null : 6),
                      child: _ReferencesForm(controller: _referencesController),
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
                  onPressed: _isLoading ? null : _saveProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0e5bbc),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(context, '/settings');
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
                        color: isExpanded
                            ? const Color(0xFF0e5bbc)
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isExpanded
                        ? const Color(0xFF0e5bbc)
                        : Colors.grey.shade600,
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
class _EducationDetailsForm extends StatelessWidget {
  final TextEditingController courseController;
  final TextEditingController universityController;
  final TextEditingController gradeController;
  final TextEditingController yearController;

  const _EducationDetailsForm({
    required this.courseController,
    required this.universityController,
    required this.gradeController,
    required this.yearController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Course/Degree', Icons.school, courseController),
        const SizedBox(height: 12),
        _buildTextField(
            'University/Institution', Icons.business, universityController),
        const SizedBox(height: 12),
        _buildTextField('Grade/CGPA (0-10)', Icons.grade, gradeController,
            inputType: TextInputType.numberWithOptions(decimal: true)),
        const SizedBox(height: 8),
        Text(
          'CGPA must be between 0 and 10',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField('Year of Completion', Icons.date_range, yearController,
            inputType: TextInputType.number),
      ],
    );
  }
}

// Experience Form
class _ExperienceForm extends StatelessWidget {
  final TextEditingController jobTitleController;
  final TextEditingController companyController;
  final TextEditingController durationController;
  final TextEditingController descriptionController;

  const _ExperienceForm({
    required this.jobTitleController,
    required this.companyController,
    required this.durationController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Job Title', Icons.work, jobTitleController),
        const SizedBox(height: 12),
        _buildTextField('Company Name', Icons.business, companyController),
        const SizedBox(height: 12),
        _buildTextField('Duration (e.g., 2020-2023)', Icons.access_time,
            durationController),
        const SizedBox(height: 12),
        _buildTextField(
            'Job Description', Icons.description, descriptionController,
            maxLines: 4),
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
  final TextEditingController controller;

  const _ReferencesForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('References', Icons.contact_mail, controller,
            maxLines: 5),
        const SizedBox(height: 8),
        Text(
          'Format: Name, Position, Contact (one per line)',
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
        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF0e5bbc)),
        suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0e5bbc)),
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
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    ),
  );
}
