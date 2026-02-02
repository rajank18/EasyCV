import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/profile/profile_info_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/templates/template_selection_screen.dart';

//logo color - #0e5bbc , bg color - fromARGB(255, 248, 250, 255),

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDGvo-9OtjYfaPXG5qa7AHgiB9lwLbPBQ0",
      authDomain: "easycv-4609c.firebaseapp.com",
      projectId: "easycv-4609c",
      storageBucket: "easycv-4609c.firebasestorage.app",
      messagingSenderId: "728845413362",
      appId: "1:728845413362:web:7bb79e6794e5bfc8f7996b",
      measurementId: "G-FXTCHFCBHN",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyCV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0e5bbc)),
        useMaterial3: true,
      ),
      initialRoute: OnboardingScreen.routeName,
      routes: {
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        DashboardScreen.routeName: (_) => const DashboardScreen(),
        ProfileInfoScreen.routeName: (_) => const ProfileInfoScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        TemplateSelectionScreen.routeName: (_) => const TemplateSelectionScreen(),
      },
    );
  }
}
 
