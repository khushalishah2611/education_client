import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/responsive_helper.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flow_widgets.dart';
import 'payment_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    this.universityName,
    this.universityHeroImage,
    this.courseTitle,
  });

  final String? universityName;
  final String? universityHeroImage;
  final String? courseTitle;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selected = 1;

  @override
  Widget build(BuildContext context) {
    final bool isSmallMobile = context.isSmallMobile;
    final double horizontalPadding = context.responsiveHorizontalPadding;

    return Scaffold(
      body: AppBackground(
        child: AppPageEntrance(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FlowStepHeader(
                currentStep: 2,
                title: context.l10n.text('payment'),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    isSmallMobile ? 14 : 20,
                    horizontalPadding,
                    20,
                  ),
                  children: [
                    Text(
                      context.l10n.text('applicationFeeSummary'),
                      style: TextStyle(
                        fontSize: isSmallMobile ? 16 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE8E2D9)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                context.l10n.text('applicationFee'),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                context.l10n.text('feeAmount'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Text(
                                context.l10n.text('totalAmount'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                context.l10n.text('feeAmount'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      context.l10n.text('paymentMethod'),
                      style: TextStyle(
                        fontSize: isSmallMobile ? 16 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PaymentMethodTile(
                      label: context.l10n.text('creditCard'),
                      iconText: 'VISA',
                      selected: selected == 0,
                      onTap: () => setState(() => selected = 0),
                    ),
                    const SizedBox(height: 10),
                    _PaymentMethodTile(
                      label: context.l10n.text('upiPay'),
                      iconText: 'UPI',
                      selected: selected == 1,
                      onTap: () => setState(() => selected = 1),
                    ),
                    const SizedBox(height: 10),
                    _PaymentMethodTile(
                      label: context.l10n.text('netBanking'),
                      iconText: 'BANK',
                      selected: selected == 2,
                      onTap: () => setState(() => selected = 2),
                    ),
                    const SizedBox(height: 30),
                    AppPrimaryButton(
                      label: context.l10n.text('payNow'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PaymentConfirmationScreen(
                            universityName: widget.universityName,
                            universityHeroImage: widget.universityHeroImage,
                            courseTitle: widget.courseTitle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    final bool isSmallMobile = context.isSmallMobile;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.accent : const Color(0xFFE8E2D9),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                iconText,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallMobile ? 14 : 16,
                color: AppColors.textMuted,
              ),
            ),
            const Spacer(),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.textMuted,
                ),
              ),
              child: selected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: AppColors.accent,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
