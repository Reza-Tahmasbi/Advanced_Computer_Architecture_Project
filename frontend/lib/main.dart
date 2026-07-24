import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'core/theme.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'models/scenario_store.dart'; // <-- new import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved scenarios before the app starts
  await ScenarioStore().init();

  appWindow.minSize = const Size(800, 600);
  appWindow.maxSize = const Size(1920, 1080);
  appWindow.title = 'Dynamic Instruction Scheduling Simulator';
  appWindow.show();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ACASimulatorApp());
}

class ACASimulatorApp extends StatelessWidget {
  const ACASimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Instruction Scheduling Simulator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
      builder: (context, child) {
        return WindowBorder(
          color: Colors.black,
          width: 1,
          child: child!,
        );
      },
    );
  }
}