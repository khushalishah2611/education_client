import 'package:education/core/image_url_helper.dart';
import 'package:education/services/application_api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/url_launcher_helper.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../core/bloc/app_cubit.dart';
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

class _TrackMyApplicationsScreenState extends State<TrackMyApplicationsScreen>
    with CubitStateMixin<TrackMyApplicationsScreen> {
  final ApplicationApiService _api = const ApplicationApiService();

  bool _loading = true;

  List<Map<String, dynamic>> _apps = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    updateView(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final studentUserId = prefs.getString('studentUserId')?.trim() ?? '';

      final data = await _api.fetchStudentOverview(
        studentUserId: studentUserId,
      );

      final apps = data['applications'];

      if (!mounted) return;

      updateView(() {
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
              'universityNameAr': uni['nameAr'] ?? '',
              'logoPath': uni['logoPath'] ?? '',

              // program
              'programName': program['academicProgram'] ?? '',
              'programNameAr': program['academicProgramAr'] ?? '',

              // selected course
              'college': firstCourse['college'] ?? '',
              'courseName': firstCourse['name'] ?? '',
              'courseNameAr': firstCourse['nameAr'] ?? '',
              'coursePrice':
                  firstCourse['basePrice'] ?? firstCourse['totalCost'] ?? '',
              'courseCurrency':
                  firstCourse['currency'] ?? firstCourse['currencyCode'] ?? '',
              // extra details
              'history': map['history'] ?? [],
              'offerLetterPath': map['offerLetterPath'] ?? '',
              'decisionLetterPath': map['decisionLetterPath'] ?? '',
              'applicationFeeCurrency':
                  map['applicationFeeCurrency'] ?? map['currency'] ?? '',
              'selectedApplicationFeeTotal':
                  map['selectedApplicationFeeTotal'] ??
                      map['applicationFee'] ??
                      0,
            };
          }).toList();
        }

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      updateView(() {
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

      case 'IN_PROCESS':
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
    return buildCubitView(
      (context) => SideMenuScaffold(
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
      ),
    );
  }

  // ✅ CARD UI
  Widget _buildCard(
    Map<String, dynamic> item,
  ) {
    final status = (item['status'] ?? '').toString().toUpperCase();

    final statusColor = _getStatusColor(status);

    return InkWell(
      onTap: () => _showApplicationDetails(context, item),
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
                        _localizedLabel(context, item['universityName'],
                            item['universityNameAr']),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '${(item['college'] ?? '')} (${_localizedLabel(context, item['programName'], item['programNameAr'])})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // ✅ COURSE
                      Text(
                        _localizedLabel(
                            context, item['courseName'], item['courseNameAr']),
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
                    _getStatusLabel(context, status),
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

  String _getStatusLabel(BuildContext context, String status) {
    final s = status.toUpperCase();

    const ar = {
      'NEW': 'جديد',
      'IN_PROGRESS': 'قيد المعالجة',
      'IN_PROCESS': 'قيد المعالجة',
      'ACCEPTED': 'مقبول',
      'ON_HOLD': 'معلق',
      'REJECTED': 'مرفوض',
    };

    final english = (() {
      switch (s) {
        case 'NEW':
          return 'New';
        case 'IN_PROGRESS':
        case 'IN_PROCESS':
          return 'In Progress';
        case 'ACCEPTED':
          return 'Accepted';
        case 'ON_HOLD':
          return 'On Hold';
        case 'REJECTED':
          return 'Rejected';
        default:
          return s;
      }
    })();

    final isArabic =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

    if (isArabic) {
      return ar[s] ?? english;
    }

    return english;
  }

  String _localizedLabel(
    BuildContext context,
    Object? enObj,
    Object? arObj,
  ) {
    final en = (enObj ?? '').toString();
    final ar = (arObj ?? '').toString();

    final isArabic =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

    if (isArabic) {
      return ar.isNotEmpty ? ar : en;
    }

    return en.isNotEmpty ? en : ar;
  }

  void _showApplicationDetails(
      BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        final history =
            (item['history'] is List) ? item['history'] as List : [];
        final offer = (item['offerLetterPath'] ?? '').toString();
        final decision = (item['decisionLetterPath'] ?? '').toString();
        final fee = item['selectedApplicationFeeTotal']?.toString() ?? '';

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, ctl) {
            return SingleChildScrollView(
              controller: ctl,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _localizedLabel(context, item['universityName'],
                          item['universityNameAr']),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${(item['college'] ?? '')} (${_localizedLabel(context, item['programName'], item['programNameAr'])})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _localizedLabel(
                          context, item['courseName'], item['courseNameAr']),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '${context.l10n.text('applicationFee')}: $fee ${context.l10n.text('omaniRial')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(context.l10n.text('applicationHistory'),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    if (history.isEmpty)
                      Text(context.l10n.text('noApplicationHistory'))
                    else
                      ...history.map<Widget>((h) {
                        final hm = Map<String, dynamic>.from(h ?? {});
                        final hs =
                            (hm['status'] ?? '').toString().toUpperCase();
                        final comment = hm['comment'] ?? '';
                        final date = hm['createdAt'] ?? '';
                        String formattedDate = '';

                        if (date != null && date.toString().isNotEmpty) {
                          formattedDate = DateFormat('d MMMM yyyy, h:mm a')
                              .format(
                                  DateTime.parse(date.toString()).toLocal());
                        }
                        return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(_getStatusLabel(context, hs)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((comment ?? '').toString().isNotEmpty)
                                  Text(comment.toString()),
                                if ((formattedDate ?? '').toString().isNotEmpty)
                                  Text(formattedDate.toString(),
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black54)),
                              ],
                            ));
                      }),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(context.l10n.text('applicationLetter'),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    if (offer.isEmpty && decision.isEmpty)
                      Text(context.l10n.text('noDocumentsUploaded'))
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (offer.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: const Color(0xFFE0DDD8)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.description_outlined),
                                title: Text(context.l10n.text('offerLetter')),
                                trailing: const Icon(Icons.open_in_new),
                                onTap: () async {
                                  final url =
                                      ImageUrlHelper.resolveUploadUrl(offer);

                                  debugPrint('Offer Letter URL: $url');

                                  await openExternalLink(url);
                                },
                              ),
                            ),
                          if (decision.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: const Color(0xFFE0DDD8)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.description_outlined),
                                title:
                                    Text(context.l10n.text('decisionLetter')),
                                trailing: const Icon(Icons.open_in_new),
                                onTap: () async {
                                  final url =
                                      ImageUrlHelper.resolveUploadUrl(decision);

                                  debugPrint('Decision Letter URL: $url');

                                  await openExternalLink(url);
                                },
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
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
      child: Text(
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
