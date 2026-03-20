import 'package:flutter/material.dart';

import '../screens/otp_screen.dart';
import 'input_field.dart';

class AuthForm extends StatelessWidget {
  const AuthForm({
    super.key,
    required this.buttonLabel,
    required this.helperText,
    required this.flowLabel,
  });

  final String buttonLabel;
  final String helperText;
  final String flowLabel;

  void _openOtpScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OtpScreen(flowLabel: flowLabel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InputField(label: 'Full Name', hintText: 'Enter your name'),
          const SizedBox(height: 16),
          const InputField(label: 'Email', hintText: 'Enter your email'),
          const SizedBox(height: 16),
          const InputField(
            label: 'Password',
            hintText: 'Enter your password',
            obscureText: true,
          ),
          const SizedBox(height: 12),
          Text(
            helperText,
            style: const TextStyle(fontSize: 13, color: Color(0xFF777777)),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openOtpScreen(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF95E1B0),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
