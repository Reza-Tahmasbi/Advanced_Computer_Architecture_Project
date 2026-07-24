// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo3.png",   // ← make sure path is correct
                    width: 500,
                    height: 350,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.school_rounded,
                      size: 180,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "Advanced Computer Architecture Project",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Dynamic Instruction Scheduling Simulator",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 250,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DashboardScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Start Learning",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}