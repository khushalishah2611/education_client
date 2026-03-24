import 'package:flutter/material.dart';

import '../data/universities.dart';
import '../widgets/common_widgets.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/university_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppPageEntrance(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.menu_rounded,
                    onTap: () {},
                  ),
                  const Spacer(),
                  const Column(
                    children: [
                      Text(
                        'جامعات',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'ARAB\nUNIVERSITIES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          color: Color(0xFFB35F2E),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      RoundIconButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () {},
                      ),
                      Positioned(
                        right: 11,
                        top: 11,
                        child: Container(
                          height: 8,
                          width: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'College/University or City Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'University of',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.orange.shade100),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.orange.shade100),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF9D1A7)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tune_rounded, color: Color(0xFFF29A38)),
                    SizedBox(width: 8),
                    Text(
                      'More Filters',
                      style: TextStyle(
                        color: Color(0xFFF29A38),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 120,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB665), Color(0xFFF4A74A)],
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Find Your Perfect Arab University',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '+500 University',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 108,
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            top: 8,
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: const Color(0xFF90C978),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 6,
                            bottom: 8,
                            child: Icon(
                              Icons.person_pin_circle_rounded,
                              size: 54,
                              color: Colors.red.shade300,
                            ),
                          ),
                          Positioned(
                            left: 22,
                            top: 18,
                            child: Icon(
                              Icons.apartment_rounded,
                              size: 58,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 20,
                            child: Icon(
                              Icons.cloud_rounded,
                              size: 28,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Popular Universities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: universities.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.70,
                ),
                itemBuilder: (context, index) {
                  final university = universities[index];
                  return UniversityCard(university: university);
                },
              ),
            ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'University',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'College',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment),
            label: 'Private School',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Location',
          ),
        ],
      ),
    );
  }
}
