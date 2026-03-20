import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'payment_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.university, required this.course});

  final UniversityData university;
  final CourseData course;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selected = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FlowStepHeader(currentStep: 2, title: 'Payment'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                children: [
                  const Text('Application Fee Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE8E2D9))),
                    child: const Column(
                      children: [
                        Row(
                          children: [
                            Text('Application Fee', style: TextStyle(color: AppColors.textMuted)),
                            Spacer(),
                            Text('₹1,500.00', style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Divider(height: 24),
                        Row(
                          children: [
                            Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w700)),
                            Spacer(),
                            Text('₹1,500.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accent)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _PaymentMethodTile(label: 'Credit Card', iconText: 'VISA', selected: selected == 0, onTap: () => setState(() => selected = 0)),
                  const SizedBox(height: 10),
                  _PaymentMethodTile(label: 'UPI Pay', iconText: 'UPI', selected: selected == 1, onTap: () => setState(() => selected = 1)),
                  const SizedBox(height: 10),
                  _PaymentMethodTile(label: 'Net Banking', iconText: 'BANK', selected: selected == 2, onTap: () => setState(() => selected = 2)),
                  const SizedBox(height: 30),
                  AppPrimaryButton(
                    label: 'Pay Now',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PaymentConfirmationScreen(university: widget.university, course: widget.course)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.label,
    required this.iconText,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconText;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.accent : const Color(0xFFE8E2D9)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(4)),
              child: Text(iconText, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 16, color: AppColors.textMuted)),
            const Spacer(),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? AppColors.accent : AppColors.textMuted)),
              child: selected ? const Center(child: CircleAvatar(radius: 5, backgroundColor: AppColors.accent)) : null,
            ),
          ],
        ),
      ),
    );
  }
}
