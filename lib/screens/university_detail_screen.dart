import 'package:education/core/app_localizations.dart';
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
    final List<InfoItem> _infoList = [
      InfoItem(
        icon: Icons.verified_outlined,
        iconBg: const Color(0xFFFFF2CC),
        title: 'Ranking Info',
        value: 'Ranking',
        subtitle: '#3 worldwide (2026)',
      ),
      InfoItem(
        icon: Icons.calendar_month_outlined,
        iconBg: const Color(0xFFFFF1DF),
        title: 'Upcoming Intake',
        value: 'September 2026',
        subtitle: '12th pass / Bachelor’s Degree',
      ),
    ];
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: AppBackground(
          child: Column(
            children: [

              /// 🔹 TOP HEADER (FIXED)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    child: SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Image.network(
                        data.heroImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE2E2E2),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: -24,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              data.shortCode,
                              style: TextStyle(
                                color: data.color,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Color(0xFFFFB300), size: 16),
                                    SizedBox(width: 4),
                                    Text('4.6',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(width: 4),
                                    Text('(2.4k reviews)',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMuted)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 15,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      data.location,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
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

                  TopRoundedHeader(title: data.name),
                ],
              ),

              const SizedBox(height: 40),

              /// 🔥 SCROLLABLE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'About',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: ReadMoreText(
                          text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                              'Arcu, arcu dictumst habitant vel ut et pellentesque. '
                              'Ut in egestas blandit netus in scelerisque. '
                              'Eget lectus ultrices pellentesque id...',
                        ),
                      ),
                      const SizedBox(height: 16),


                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: List.generate(_infoList.length, (index) {
                            final item = _infoList[index];

                            return Padding(
                              padding: EdgeInsets.only(bottom: index == _infoList.length - 1 ? 0 : 12),
                              child: _InfoTile(
                                icon: item.icon,
                                iconBg: item.iconBg,
                                title: item.title,
                                value: item.value,
                                subtitle: item.subtitle,
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 100), // 👈 space for button
                    ],
                  ),
                ),
              ),

              /// 🔹 BOTTOM BUTTON (FIXED)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: AppPrimaryButton(
                  label: context.l10n.text('viewCourses'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CourseListScreen(university: data),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class InfoItem {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String value;
  final String subtitle;

  InfoItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.subtitle,
  });
}
class ReadMoreText extends StatefulWidget {
  const ReadMoreText({
    super.key,
    required this.text,
    this.trimLines = 3,
  });

  final String text;
  final int trimLines;

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final textSpan = TextSpan(
          text: widget.text,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textMuted,
            height: 1.35,
          ),
        );

        final tp = TextPainter(
          text: textSpan,
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: size.maxWidth);

        final isOverflowing = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: isExpanded ? null : widget.trimLines,
              overflow:
              isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
                height: 1.35,
              ),
            ),

            if (isOverflowing)
              GestureDetector(
                onTap: () {
                  setState(() => isExpanded = !isExpanded);
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    isExpanded ? 'Read Less' : 'Read More',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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
