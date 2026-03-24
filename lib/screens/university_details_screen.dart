import 'package:flutter/material.dart';

import '../models/university.dart';
import '../widgets/common_widgets.dart';
import '../widgets/info_tile.dart';
import '../widgets/round_icon_button.dart';

class UniversityDetailsScreen extends StatelessWidget {
  const UniversityDetailsScreen({super.key, required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppPageEntrance(
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 330,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        university.themeColor.withOpacity(0.82),
                        university.themeColor.withOpacity(0.50),
                        const Color(0xFFFFF8F2),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              RoundIconButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onTap: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  university.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                color: Colors.white.withOpacity(0.18),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.18),
                                            Colors.transparent,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Icon(
                                      Icons.apartment_rounded,
                                      size: 130,
                                      color: Colors.white.withOpacity(0.92),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -36,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: university.accentColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              university.shortCode,
                              style: TextStyle(
                                color: university.themeColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFF6B31A),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${university.rating.toStringAsFixed(1)} (2.4k reviews)',
                                    style: const TextStyle(
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                university.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: Color(0xFF666666),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    university.location,
                                    style: const TextStyle(
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 58),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${university.about} Read More',
                    style: const TextStyle(
                      height: 1.5,
                      fontSize: 15,
                      color: Color(0xFF6F6F6F),
                    ),
                  ),
                  const SizedBox(height: 18),
                  InfoTile(
                    icon: Icons.workspace_premium_rounded,
                    iconColor: const Color(0xFFF1B91B),
                    title: 'Ranking Info',
                    subtitle: 'Ranking',
                    value: university.ranking,
                  ),
                  const SizedBox(height: 14),
                  InfoTile(
                    icon: Icons.calendar_month_rounded,
                    iconColor: const Color(0xFFF29A38),
                    title: 'Upcoming Intake',
                    subtitle: university.intake,
                    value: university.degreeInfo,
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
      bottomSheet: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF95E1B0),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'View Courses',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}
