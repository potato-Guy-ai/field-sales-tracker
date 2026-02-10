import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class PdfExportService {
  static Future<File> generateSalesReport({
    required Map<String, dynamic> reportData,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Sales Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Period: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}'),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 20),
            
            _buildReportSection('Summary', [
              ['Total Sales:', '${reportData['total_sales']}'],
              ['Total Revenue:', '₹${reportData['total_revenue']?.toStringAsFixed(2)}'],
              ['Total Payments:', '₹${reportData['total_payments']?.toStringAsFixed(2)}'],
              ['Total Credit:', '₹${reportData['total_credit']?.toStringAsFixed(2)}'],
              ['Total Profit:', '₹${reportData['total_profit']?.toStringAsFixed(2)}'],
            ]),
          ],
        ),
      ),
    );

    final output = await _savePdf(pdf, 'sales_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    return output;
  }

  static Future<File> generateCustomerReport({
    required List<Map<String, dynamic>> customers,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Customer Profit Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 20),
            
            pw.Table.fromTextArray(
              headers: ['Customer', 'Sales', 'Revenue', 'Profit'],
              data: customers.map((c) => [
                c['name'],
                '${c['total_sales']}',
                '₹${(c['total_revenue'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                '₹${(c['total_profit'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
              ]).toList(),
            ),
          ],
        ),
      ),
    );

    final output = await _savePdf(pdf, 'customer_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    return output;
  }

  static pw.Widget _buildReportSection(String title, List<List<String>> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        ...data.map((row) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(row[0], style: const pw.TextStyle(fontSize: 12)),
              pw.Text(row[1], style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        )),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static Future<File> _savePdf(pw.Document pdf, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<void> sharePdf(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'Sales Report');
  }
}
