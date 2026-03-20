import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'course_list_screen.dart';
import 'university_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.l10n.textDirection,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const CommonSideMenu(),
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.menu_rounded,
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
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
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.text('cityOrCollege'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  const TextField(decoration: InputDecoration(hintText: 'University of')),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF4D2B5)),
                      color: const Color(0xFFFFFCF8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tune_rounded, color: AppColors.accent),
                        SizedBox(width: 8),
                        Text('More Filters', style: TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _DiscoverBanner(),
                  const SizedBox(height: 16),
                  SectionTitle(context.l10n.text('popularUniversities')),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      itemCount: universityCatalog.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: .72,
                      ),
                      itemBuilder: (context, index) {
                        final item = universityCatalog[index];
                        return _UniversityCard(
                          data: item,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => UniversityDetailScreen(data: item)),
                          ),
                        );
                      },
                    ),
                  ),
                  BottomTabBarCard(
                    activeIndex: _activeTab,
                    onTap: (index) {
                      setState(() => _activeTab = index);
                      if (index == 1) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CourseListScreen(university: universityCatalog.first),
                          ),
                        );
                      }
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

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

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
        child: Icon(icon, color: AppColors.text, size: 26),
      ),
    );
  }
}

class _DiscoverBanner extends StatelessWidget {
  const _DiscoverBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(colors: [Color(0xFFFFB867), Color(0xFFF6A650)]),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 6,
            bottom: 4,
            child: SizedBox(width: 132, height: 90, child: HeroIllustration(showPattern: false, height: 90)),
          ),
          const Positioned(right: 92, top: 4, child: Icon(Icons.cloud, color: Colors.white, size: 30)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Find Your Perfect Arab\nUniversity',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.15),
              ),
              SizedBox(height: 8),
              Text('+500 University', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _UniversityCard extends StatelessWidget {
  const _UniversityCard({required this.data, required this.onTap});

  final UniversityData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E3DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 84,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                data.shortCode,
                style: TextStyle(color: data.color, fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(data.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.15)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 2),
              Expanded(child: Text(data.location, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
              const Icon(Icons.star, color: Color(0xFFFFB300), size: 14),
              const SizedBox(width: 2),
              const Text('4.6', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
                elevation: 0,
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
