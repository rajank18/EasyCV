import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  int _selectedIndex = 3; // Settings tab
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  
  String _userName = '';
  String _userEmail = '';
  String _photoUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _userName = data?['name'] ?? user.displayName ?? 'User';
          _userEmail = user.email ?? '';
          _photoUrl = user.photoURL ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _userName = user.displayName ?? 'User';
          _userEmail = user.email ?? '';
          _photoUrl = user.photoURL ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. All your data including resumes will be permanently deleted.',
        ),
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
        final user = _auth.currentUser;
        if (user == null) return;

        // Show loading
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Delete Firestore data
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete Firebase Auth account
        await user.delete();

        if (mounted) {
          Navigator.of(context).pop(); // Close loading
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // User Profile Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.radiusXl),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: AppShadows.shadowSm,
                ),
                child: Column(
                  children: [
                    // Profile Image
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.accent,
                      backgroundImage: _photoUrl.isNotEmpty
                          ? NetworkImage(_photoUrl)
                          : null,
                      child: _photoUrl.isEmpty
                          ? Text(
                              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Name
                    Text(
                      _userName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Email
                    Text(
                      _userEmail,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Notification Settings (Only on Mobile)
              if (!kIsWeb) Container(
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.radiusLg),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: AppShadows.shadowSm,
                ),
                child: Column(
                  children: [
                    // Notification Toggle
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      title: const Text(
                        'Weekly Resume Reminders',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text('Get notified to update your resume'),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) async {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          
                          if (value) {
                            await _notificationService.scheduleWeeklyNotifications();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Weekly notifications enabled! 📝'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            await _notificationService.cancelAllNotifications();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Notifications disabled'),
                                ),
                              );
                            }
                          }
                        },
                        activeColor: AppColors.accent,
                      ),
                    ),
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColors.borderSubtle,
                    ),
                    
                    // Test Notification Button
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.notifications_none,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      title: const Text(
                        'Test Notification',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text('Send a test notification now'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await _notificationService.showTestNotification();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test notification sent! Check your notification bar.'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColors.borderSubtle,
                    ),
                    
                    // Test Incomplete Profile Notification Button
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.amber.shade700,
                        ),
                      ),
                      title: const Text(
                        'Test Profile Reminder',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text('Send test profile completion reminder'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await _notificationService.showTestIncompleteProfileNotification();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test profile reminder sent! Check your notification bar.'),
                              backgroundColor: Colors.amber,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              if (!kIsWeb) const SizedBox(height: 24),
              
              // Account Options
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.radiusLg),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: AppShadows.shadowSm,
                ),
                child: Column(
                  children: [
                    // Logout Option
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.logout,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text('Sign out from your account'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _logout,
                    ),
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColors.borderSubtle,
                    ),
                    
                    // Delete Account Option
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.delete_forever,
                          color: Colors.red.shade700,
                        ),
                      ),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      subtitle: const Text('Permanently delete your account'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.red),
                      onTap: _deleteAccount,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // App Info
              Text(
                'EasyCV v1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
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
            onTap: (index) {
              if (index != _selectedIndex) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/ats-checker');
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/profile-info');
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
