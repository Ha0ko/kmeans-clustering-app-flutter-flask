import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import 'cluster_screen.dart';

class ElbowScreen extends StatefulWidget {
  const ElbowScreen({super.key});

  @override
  State<ElbowScreen> createState() => _ElbowScreenState();
}

class _ElbowScreenState extends State<ElbowScreen> {
  final ApiService _apiService = ApiService();
  List<int>? kValues;
  List<double>? wcssValues;
  bool isLoading = true;
  String? error;
  int selectedK = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _apiService.getElbowData();
      setState(() {
        kValues = List<int>.from(data['k_values']);
        wcssValues = List<double>.from(data['wcss_values']);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13A4EC);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cluster Selection',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : error != null
              ? Center(child: Text('Error: $error'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A3C46) : Colors.grey.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Elbow Method Analysis',
                                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Inertia vs. Number of Clusters',
                                      style: GoogleFonts.inter(
                                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'OPTIMAL K: 5',
                                    style: GoogleFonts.inter(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 200,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: Colors.white.withOpacity(0.05),
                                      strokeWidth: 1,
                                      dashArray: [5, 5],
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        getTitlesWidget: (val, meta) => Text(
                                          val.toInt().toString(),
                                          style: GoogleFonts.inter(color: val == 5 ? primaryColor : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(kValues!.length, (i) => FlSpot(kValues![i].toDouble(), wcssValues![i])),
                                      isCurved: true,
                                      color: primaryColor,
                                      barWidth: 3,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                          radius: spot.x == 5 ? 6 : 4,
                                          color: spot.x == 5 ? primaryColor : Colors.white,
                                          strokeWidth: 2,
                                          strokeColor: primaryColor,
                                        ),
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [primaryColor.withOpacity(0.2), primaryColor.withOpacity(0)],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.05),
                          border: const Border(left: BorderSide(color: primaryColor, width: 4)),
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline, color: primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                  children: [
                                    const TextSpan(text: 'The elbow point suggests '),
                                    TextSpan(
                                      text: '5 clusters',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const TextSpan(text: ' offers the best balance of variance reduction versus complexity.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Configuration', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A3C46) : Colors.grey.shade100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Number of Clusters (k)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text('Select a value between 2 and 10',
                                    style: GoogleFonts.inter(
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 20),
                                    onPressed: () => setState(() => selectedK = (selectedK > 2) ? selectedK - 1 : 2),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      selectedK.toString(),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 20, color: Colors.white),
                                    padding: EdgeInsets.zero,
                                    style: IconButton.styleFrom(backgroundColor: primaryColor),
                                    onPressed: () => setState(() => selectedK = (selectedK < 10) ? selectedK + 1 : 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ClusterScreen(k: selectedK)));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow, size: 20),
              const SizedBox(width: 8),
              Text('Run Segmentation', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
