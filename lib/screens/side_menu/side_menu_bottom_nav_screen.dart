import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'emergency_contact_screen.dart';
import 'latest_updates_screen.dart';
import 'track_my_applications_screen.dart';
import 'uploaded_documents_screen.dart';

class SideMenuBottomNavScreen extends StatefulWidget {
  const SideMenuBottomNavScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<SideMenuBottomNavScreen> createState() => _SideMenuBottomNavScreenState();
}

class _SideMenuBottomNavScreenState extends State<SideMenuBottomNavScreen> {
  late int _currentIndex;

  final _tabs = const [
    _BottomTabConfig(label: 'My Applications', page: TrackMyApplicationsContent()),
    _BottomTabConfig(label: 'My Documents', page: UploadedDocumentsContent()),
    _BottomTabConfig(label: 'Latest Updates', page: LatestUpdatesScreen()),
    _BottomTabConfig(label: 'Emergency Contact', page: EmergencyContactContent()),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 78,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabs[_currentIndex].label,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _tabs.map((tab) => tab.page).toList(growable: false),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (value) => setState(() => _currentIndex = value),
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'My Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'My Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            label: 'Latest Updates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Emergency',
          ),
        ],
      ),
    );
  }
}

class _BottomTabConfig {
  const _BottomTabConfig({required this.label, required this.page});

  final String label;
  final Widget page;
}
