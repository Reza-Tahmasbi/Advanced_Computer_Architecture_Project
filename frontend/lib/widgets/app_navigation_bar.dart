// lib/widgets/app_navigation_bar.dart
import 'package:flutter/material.dart';
import 'dart:io' show exit, File;
import 'package:file_picker/file_picker.dart';
import 'package:frontend/screens/dashboard/dashboard_screen.dart';
import 'package:frontend/screens/about/about_screen.dart';
import 'package:frontend/screens/scenario/create_scenario_screen.dart';
import 'package:frontend/models/scenario_store.dart';

class AppNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavigationBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0.5,
      title: const SizedBox.shrink(),
      centerTitle: false,
      actions: [
        // ----- Logo (left of menus) -----
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Image.asset(
              'assets/images/logo4.png',
              height: 76,
              width: 76,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.school,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),

        // ----- File Menu -----
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'File',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem<String>(child: Text("New Scenario"), value: 'new'),
            const PopupMenuItem<String>(child: Text("Open..."), value: 'open'),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(child: Text("Exit"), value: 'exit'),
          ],
          onSelected: (value) => _handleMenuSelection(value, context),
        ),

        // ----- Tools Menu -----
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Tools',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem<String>(child: Text("Quiz"), value: 'quiz'),
          ],
          onSelected: (value) => _handleMenuSelection(value, context),
        ),

        // ----- Help Menu -----
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Help',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem<String>(child: Text("Documentation"), value: 'doc'),
            const PopupMenuItem<String>(child: Text("About"), value: 'about'),
          ],
          onSelected: (value) => _handleMenuSelection(value, context),
        ),

        const Spacer(),
      ],
    );
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'new':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateScenarioScreen()),
        );
        break;
      case 'open':
        _openScenarioFile(context);
        break;
      case 'exit':
        exit(0);
        break;
      case 'quiz':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz feature coming soon!')),
        );
        break;
      case 'doc':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documentation coming soon!')),
        );
        break;
      case 'about':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutScreen()),
        );
        break;
    }
  }

  Future<void> _openScenarioFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['aca'],
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.single.path;
        if (filePath != null) {
          final file = File(filePath);
          final content = await file.readAsString();
          ScenarioStore().importScenarioFromJson(content);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scenario imported successfully!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading file: $e')),
      );
    }
  }
}