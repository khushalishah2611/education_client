import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'course_list_screen.dart';

class UniversityDetailScreen extends StatelessWidget {
  const UniversityDetailScreen({super.key, required this.data});

  final UniversityData data;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: AppBackground(
          child: AppPageEntrance(
            child: Column(
              children: [
              TopRoundedHeader(title: data.name),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 250,
                            width: double.infinity,
                            child: Image.network(
                              data.heroImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE2E2E2)),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: -8,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 18, offset: Offset(0, 8))],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(10)),
                                    alignment: Alignment.center,
                                    child: Text(data.shortCode, style: TextStyle(color: data.color, fontWeight: FontWeight.w900, fontSize: 18)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.star, color: Color(0xFFFFB300), size: 16),
                                            SizedBox(width: 4),
                                            Text('4.6', style: TextStyle(fontWeight: FontWeight.w700)),
                                            SizedBox(width: 4),
                                            Text('(2.4k reviews)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(data.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted),
                                            const SizedBox(width: 2),
                                            Text(data.location, style: const TextStyle(color: AppColors.textMuted)),
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
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Arcu, arcu dictumst habitant vel ut et pellentesque. Ut in egestas blandit netus in scelerisque. Eget lectus ultrices pellentesque id...Read More',
                          style: TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.35),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _InfoTile(
                          icon: Icons.verified_outlined,
                          iconBg: Color(0xFFFFF2CC),
                          title: 'Ranking Info',
                          value: 'Ranking',
                          subtitle: '#3 worldwide (2026)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _InfoTile(
                          icon: Icons.calendar_month_outlined,
                          iconBg: Color(0xFFFFF1DF),
                          title: 'Upcoming Intake',
                          value: 'September 2026',
                          subtitle: '12th pass / Bachelor’s Degree',
                        ),
                      ),
                      const SizedBox(height: 130),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: AppPrimaryButton(
                  label: 'View Courses',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CourseListScreen(university: data)),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E3DB)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFFE09B2D)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
