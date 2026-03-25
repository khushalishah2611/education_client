import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/flow_widgets.dart';
import 'home_screen.dart';

class TrackApplicationScreen extends StatelessWidget {
  const TrackApplicationScreen({super.key, required this.university, required this.course});

  final UniversityData university;
  final CourseData course;

  @override
  Widget build(BuildContext context) {
    final applications = [
      _ApplicationCardData(universityName: university.name, courseName: course.title, shortCode: _extractCode(university.name), appId: '#12345'),
      const _ApplicationCardData(universityName: 'Al-Ahliyya Amman University', courseName: 'Bachelor of Computer Science', shortCode: 'AAU', appId: '#12345'),
      const _ApplicationCardData(universityName: 'Beirut Arab University', courseName: 'Bachelor of Computer Science', shortCode: 'BAU', appId: '#12345'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4EFE8),
      body: SafeArea(
        child: Column(
          children: [
            TopRoundedHeader(
              title: 'Track My Applications',
              onBack: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              ),
            ),
            Expanded(
              child: AppPageEntrance(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
                  itemBuilder: (_, index) => _TrackApplicationCard(data: applications[index]),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: applications.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractCode(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return 'UNI';
    if (words.length == 1) return words.first.characters.take(3).toString().toUpperCase();
    return words.take(3).map((word) => word.characters.first.toUpperCase()).join();
  }
}

class _TrackApplicationCard extends StatelessWidget {
  const _TrackApplicationCard({required this.data});

  final _ApplicationCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0DDD8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Application ID : ${data.appId}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                child: Text(data.shortCode, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.universityName, style: const TextStyle(fontSize: 25 / 1.5, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(data.courseName, style: const TextStyle(fontSize: 23 / 1.5, color: AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE0DDD8)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Application Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(color: Color(0xFFF1F1F1), shape: BoxShape.circle),
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplicationCardData {
  const _ApplicationCardData({
    required this.universityName,
    required this.courseName,
    required this.shortCode,
    required this.appId,
  });

  final String universityName;
  final String courseName;
  final String shortCode;
  final String appId;
}
