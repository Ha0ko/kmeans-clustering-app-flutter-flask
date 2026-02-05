import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final ApiService _apiService = ApiService();
  
  double _currentAge = 34.0;
  double _currentIncome = 65.0;
  double _currentSpending = 88.0;
  
  bool isLoading = false;
  Map<String, dynamic>? predictionResult;
  
  void _reset() {
    setState(() {
      _currentAge = 34.0;
      _currentIncome = 65.0;
      _currentSpending = 88.0;
      predictionResult = null;
    });
  }

  Future<void> _predict() async {
    setState(() => isLoading = true);
    try {
      final result = await _apiService.predictCluster(
        age: _currentAge,
        income: _currentIncome,
        spending: _currentSpending,
      );
      setState(() {
        predictionResult = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13A4EC);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          'Customer Prediction',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt, size: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Classify New User',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adjust the demographics below to segment the customer using our K-Means model.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Age Slider
                  _buildSliderCard(
                    context: context,
                    label: 'Age',
                    value: _currentAge,
                    unit: 'years',
                    min: 18,
                    max: 80,
                    onChanged: (val) => setState(() => _currentAge = val),
                    color: primaryColor,
                  ),
                  const SizedBox(height: 20),
                  
                  // Income Slider
                  _buildSliderCard(
                    context: context,
                    label: 'Annual Income',
                    value: _currentIncome,
                    unit: 'k',
                    prefix: r'$',
                    min: 15,
                    max: 150,
                    onChanged: (val) => setState(() => _currentIncome = val),
                    color: primaryColor,
                  ),
                  const SizedBox(height: 20),
                  
                  // Spending Score Slider
                  _buildSliderCard(
                    context: context,
                    label: 'Spending Score',
                    value: _currentSpending,
                    unit: 'pts',
                    min: 1,
                    max: 100,
                    onChanged: (val) => setState(() => _currentSpending = val),
                    color: Colors.purple,
                  ),
                  
                  if (predictionResult != null) ...[
                    const SizedBox(height: 32),
                    _buildResultCard(context),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: isLoading ? null : _predict,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.4),
              ),
              child: isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      'Classify Customer',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSliderCard({
    required BuildContext context,
    required String label,
    required double value,
    required String unit,
    String? prefix,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF2A3C46) : Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${prefix ?? ""}${value.toInt()}',
                      style: GoogleFonts.inter(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const WidgetSpan(child: SizedBox(width: 4)),
                    TextSpan(
                      text: unit,
                      style: GoogleFonts.inter(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: isDark ? Colors.blueGrey[700] : Colors.blueGrey[200],
              thumbColor: color,
              overlayColor: color.withOpacity(0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${prefix ?? ""}${min.toInt()}', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
              Text('${prefix ?? ""}${max.toInt()}', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final label = predictionResult!['label'] ?? "Prediction";
    final cluster = predictionResult!['cluster'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine info based on label
    String description = "Customer has been classified into Cluster $cluster.";
    IconData icon = Icons.diamond;
    Color clusterColor = const Color(0xFF13A4EC);

    if (label.contains("VIP")) {
      description = "High income and high spending score. This customer is likely to respond well to exclusive offers.";
      icon = Icons.workspace_premium;
      clusterColor = const Color(0xFF13A4EC);
    } else if (label.contains("Saver")) {
      description = "High income but low spending. Focus on value-driven rewards and high-end savings plans.";
      icon = Icons.savings;
      clusterColor = Colors.green;
    } else if (label.contains("Spender")) {
      description = "Target this customer with trending items and frequent shopper discounts. High potential for impulse buys.";
      icon = Icons.shopping_basket;
      clusterColor = Colors.purple;
    } else if (label.contains("Frugal")) {
      description = "Conservative budget and cautious spending. Best suited for essential item discounts and promotions.";
      icon = Icons.money_off;
      clusterColor = Colors.orange;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [const Color(0xFF1A2C36), const Color(0xFF121212)]
            : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: clusterColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: clusterColor, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prediction Result',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
