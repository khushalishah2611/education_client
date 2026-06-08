import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

String resolvePaymentId(Map<String, dynamic>? payment) {
  if (payment == null || payment.isEmpty) return '';

  const List<String> candidateKeys = <String>[
    'id',
    'paymentId',
    'payment_id',
    '_id',
  ];

  for (final String key in candidateKeys) {
    final String value = payment[key]?.toString().trim() ?? '';
    if (value.isNotEmpty) {
      return value;
    }
  }

  final Object? nestedPayment = payment['payment'];
  if (nestedPayment is Map) {
    return resolvePaymentId(
      nestedPayment.map((k, v) => MapEntry(k.toString(), v)),
    );
  }

  return '';
}

PaymentReceiptData parsePaymentReceiptHtml(String receiptHtml) {
  return PaymentReceiptData.parse(receiptHtml);
}

Future<Uint8List> buildPaymentReceiptPdf(String receiptHtml) async {
  final PaymentReceiptData receipt = PaymentReceiptData.parse(receiptHtml);
  final pw.Document document = pw.Document();
  final PdfColor primary = PdfColor.fromHex('#3f3a2a');
  final PdfColor muted = PdfColor.fromHex('#726a4b');
  final PdfColor border = PdfColor.fromHex('#d8d3b8');
  final PdfColor sectionBackground = PdfColor.fromHex('#f3f0e0');

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (pw.Context context) => <pw.Widget>[
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#ece8d3'),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(
                receipt.title.isEmpty ? 'Payment Receipt' : receipt.title,
                style: pw.TextStyle(
                  color: primary,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (receipt.generatedOn.isNotEmpty) ...<pw.Widget>[
                pw.SizedBox(height: 6),
                pw.Text(
                  receipt.generatedOn,
                  style: pw.TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Wrap(
          spacing: 8,
          runSpacing: 8,
          children: receipt.cards
              .map(
                (card) => pw.Container(
                  width: 170,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: sectionBackground,
                    border: pw.Border.all(color: border),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Text(
                        card.label.toUpperCase(),
                        style: pw.TextStyle(color: muted, fontSize: 8),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        card.value.isEmpty ? '-' : card.value,
                        style: pw.TextStyle(
                          color: primary,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
        ),
        if (receipt.headers.isNotEmpty && receipt.rows.isNotEmpty) ...<pw.Widget>[
          pw.SizedBox(height: 18),
          pw.Text(
            'Details',
            style: pw.TextStyle(
              color: primary,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: receipt.headers,
            data: receipt.rows,
            border: pw.TableBorder.all(color: border, width: 0.6),
            headerDecoration:
                pw.BoxDecoration(color: PdfColor.fromHex('#ece8d3')),
            headerStyle: pw.TextStyle(
              color: muted,
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: pw.TextStyle(color: primary, fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(5),
          ),
        ],
        if (receipt.notes.isNotEmpty) ...<pw.Widget>[
          pw.SizedBox(height: 14),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#f8f5e7'),
              border: pw.Border.all(color: border),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              receipt.notes,
              style: pw.TextStyle(
                color: PdfColor.fromHex('#dc2626'),
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  return document.save();
}

class PaymentReceiptData {
  const PaymentReceiptData({
    required this.title,
    required this.generatedOn,
    required this.cards,
    required this.headers,
    required this.rows,
    required this.notes,
  });

  final String title;
  final String generatedOn;
  final List<PaymentReceiptInfoCard> cards;
  final List<String> headers;
  final List<List<String>> rows;
  final String notes;

  static PaymentReceiptData parse(String html) {
    final String normalized = html.replaceAll(RegExp(r'\s+'), ' ');
    final String title = _decodeHtml(_firstMatch(
      normalized,
      RegExp(r'<h2[^>]*>(.*?)</h2>', caseSensitive: false),
    ).isNotEmpty
        ? _firstMatch(
            normalized,
            RegExp(r'<h2[^>]*>(.*?)</h2>', caseSensitive: false),
          )
        : _firstMatch(
            normalized,
            RegExp(r'<title[^>]*>(.*?)</title>', caseSensitive: false),
          ));
    final String generatedOn = _decodeHtml(_firstMatch(
      normalized,
      RegExp(
        r'<div[^>]*>\s*(Receipt generated on.*?)</div>',
        caseSensitive: false,
      ),
    ));

    final List<PaymentReceiptInfoCard> cards = RegExp(
      r'<div[^>]*class="label"[^>]*>(.*?)</div>\s*<div[^>]*class="value"[^>]*>(.*?)</div>',
      caseSensitive: false,
    ).allMatches(normalized).map((match) {
      return PaymentReceiptInfoCard(
        label: _decodeHtml(match.group(1) ?? ''),
        value: _decodeHtml(match.group(2) ?? ''),
      );
    }).where((card) => card.label.isNotEmpty || card.value.isNotEmpty).toList();

    final String tableHead = _firstMatch(
      normalized,
      RegExp(r'<thead[^>]*>(.*?)</thead>', caseSensitive: false),
    );
    final List<String> headers = _extractCells(tableHead, 'th');
    final String tableBody = _firstMatch(
      normalized,
      RegExp(r'<tbody[^>]*>(.*?)</tbody>', caseSensitive: false),
    );
    final List<List<String>> rows = RegExp(
      r'<tr[^>]*>(.*?)</tr>',
      caseSensitive: false,
    ).allMatches(tableBody).map((match) => _extractCells(match.group(1) ?? '', 'td'))
        .where((row) => row.isNotEmpty)
        .toList(growable: false);

    final String notes = _decodeHtml(_firstMatch(
      normalized,
      RegExp(
        r'<div[^>]*class="non-refundable"[^>]*>(.*?)</div>',
        caseSensitive: false,
      ),
    ));

    return PaymentReceiptData(
      title: title,
      generatedOn: generatedOn,
      cards: cards,
      headers: headers,
      rows: rows,
      notes: notes,
    );
  }

  static List<String> _extractCells(String html, String tagName) {
    return RegExp(
      '<$tagName[^>]*>(.*?)</$tagName>',
      caseSensitive: false,
    ).allMatches(html).map((match) => _decodeHtml(match.group(1) ?? ''))
        .where((cell) => cell.isNotEmpty)
        .toList(growable: false);
  }

  static String _firstMatch(String html, RegExp pattern) {
    return pattern.firstMatch(html)?.group(1) ?? '';
  }

  static String _decodeHtml(String value) {
    String decoded = value.replaceAll(RegExp(r'<[^>]+>'), ' ');
    decoded = decoded
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    decoded = decoded.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (match) => String.fromCharCode(int.tryParse(match.group(1) ?? '') ?? 32),
    );
    return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

class PaymentReceiptInfoCard {
  const PaymentReceiptInfoCard({required this.label, required this.value});

  final String label;
  final String value;
}
