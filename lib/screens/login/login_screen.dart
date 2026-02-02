import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    
    try {
      // For web, use Firebase's popup-based Google Sign-In
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      
      // Sign in with popup (works better on web)
      final UserCredential userCredential = 
          await _auth.signInWithPopup(googleProvider);
      
      // Create user document in Firestore if it doesn't exist
      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!);
        
        // Check if profile is complete and redirect accordingly
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        final profileComplete = userDoc.data()?['profileComplete'] ?? false;
        
        if (mounted) {
          if (profileComplete) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else {
            Navigator.of(context).pushReplacementNamed('/profile-info');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();
    
    if (!docSnapshot.exists) {
      await userDoc.set({
        'email': user.email,
        'name': user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'profileComplete': false,
        'profileData': {},
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 250, 255),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logowithoutbg.png',
                  height: 200,
                ),
                const SizedBox(height: 40),
                
                // Title
                const Text(
                  'Welcome to EasyCV',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0e5bbc),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Create ATS-friendly resumes in minutes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                
                // Google Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Image.asset(
                            'assets/images/google_icon.png',
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.login, color: Colors.white),
                          ),
                    label: Text(
                      _isLoading ? 'Signing in...' : 'Continue with Google',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0e5bbc),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Terms and Privacy
                const Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
