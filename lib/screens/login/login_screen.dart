import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_animations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable_scale.dart';

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
      UserCredential userCredential;

      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        if (googleUser == null) {
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }
      
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
    final insets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: AnimatedPadding(
          duration: AppAnimations.dur300,
          curve: AppAnimations.smoothOut,
          padding: EdgeInsets.only(bottom: insets),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 48),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    Text(
                      'EasyCV',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 38),
                    )
                        .animate()
                        .fadeIn(duration: AppAnimations.dur500)
                        .slideY(begin: -0.1, curve: AppAnimations.smoothOut),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in with Google to continue.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ).animate().fadeIn(duration: AppAnimations.dur400, delay: AppAnimations.dur100),
                    const SizedBox(height: 44),
                    PressableScale(
                      onTap: _isLoading ? null : _signInWithGoogle,
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Image.asset(
                                  'assets/images/google_icon.png',
                                  height: 18,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.g_mobiledata);
                                  },
                                ),
                          label: Text(_isLoading ? 'Signing in...' : 'Continue with Google'),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: AppAnimations.dur300, delay: AppAnimations.dur300)
                        .slideY(begin: 0.08),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Center(
                        child: Text(
                          'By continuing, you agree to use Google authentication.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
