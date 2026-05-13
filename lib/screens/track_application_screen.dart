import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_localizations.dart';
import '../core/image_url_helper.dart';
import '../core/responsive_helper.dart';
import '../core/app_theme.dart';
import '../services/application_api_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'home_screen.dart';

class TrackApplicationScreen extends StatefulWidget {
  const TrackApplicationScreen({
    super.key,
    this.universityName,
    this.universityHeroImage,
    this.courseTitle,
    this.applicationId,
    this.studentOverview,
  });

  final String? universityName;
  final String? universityHeroImage;
  final String? courseTitle;
  final String? applicationId;
  final Map<String, dynamic>? studentOverview;

  @override
  State<TrackApplicationScreen> createState() => _TrackApplicationScreenState();
}

class _TrackApplicationScreenState extends State<TrackApplicationScreen> {
  final ApplicationApiService _applicationApiService =
      const ApplicationApiService();

  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  Map<String, dynamic>? _studentOverview;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _studentOverview = widget.studentOverview;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_studentOverview == null) {
        _fetchStudentOverview();
      }
    });
  }

  Future<void> _fetchStudentOverview({
    bool isRefresh = false,
  }) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String studentUserId =
          prefs.getString('studentUserId')?.trim() ?? '';

      if (studentUserId.isEmpty) {
        throw Exception('Student user id not found');
      }

      final Map<String, dynamic> overview =
          await _applicationApiService.fetchStudentOverview(
        studentUserId: studentUserId,
      );

      if (!mounted) return;

      setState(() {
        _studentOverview = overview;
      });

      if (isRefresh) {
        showAppSnackBar(
          context,
          type: AppSnackBarType.success,
          message: 'Application data refreshed successfully',
        );
      }
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        type: AppSnackBarType.error,
        message: e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    await _fetchStudentOverview(isRefresh: true);
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  List<Map<String, dynamic>> get _applications =>
      _listFromOverview('applications');

  List<Map<String, dynamic>> get _payments => _listFromOverview('payments');

  List<Map<String, dynamic>> get _documents => _listFromOverview('documents');

  List<Map<String, dynamic>> _listFromOverview(
    String key,
  ) {
    final Object? items = _studentOverview?[key];

    if (items is! List) {
      return const <Map<String, dynamic>>[];
    }

    return items
        .whereType<Map>()
        .map(
          (item) => item.map(
            (key, value) => MapEntry(
              key.toString(),
              value,
            ),
          ),
        )
        .toList(growable: false);
  }

  Map<String, dynamic>? get _application {
    final String selectedApplicationId = widget.applicationId?.trim() ?? '';

    for (final Map<String, dynamic> application in _applications) {
      if (selectedApplicationId.isNotEmpty &&
          _textFrom(application['id']) == selectedApplicationId) {
        return application;
      }
    }

    return _applications.isNotEmpty ? _applications.first : null;
  }

  Map<String, dynamic>? get _payment {
    final String selectedApplicationId = _textFrom(_application?['id']);

    for (final Map<String, dynamic> payment in _payments) {
      if (selectedApplicationId.isNotEmpty &&
          _textFrom(payment['applicationId']) == selectedApplicationId) {
        return payment;
      }
    }

    return _payments.isNotEmpty ? _payments.first : null;
  }

  String get _applicationId {
    final String id =
        _textFrom(_application?['id']).ifEmpty(widget.applicationId);

    return id.isEmpty ? '-' : '#${_shortId(id)}';
  }

  String get _universityName {
    final Object? university = _application?['university'];

    if (university is Map) {
      final String name = _textFrom(university['name']);

      if (name.isNotEmpty) {
        return name;
      }
    }

    return widget.universityName ?? context.l10n.text('university');
  }

  String get _heroImage {
    if (widget.universityHeroImage?.trim().isNotEmpty == true) {
      return widget.universityHeroImage!.trim();
    }

    final Object? university = _application?['university'];

    if (university is Map) {
      final String coverImagePath = _textFrom(university['coverImagePath']);

      if (coverImagePath.isNotEmpty) {
        return ImageUrlHelper.resolveUploadUrl(
          coverImagePath,
        );
      }
    }

    return 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?auto=format&fit=crop&w=1200&q=80';
  }

  String get _courseTitle {
    if (widget.courseTitle?.trim().isNotEmpty == true) {
      return widget.courseTitle!.trim();
    }

    final Object? selectedCourses = _application?['selectedCourses'];

    if (selectedCourses is List && selectedCourses.isNotEmpty) {
      final Object? selectedCourse = selectedCourses.first;

      if (selectedCourse is Map) {
        final String name = _textFrom(selectedCourse['name']);

        if (name.isNotEmpty) {
          return name;
        }

        final String courseName = _textFrom(selectedCourse['courseName']);

        if (courseName.isNotEmpty) {
          return courseName;
        }
      }
    }

    final Object? program = _application?['program'];

    if (program is Map) {
      final String programName = _textFrom(program['name']);

      if (programName.isNotEmpty) {
        return programName;
      }
    }

    return context.l10n.text(
      'courseOrProgram',
    );
  }

  String get _educationInstitute {
    final Object? selectedCourses = _application?['selectedCourses'];

    if (selectedCourses is List && selectedCourses.isNotEmpty) {
      final Object? selectedCourse = selectedCourses.first;

      if (selectedCourse is Map) {
        final String educationInstitute = _textFrom(
          selectedCourse['educationInstitute'],
        );

        if (educationInstitute.isNotEmpty) {
          return educationInstitute;
        }
      }
    }

    return '-';
  }

  String get _status => _textFrom(_application?['status']).ifEmpty('NEW');

  List<Map<String, dynamic>> get _applicationHistory {
    final Object? history = _application?['history'];

    if (history is! List) {
      return const <Map<String, dynamic>>[];
    }

    final List<Map<String, dynamic>> items = history
        .whereType<Map>()
        .map(
          (item) => item.map(
            (key, value) => MapEntry(
              key.toString(),
              value,
            ),
          ),
        )
        .toList(growable: true);

    items.sort((a, b) {
      final DateTime? aDate = DateTime.tryParse(
        _textFrom(a['createdAt']),
      );

      final DateTime? bDate = DateTime.tryParse(
        _textFrom(b['createdAt']),
      );

      if (aDate == null && bDate == null) {
        return 0;
      }

      if (aDate == null) {
        return -1;
      }

      if (bDate == null) {
        return 1;
      }

      return aDate.compareTo(bDate);
    });

    return items;
  }

  String get _latestStatusFromHistory {
    for (final Map<String, dynamic> item in _applicationHistory.reversed) {
      final String status = _textFrom(item['status']);

      if (status.isNotEmpty) {
        return status;
      }
    }

    return _status;
  }

  String get _latestStatusComment {
    for (final Map<String, dynamic> item in _applicationHistory.reversed) {
      final String comment = _textFrom(item['comment']);

      if (comment.isNotEmpty) {
        return comment;
      }
    }

    return '';
  }

  int get _progressIndex {
    switch (_latestStatusFromHistory) {
      case 'NEW':
        return 1;

      case 'IN_PROCESS':
      case 'UNDER_REVIEW':
      case 'ON_HOLD':
        return 2;

      case 'ACCEPTED':
      case 'REJECTED':
        return 4;

      default:
        return 1;
    }
  }

  _StepState _stateForStep(int stepIndex) {
    if (_progressIndex > stepIndex) {
      return _StepState.done;
    }

    if (_progressIndex == stepIndex) {
      return _StepState.active;
    }

    return _StepState.pending;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;

    final double horizontalPadding = context.responsiveHorizontalPadding;

    return WillPopScope(
      onWillPop: () async {
        _goHome();
        return false;
      },
      child: Scaffold(
        body: AppBackground(
          child: AppPageEntrance(
            child: Column(
              children: [
                TopRoundedHeader(
                  title: context.l10n.text('trackApplication'),
                  onBack: _goHome,
                ),
                Expanded(
                  child: RefreshIndicator(
                    key: refreshIndicatorKey,
                    onRefresh: _onRefresh,
                    child: _isLoading && _studentOverview == null
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              isSmallMobile ? 14 : 18,
                              horizontalPadding,
                              20,
                            ),
                            children: const [
                              _TrackApplicationShimmer(),
                            ],
                          )
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              isSmallMobile ? 14 : 18,
                              horizontalPadding,
                              20,
                            ),
                            children: [
                              _ApplicationOverviewCard(
                                applicationId: _applicationId,
                                universityName: _universityName,
                                courseTitle: _courseTitle,
                                educationInstitute: _educationInstitute,
                                universityHeroImage: _heroImage,
                                isSmallMobile: isSmallMobile,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Application Status : ${_latestStatusFromHistory.replaceAll('_', ' ').trim()}',
                                style: TextStyle(
                                  fontSize: isSmallMobile ? 16 : 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _ProgressStep(
                                title: context.l10n.text(
                                  'submitted',
                                ),
                                subtitle: 'Application Submitted',
                                state: _StepState.done,
                                showLine: true,
                              ),
                              _ProgressStep(
                                title: context.l10n.text(
                                  'underReview',
                                ),
                                subtitle: _latestStatusComment.isNotEmpty
                                    ? _latestStatusComment
                                    : 'Application under review',
                                state: _stateForStep(2),
                                showLine: true,
                              ),
                              _ProgressStep(
                                title: context.l10n.text(
                                  'documentsVerified',
                                ),
                                subtitle: 'Documents verification process',
                                state: _stateForStep(3),
                                showLine: true,
                              ),
                              _ProgressStep(
                                title: context.l10n.text(
                                  'acceptedRejected',
                                ),
                                subtitle: _latestStatusFromHistory.replaceAll(
                                  '_',
                                  ' ',
                                ),
                                state: _stateForStep(4),
                                showLine: false,
                              ),
                              const SizedBox(height: 24),
                            ],
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

  static String _textFrom(Object? value) => value?.toString().trim() ?? '';

  static String _shortId(String id) => id.length > 8 ? id.substring(0, 8) : id;
}

class _ApplicationOverviewCard extends StatelessWidget {
  const _ApplicationOverviewCard({
    required this.applicationId,
    required this.universityName,
    required this.courseTitle,
    required this.educationInstitute,
    required this.universityHeroImage,
    required this.isSmallMobile,
  });

  final String applicationId;
  final String universityName;
  final String courseTitle;
  final String educationInstitute;
  final String universityHeroImage;
  final bool isSmallMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE8E2D9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application ID: $applicationId',
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 10),
          Text(
            universityName,
            style: TextStyle(
              fontSize: isSmallMobile ? 16 : 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.school_outlined,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  courseTitle,
                  style: TextStyle(
                    fontSize: isSmallMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            educationInstitute,
            style: TextStyle(
              fontSize: isSmallMobile ? 13 : 14,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              universityHeroImage,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return AppShimmer(
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                height: 150,
                color: const Color(0xFFE2E2E2),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackApplicationShimmer extends StatelessWidget {
  const _TrackApplicationShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 20,
            width: 180,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(
                bottom: 24,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 180,
                          color: Colors.white,
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
    );
  }
}

class AppShimmer extends StatefulWidget {
  final Widget child;

  const AppShimmer({
    super.key,
    required this.child,
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0, -0.3),
              end: Alignment(1.0, 0.3),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [
                0.1,
                0.3,
                0.4,
              ],
              transform: SlidingGradientTransform(
                slide: _controller.value,
              ),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SlidingGradientTransform extends GradientTransform {
  final double slide;

  const SlidingGradientTransform({
    required this.slide,
  });

  @override
  Matrix4 transform(
    Rect bounds, {
    TextDirection? textDirection,
  }) {
    return Matrix4.translationValues(
      bounds.width * (slide * 2 - 1),
      0,
      0,
    );
  }
}

enum _StepState {
  done,
  active,
  pending,
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.title,
    required this.subtitle,
    required this.state,
    required this.showLine,
  });

  final String title;
  final String subtitle;
  final _StepState state;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _StepState.done => const Color(0xFF0E9F58),
      _StepState.active => AppColors.accent,
      _StepState.pending => const Color(0xFF777777),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 300,
                ),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: state == _StepState.active ? Colors.white : color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: 3,
                  ),
                ),
                child: state == _StepState.done
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              if (showLine)
                Container(
                  width: 2,
                  height: 42,
                  color: state == _StepState.pending
                      ? const Color(
                          0xFFD7D7D7,
                        )
                      : const Color(
                          0xFF0E9F58,
                        ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: state == _StepState.pending
                        ? const Color(
                            0xFF777777,
                          )
                        : AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

extension _StringFallback on String {
  String ifEmpty(String? fallback) {
    return isEmpty ? (fallback ?? '') : this;
  }
}
