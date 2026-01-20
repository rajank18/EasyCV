import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EasyCV Dashboard')),
      body: const Center(
        child: Text('Welcome to EasyCV!'),
      ),
    );
  }
}
