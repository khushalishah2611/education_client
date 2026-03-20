import 'package:flutter/material.dart';

import '../widgets/input_field.dart';
import 'dashboard_screen.dart';

class AcademicInfoScreen extends StatelessWidget {
  const AcademicInfoScreen({super.key, required this.flowLabel});

  final String flowLabel;

  void _openDashboard(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$flowLabel Academic Info',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                'Complete this academic information form. After tapping continue, the dashboard will open.',
                style: TextStyle(fontSize: 15, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 24),
              const InputField(
                label: 'Highest Qualification',
                hintText: '12th pass / Diploma / Bachelor',
              ),
              const SizedBox(height: 16),
              const InputField(
                label: 'Preferred Program',
                hintText: 'Engineering / Business / Medicine',
              ),
              const SizedBox(height: 16),
              const InputField(
                label: 'Preferred Intake',
                hintText: 'September 2026',
              ),
              const SizedBox(height: 16),
              const InputField(
                label: 'Country Preference',
                hintText: 'UAE / Jordan / Lebanon',
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openDashboard(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF95E1B0),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
