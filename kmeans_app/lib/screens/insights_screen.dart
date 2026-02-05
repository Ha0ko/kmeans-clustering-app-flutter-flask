import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'prediction_screen.dart';

class InsightsScreen extends StatelessWidget {
  final Map<String, dynamic> clusterMeans;
  final Map<String, dynamic>? clusterLabels;
  final String? clusterImageBase64;
  final String? elbowImageBase64;

  const InsightsScreen({
    super.key, 
    required this.clusterMeans,
    this.clusterLabels,
    this.clusterImageBase64,
    this.elbowImageBase64,
  });

  Future<void> _exportToPdf(BuildContext context) async {
    final pdf = pw.Document();

    final incomeData = clusterMeans['Annual Income (k\$)'] as Map<String, dynamic>;
    final spendingData = clusterMeans['Spending Score (1-100)'] as Map<String, dynamic>;
    final clusterIds = incomeData.keys.toList();

    // Prepare images
    pw.MemoryImage? clusterImage;
    if (clusterImageBase64 != null) {
      clusterImage = pw.MemoryImage(base64Decode(clusterImageBase64!));
    }

    pw.MemoryImage? elbowImage;
    if (elbowImageBase64 != null) {
      elbowImage = pw.MemoryImage(base64Decode(elbowImageBase64!));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Customer Segmentation Report',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24, color: PdfColors.blue900)),
                  pw.Text(DateTime.now().toString().split(' ')[0], style: const pw.TextStyle(color: PdfColors.grey)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Visualization Section
            if (clusterImage != null) ...[
              pw.Text('1. Cluster Visualization', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Container(
                height: 300,
                child: pw.Center(child: pw.Image(clusterImage, fit: pw.BoxFit.contain)),
              ),
              pw.SizedBox(height: 20),
            ],

            // Elbow Section
            if (elbowImage != null) ...[
              pw.Text('2. Elbow Method Analysis', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Container(
                height: 300,
                child: pw.Center(child: pw.Image(elbowImage, fit: pw.BoxFit.contain)),
              ),
              pw.SizedBox(height: 20),
            ],

            pw.Text('3. Group Breakdown & Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
            pw.SizedBox(height: 15),

            ...clusterIds.map((id) {
              final income = incomeData[id] as double;
              final spending = spendingData[id] as double;
              final label = clusterLabels?[id.toString()] ?? _getLabel(income, spending);
              final desc = _getDescription(income, spending);

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  border: pw.Border.all(color: PdfColors.grey200),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Segment: $label',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.blue700)),
                        pw.Text('ID: $id', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Average Income', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                              pw.Text('\$${income.toStringAsFixed(1)}k', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Spending Score', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                              pw.Text('${spending.toStringAsFixed(1)}/100', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('Characteristics: $desc', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                  ],
                ),
              );
            }),
            
            pw.SizedBox(height: 30),
            pw.Divider(color: PdfColors.grey300),
            pw.Center(
              child: pw.Text('Clustering System', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Modern_Customer_Segmentation_Report.pdf',
    );
  }

  String _getLabel(double income, double spending) {
    if (income > 60 && spending > 60) return "The VIPs";
    if (income > 60 && spending < 40) return "The Savers";
    if (income < 40 && spending > 60) return "The Big Spenders";
    if (income < 40 && spending < 40) return "The Frugals";
    return "The Average Joes";
  }

  String _getDescription(double income, double spending) {
    String inc = income > 60 ? "High Income" : (income < 40 ? "Low Income" : "Medium Income");
    String spd = spending > 60 ? "High Spending" : (spending < 40 ? "Low Spending" : "Medium Spending");
    return "$inc, $spd profile with balanced behavioral patterns.";
  }

  IconData _getIcon(String label) {
    if (label.contains("VIP")) return Icons.workspace_premium;
    if (label.contains("Saver")) return Icons.savings;
    if (label.contains("Big Spender")) return Icons.shopping_bag;
    if (label.contains("Frugal")) return Icons.money_off;
    if (label.contains("Balanced")) return Icons.balance;
    if (label.contains("Active")) return Icons.bolt;
    if (label.contains("Value")) return Icons.search;
    return Icons.person;
  }

  Color _getColor(String label) {
    if (label.contains("VIP")) return const Color(0xFF13A4EC);
    if (label.contains("Saver")) return Colors.green;
    if (label.contains("Big Spender")) return Colors.purple;
    if (label.contains("Frugal")) return Colors.orange;
    if (label.contains("Balanced")) return Colors.teal;
    if (label.contains("Active")) return Colors.pink;
    if (label.contains("Value")) return Colors.indigo;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13A4EC);

    final incomeData = clusterMeans['Annual Income (k\$)']!;
    final spendingData = clusterMeans['Spending Score (1-100)']!;
    final clusterIds = incomeData.keys.toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cluster Insights',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Segments', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(
              '${clusterIds.length} clusters identified from the dataset.',
              style: GoogleFonts.inter(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ...clusterIds.map((id) {
              final income = incomeData[id] as double;
              final spending = spendingData[id] as double;
              final label = clusterLabels?[id.toString()] ?? _getLabel(income, spending);
              final desc = _getDescription(income, spending);
              final icon = _getIcon(label);
              final color = _getColor(label);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                    child: Text('Cluster $id', style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              Text(
                                desc,
                                style: GoogleFonts.inter(
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Income',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                                        )),
                                    Text('\$${income.toInt()}k',
                                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: income / 140,
                                  backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade200,
                                  color: color,
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Spending',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                                        )),
                                    Text('${spending.toInt()}',
                                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: spending / 100,
                                  backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade200,
                                  color: color,
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
          border: const Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportToPdf(context),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                label: Text('Export PDF', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PredictionScreen()),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text('Add Customer', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
