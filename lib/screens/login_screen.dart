import 'package:flutter/material.dart';
import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'verify_otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  String _selectedDialCode = '+91';

  bool _isChecked = false; // ✅ Checkbox state

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Title
          Text(
            context.l10n.text('loginWithOtp'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 20),

          /// Mobile Label
          Text(
            context.l10n.text('mobileNumber'),
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 10),

          /// Mobile Input Field
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),

                /// Country Code Dropdown
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDialCode,
                    borderRadius: BorderRadius.circular(12),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                    ),
                    style: const TextStyle(fontSize: 16, color: AppColors.text),
                    items: const [
                      DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                      DropdownMenuItem(value: '+971', child: Text('🇦🇪 +971')),
                      DropdownMenuItem(value: '+966', child: Text('🇸🇦 +966')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedDialCode = value;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 10),

                /// Divider
                Container(width: 1, height: 30, color: AppColors.border),

                /// Input
                Expanded(
                  child: TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(5),
                      hintText: 'Enter mobile number',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),

          const SizedBox(height: 26),

          /// Send OTP Button
          AppPrimaryButton(
            label: context.l10n.text('sendOtp'),
            onPressed: () {
              /// Mobile validation
              if (_mobileController.text.length < 10) {
                showAppSnackBar(
                  context,
                  type: AppSnackBarType.error,
                  message: context.l10n.isArabic
                      ? 'أدخل رقم هاتف صحيح'
                      : 'Enter valid mobile number',
                );
                return;
              }

              /// Checkbox validation
              if (!_isChecked) {
                showAppSnackBar(
                  context,
                  type: AppSnackBarType.error,
                  message: context.l10n.isArabic
                      ? 'يرجى قبول الشروط وسياسة الخصوصية'
                      : 'Please accept Terms & Privacy',
                );
                return;
              }

              /// Navigate
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VerifyOtpScreen()),
              );
            },
          ),

          const SizedBox(height: 14),

          /// Terms & Privacy Checkbox
          CheckboxListTile(
            value: _isChecked,
            onChanged: (value) {
              setState(() {
                _isChecked = value!;
              });
            },
            title: Text(
              context.l10n.text('termsPrivacy'),
              style: const TextStyle(color: Colors.blue, fontSize: 14),
            ),
            controlAffinity:
                ListTileControlAffinity.leading, // checkbox left side
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
