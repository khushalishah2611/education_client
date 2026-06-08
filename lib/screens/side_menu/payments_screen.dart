import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../core/bloc/app_cubit.dart';
import '../../utils/payment_receipt_pdf.dart';
import '../../services/snackbar_service.dart';
import '../../services/application_api_service.dart';
import 'payment_receipt_screen.dart';
import 'side_menu_common.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SideMenuScaffold(
      title: context.l10n.text('paymentsHistory'),
      child: const PaymentsContent(),
    );
  }
}

class PaymentsContent extends StatefulWidget {
  const PaymentsContent({super.key});

  @override
  State<PaymentsContent> createState() => _PaymentsContentState();
}

class _PaymentsContentState extends State<PaymentsContent>
    with SingleTickerProviderStateMixin, CubitStateMixin<PaymentsContent> {
  final ApplicationApiService _api = const ApplicationApiService();

  bool _loading = true;
  String? _downloadingPaymentId;

  List<Map<String, dynamic>> _payments = <Map<String, dynamic>>[];

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _load();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _overviewData(Map<String, dynamic> rawOverview) {
    final Object? data = rawOverview['data'];
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return rawOverview;
  }

  Future<void> _load() async {
    updateView(() => _loading = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String studentUserId =
          prefs.getString('studentUserId')?.trim() ?? '';

      if (studentUserId.isEmpty) {
        if (!mounted) return;

        updateView(() {
          _payments = <Map<String, dynamic>>[];
          _loading = false;
        });

        return;
      }

      final Map<String, dynamic> overview = _overviewData(
        await _api.fetchStudentOverview(
          studentUserId: studentUserId,
        ),
      );

      final Object? payments = overview['payments'];

      if (!mounted) return;

      updateView(() {
        _payments = payments is List
            ? payments
                .whereType<Map>()
                .map(
                  (e) => e.map(
                    (k, v) => MapEntry(
                      k.toString(),
                      v,
                    ),
                  ),
                )
                .toList()
            : <Map<String, dynamic>>[];

        _loading = false;
      });
    } catch (e) {
      updateView(() => _loading = false);

      snackBarService.showError(
        message: context.l10n.text('failedLoadPayments'),
      );
    }
  }

  Future<void> _downloadReceipt(
    BuildContext context,
    Map<String, dynamic> payment,
  ) async {
    if (_downloadingPaymentId != null) return;

    final String paymentId = resolvePaymentId(payment);
    if (paymentId.isEmpty) {
      snackBarService.showError(
        message: context.l10n.text('receiptNotAvailableYet'),
      );
      return;
    }

    updateView(() => _downloadingPaymentId = paymentId);
    try {
      final String receiptHtml = await _api.fetchPaymentReceiptHtml(
        paymentId: paymentId,
        language: context.l10n.locale.languageCode,
      );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PaymentReceiptScreen(
            receiptHtml: receiptHtml,
          ),
        ),
      );
    } catch (e) {
      snackBarService.showError(
        message: e.toString(),
      );
    } finally {
      if (mounted) updateView(() => _downloadingPaymentId = null);
    }
  }

  String _formatDate(DateTime date, String locale) {
    return DateFormat(
      'MMM dd, yyyy',
      locale,
    ).format(date.toLocal());
  }

  String _formatTime(DateTime date, String locale) {
    return DateFormat(
      'hh:mm a',
      locale,
    ).format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return buildCubitView((context) {
      return Stack(
        children: [
          if (_loading)
            _buildShimmerList()
          else if (_payments.isEmpty)
            _emptyState(context)
          else
            RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _payments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final Map<String, dynamic> item = _payments[index];

                  final DateTime? createdAt = DateTime.tryParse(
                    item['createdAt']?.toString() ?? '',
                  );

                  final String locale = context.l10n.locale.languageCode;

                  final String date =
                      createdAt == null ? '-' : _formatDate(createdAt, locale);

                  final String time =
                      createdAt == null ? '-' : _formatTime(createdAt, locale);

                  final num amount = (item['application'] is Map)
                      ? ((item['application']['selectedApplicationFeeTotal']
                              as num?) ??
                          0)
                      : ((item['amount'] as num?) ?? 0);

                  return GestureDetector(
                    onTap: _downloadingPaymentId != null
                        ? null
                        : () => _downloadReceipt(context, item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE6E0D8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              '$date  •  $time',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${amount.toStringAsFixed(0)} '
                              '${context.l10n.text('omaniRial')}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_downloadingPaymentId != null)
            const Positioned.fill(
              child: ColoredBox(
                color: Color.fromRGBO(0, 0, 0, 0.15),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildShimmerList() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: 10,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, __) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE6E0D8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerLine(
                          width: 180,
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _shimmerLine(
                    width: 120,
                    height: 18,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _shimmerLine({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment(
            -1 + (_shimmerController.value * 2),
            0,
          ),
          end: Alignment(
            1 + (_shimmerController.value * 2),
            0,
          ),
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE6E6E6),
                ),
                color: Colors.white,
              ),
              child: Text(
                context.l10n.text('noPaymentsAvailable'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF616161),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
