import 'package:education/screens/side_menu/side_menu_common.dart';
import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../utils/payment_receipt_pdf.dart';

class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({
    super.key,
    required this.receiptHtml,
  });

  final String receiptHtml;

  @override
  Widget build(BuildContext context) {
    final PaymentReceiptData receipt = parsePaymentReceiptHtml(receiptHtml);
    final bool isArabic = context.l10n.isArabic;

    return SideMenuScaffold(
      title:  receipt.title,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECE8D3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  if (receipt.generatedOn.isNotEmpty) ...<Widget>[

                    Text(
                      receipt.generatedOn,
                      style: const TextStyle(
                        color: Color(0xFF726A4B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (receipt.cards.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: receipt.cards
                    .map(
                      (card) => _InfoCard(
                        label: card.label,
                        value: card.value,
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            if (receipt.headers.isNotEmpty &&
                receipt.rows.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              _ReceiptTable(
                headers: receipt.headers,
                rows: receipt.rows,
                isArabic: isArabic,
              ),
            ],
            if (receipt.notes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5E7),
                  border: Border.all(color: const Color(0xFFD8D3B8)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  receipt.notes,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.sizeOf(context).width - 48) / 2,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0E0),
        border: Border.all(color: const Color(0xFFD8D3B8)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF726A4B),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              color: Color(0xFF3F3A2A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptTable extends StatelessWidget {
  const _ReceiptTable({
    required this.headers,
    required this.rows,
    required this.isArabic,
  });

  final List<String> headers;
  final List<List<String>> rows;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD8D3B8)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Table(
          border: TableBorder.all(
            color: const Color(0xFFD8D3B8),
            width: 0.6,
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              decoration: const BoxDecoration(
                color: Color(0xFFECE8D3),
              ),
              children: headers
                  .map(
                    (header) => Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        header,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          color: Color(0xFF726A4B),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            ...rows.map(
              (row) => TableRow(
                children: List<Widget>.generate(
                  headers.length,
                  (index) {
                    final String cell = index < row.length ? row[index] : '-';
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        cell.isEmpty ? '-' : cell,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          color: Color(0xFF3F3A2A),
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                  growable: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
