import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:animations/animations.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/profile/profile_info_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/ats/ats_checker_screen.dart';
import 'screens/templates/template_selection_screen.dart';
import 'screens/resume/resume_preview_screen.dart';
import 'services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/theme/app_theme.dart';
import 'core/theme/app_animations.dart';

//logo color - #0e5bbc , bg color - fromARGB(255, 248, 250, 255),

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    if (kIsWeb) {
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
    } else {
      await Firebase.initializeApp();
    }
  }
  
  // Initialize Notification Service (only on mobile)
  if (!kIsWeb) {
    try {
      await NotificationService().initialize();
      await NotificationService().scheduleWeeklyNotifications();
    } catch (e) {
      print('Notification initialization failed: $e');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic> _buildSharedAxisRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: AppAnimations.dur250,
      reverseTransitionDuration: AppAnimations.dur250,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          fillColor: AppColors.bgPrimary,
          child: child,
        );
      },
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case OnboardingScreen.routeName:
        return _buildSharedAxisRoute(const OnboardingScreen(), settings);
      case LoginScreen.routeName:
        return _buildSharedAxisRoute(const LoginScreen(), settings);
      case DashboardScreen.routeName:
        return _buildSharedAxisRoute(const DashboardScreen(), settings);
      case ATSCheckerScreen.routeName:
        return _buildSharedAxisRoute(const ATSCheckerScreen(), settings);
      case ProfileInfoScreen.routeName:
        return _buildSharedAxisRoute(const ProfileInfoScreen(), settings);
      case SettingsScreen.routeName:
        return _buildSharedAxisRoute(const SettingsScreen(), settings);
      case TemplateSelectionScreen.routeName:
        return _buildSharedAxisRoute(const TemplateSelectionScreen(), settings);
      case ResumePreviewScreen.routeName:
        final templateId = settings.arguments as String? ?? 'default';
        return _buildSharedAxisRoute(
          ResumePreviewScreen(templateId: templateId),
          settings,
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyCV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      initialRoute: OnboardingScreen.routeName,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
 
