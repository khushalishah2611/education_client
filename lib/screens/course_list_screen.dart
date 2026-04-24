import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common_widgets.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/flow_widgets.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key, required this.university});

  final UniversityData university;

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  int? _activeTab;

  static const double _tableWidth = 740;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: Row(
                      children: [
                        RoundIconButton(
                          icon: Icons.menu_rounded,
                          onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                        const Spacer(),
                        const AppLogo(compact: true, center: true),
                        const Spacer(),
                        const Icon(Icons.notifications_none_rounded, size: 24),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFDCDCDC)),
                        ),
                        child: Column(
                          children: [
                            _buildSectionTitle(context),
                            _buildHeaderRow(context),
                            Expanded(
                              child: _isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : _buildCoursesBody(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  BottomTabBarCard(
                    activeIndex: _activeTab,
                    onTap: (index) => setState(() => _activeTab = index),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.university.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7C7C7C),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.keyboard_arrow_up_rounded),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: _tableWidth,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        color: const Color(0xFFE6E6E6),
        child: const Row(
          children: [
            _HeaderCell(title: 'Course', flex: 31),
            _HeaderCell(title: 'Credit\nHour Fee', flex: 16),
            _HeaderCell(title: 'Min\nAdmis%', flex: 14),
            _HeaderCell(title: 'Track', flex: 18),
            _HeaderCell(title: 'Details\n/ Apply', flex: 21),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _tableWidth,
        child: ListView.separated(
          itemCount: courseCatalog.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final course = courseCatalog[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 31,
                    child: Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 31 / 2,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 16,
                    child: Text(
                      '45\nJOD',
                      style: TextStyle(
                        fontSize: 14,
                        color: index == 0 ? Colors.blue[900] : Colors.black,
                        decoration: index == 0
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 14,
                    child: Text(
                      '80%',
                      style: TextStyle(fontSize: 28 / 2),
                    ),
                  ),
                  Expanded(
                    flex: 18,
                    child: Text(
                      'SCIENTIFIC',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 21,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Details ›',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFAEE9C9),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Apply & Pay\nApplication Fee',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.05,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.title, required this.flex});

  final String title;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}
