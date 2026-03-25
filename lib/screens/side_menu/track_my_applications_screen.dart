import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'side_menu_common.dart';

class TrackMyApplicationsScreen extends StatelessWidget {
  const TrackMyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final applications = [
      const ApplicationCardData(
        universityName: 'Harvard University',
        courseName: 'Bachelor of Computer Science',
        shortCode: 'HAR',
        appId: '#12345',
      ),
      const ApplicationCardData(
        universityName: 'Al-Ahliyya Amman University',
        courseName: 'Bachelor of Computer Science',
        shortCode: 'AAU',
        appId: '#12346',
      ),
      const ApplicationCardData(
        universityName: 'Beirut Arab University',
        courseName: 'Bachelor of Computer Science',
        shortCode: 'BAU',
        appId: '#12347',
      ),
    ];

    return SideMenuScaffold(
      title: 'Track My Applications',
      child: ListView.separated(
        itemCount: applications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = applications[index];

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
                Text(
                  'Application ID : ${item.appId}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.shortCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.universityName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.courseName,
                            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                    const Text(
                      'Application Progress',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F1F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ApplicationCardData {
  const ApplicationCardData({
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
