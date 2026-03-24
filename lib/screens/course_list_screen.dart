import 'package:education/core/app_localizations.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key, required this.university});

  final UniversityData university;

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const CommonSideMenu(),
        body: AppBackground(
          child: AppPageEntrance(
            child: SafeArea(
              child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _RoundIconButton(icon: Icons.menu_rounded, onTap: () => _scaffoldKey.currentState?.openDrawer()),
                      const Spacer(),
                      const AppLogo(compact: true, center: true),
                      const Spacer(),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications_none_rounded, size: 26),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10))),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: context.l10n.text('cityOrCollege'),
                    hint: context.l10n.text('searchHint'),
                    height: 45,
                  ),

                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      itemCount: courseCatalog.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final course = courseCatalog[index];
                        return _CourseCard(
                          course: course,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CourseDetailScreen(university: widget.university, course: course),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const BottomTabBarCard(),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final CourseData course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE9E2D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              course.image,
              height: 112,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 112, color: const Color(0xFFE7E7E7)),
            ),
          ),
          const SizedBox(height: 8),
          Text(course.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 3),
              Expanded(child: Text(course.duration, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted))),
              Text(course.fee, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.text,
                minimumSize: const Size.fromHeight(36),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 26),
      ),
    );
  }
}
