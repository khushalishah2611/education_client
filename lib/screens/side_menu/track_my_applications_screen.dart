import 'package:education/core/image_url_helper.dart';
import 'package:education/services/application_api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../track_application_screen.dart';
import 'side_menu_common.dart';

class TrackMyApplicationsScreen extends StatefulWidget {
  const TrackMyApplicationsScreen({
    super.key,
    this.activeTab = false,
  });

  final bool activeTab;

  @override
  State<TrackMyApplicationsScreen> createState() =>
      _TrackMyApplicationsScreenState();
}

class _TrackMyApplicationsScreenState extends State<TrackMyApplicationsScreen> {
  final ApplicationApiService _api = const ApplicationApiService();

  bool _loading = true;

  List<Map<String, dynamic>> _apps = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final studentUserId = prefs.getString('studentUserId')?.trim() ?? '';

      final data = await _api.fetchStudentOverview(
        studentUserId: studentUserId,
      );

      final apps = data['applications'];

      if (!mounted) return;

      setState(() {
        _apps = [];

        if (apps is List) {
          _apps = apps.map<Map<String, dynamic>>((e) {
            final map = Map<String, dynamic>.from(e);

            final uni = Map<String, dynamic>.from(map['university'] ?? {});

            final program = Map<String, dynamic>.from(map['program'] ?? {});

            final selectedCourses = (map['selectedCourses'] is List)
                ? map['selectedCourses'] as List
                : [];

            final firstCourse = selectedCourses.isNotEmpty
                ? Map<String, dynamic>.from(selectedCourses.first)
                : {};

            return {
              // basic
              'id': map['id'] ?? '',
              'appId': map['id'] ?? '',
              'status': map['status'] ?? '',

              // university
              'universityName': uni['name'] ?? '',
              'logoPath': uni['logoPath'] ?? '',

              // program
              'programName': program['name'] ?? '',

              // selected course
              'college': firstCourse['college'] ?? '',
              'courseName': firstCourse['name'] ?? '',
            };
          }).toList();
        }

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _apps = [];
        _loading = false;
      });

      debugPrint(e.toString());
    }
  }

  // ✅ STATUS COLOR
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'NEW':
        return Colors.blue;

      case 'IN_PROGRESS':
        return Colors.orange;

      case 'ACCEPTED':
        return Colors.green;

      case 'ON_HOLD':
        return Colors.brown;

      case 'REJECTED':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: context.l10n.text('trackApplications'),
      showBackButton: widget.activeTab,
      child: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? _shimmerList()
            : _apps.isEmpty
                ? ListView(
                    children: [
                      _emptyState(context),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: _apps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _buildCard(
                        _apps[index],
                      );
                    },
                  ),
      ),
    );
  }

  // ✅ CARD UI
  Widget _buildCard(
    Map<String, dynamic> item,
  ) {
    final status = (item['status'] ?? '').toString().toUpperCase();

    final statusColor = _getStatusColor(status);

    final resolvedUniversityName = (item['universityName'] ?? '').toString();
    final resolvedCourseTitle = (item['courseName'] ?? '').toString();
    final appId = (item['id'] ?? '').toString();
    return InkWell(
      onTap: () {
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (_) => TrackApplicationScreen(
        //       universityName: resolvedUniversityName,
        //       universityHeroImage: (item['logoPath'] ?? '').toString(),
        //       courseTitle: resolvedCourseTitle,
        //       applicationId: appId,
        //       studentOverview: const <String, dynamic>{},
        //     ),
        //   ),
        // );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE0DDD8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${context.l10n.text('applicationId')} : #${(item['appId'] ?? '').toString().substring(0, 8)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      ImageUrlHelper.resolveUploadUrl(
                        item['logoPath'] ?? '',
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/logo.webp',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['universityName'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ✅ COLLEGE
                      Text(
                        '${item['college'] ?? ''} (${item['programName'] ?? ''})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // ✅ COURSE
                      Text(
                        item['courseName'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Divider(
              height: 1,
              color: Color(0xFFE0DDD8),
            ),

            const SizedBox(height: 10),

            // ✅ STATUS SECTION
            Row(
              children: [
                 Text(
                  context.l10n.text('applicationStatus'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(
                      0.12,
                    ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                    border: Border.all(
                      color: statusColor,
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🟡 SHIMMER
  Widget _shimmerList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: 10,
      itemBuilder: (_, __) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                height: 14,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 12,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Container(
                          height: 12,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Container(
                          height: 12,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔴 EMPTY STATE
  Widget _emptyState(
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE6E6E6),
        ),
      ),
      child:  Text(
        context.l10n.text('noApplicationsAvailable'),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF616161),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
