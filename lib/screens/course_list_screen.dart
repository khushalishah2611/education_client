import 'package:education/core/app_localizations.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({
    super.key,
    required this.university,

  });

  final UniversityData university;


  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  int? _activeTab;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _RoundIconButton(
                              icon: Icons.menu_rounded,
                              onTap: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                            ),
                            const Spacer(),
                            const AppLogo(compact: true, center: true),
                            const Spacer(),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(
                                  Icons.notifications_none_rounded,
                                  size: 26,
                                ),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
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
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                      ),
                      child: GridView.builder(
                        itemCount: _isLoading ? 6 : courseCatalog.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.75,
                            ),
                        itemBuilder: (context, index) {
                          if (_isLoading) {
                            return const _CourseCardShimmer();
                          }
                          final course = courseCatalog[index];
                          return _CourseCard(
                            course: course,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CourseDetailScreen(
                                  university: widget.university,
                                  course: course,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  BottomTabBarCard(
                    activeIndex: _activeTab,
                    onTap: (index) async {
                      setState(() => _activeTab = index);
                    },
                  ),
                ],
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
              errorBuilder: (_, __, ___) =>
                  Container(height: 112, color: const Color(0xFFE7E7E7)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            course.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 13,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  course.duration,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Text(
                course.fee,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 26),
      ),
    );
  }
}

class _CourseCardShimmer extends StatelessWidget {
  const _CourseCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE9E2D7)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBlock(height: 112, borderRadius: 8),
          SizedBox(height: 8),
          _ShimmerBlock(height: 14, width: 120, borderRadius: 4),
          SizedBox(height: 6),
          _ShimmerBlock(height: 14, width: 90, borderRadius: 4),
          SizedBox(height: 8),
          Row(
            children: [
              _ShimmerCircle(size: 13),
              SizedBox(width: 5),
              Expanded(child: _ShimmerBlock(height: 10, borderRadius: 4)),
              SizedBox(width: 8),
              _ShimmerBlock(height: 10, width: 42, borderRadius: 4),
            ],
          ),
          Spacer(),
          _ShimmerBlock(height: 36, borderRadius: 8),
        ],
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
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
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final width = bounds.width == 0 ? 1 : bounds.width;
            final offset = (_controller.value * 2 * width) - width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE6E6E6),
                Color(0xFFF4F4F4),
                Color(0xFFE6E6E6),
              ],
              stops: const [0.1, 0.45, 0.9],
              transform: GradientTranslation(offset, 0),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({
    required this.height,
    this.width,
    this.borderRadius = 6,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFEAEAEA),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  const _ShimmerCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFEAEAEA),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
