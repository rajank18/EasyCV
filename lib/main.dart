import 'package:flutter/material.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/profile/profile_info_screen.dart';

//logo color - #0e5bbc , bg color - fromARGB(255, 248, 250, 255),

void main() {
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
        DashboardScreen.routeName: (_) => const DashboardScreen(),
        ProfileInfoScreen.routeName: (_) => const ProfileInfoScreen(),
      },
    );
  }
}
 
