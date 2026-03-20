import 'package:flutter/material.dart';

import '../widgets/input_field.dart';
import 'academic_info_screen.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, required this.flowLabel});

  final String flowLabel;

  void _openAcademicInfo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AcademicInfoScreen(flowLabel: flowLabel),
      ),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$flowLabel OTP Verification',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter the 4-digit OTP sent to your mobile number or email address.',
                style: TextStyle(fontSize: 15, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 28),
              const InputField(label: 'OTP Code', hintText: 'Enter 4-digit OTP'),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Text(
                    'Didn\'t receive code?',
                    style: TextStyle(color: Color(0xFF666666)),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: Color(0xFFF29A38),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openAcademicInfo(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF95E1B0),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Verify OTP',
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
