import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'insights_screen.dart';

class ClusterScreen extends StatefulWidget {
  final int k;
  const ClusterScreen({super.key, required this.k});

  @override
  State<ClusterScreen> createState() => _ClusterScreenState();
}

class _ClusterScreenState extends State<ClusterScreen> {
  final ApiService _apiService = ApiService();
  
  String? imageBase64;
  String? elbowBase64;
  Map<String, dynamic>? clusterMeans;
  Map<String, dynamic>? clusterLabels;
  Map<String, dynamic>? clusterSizes;
  List<dynamic>? clusterColors;
  
  bool isLoading = true;
  String? error;
  
  String currentVizMode = 'Income vs Score';
  int selectedClusterIndex = 0; // 0-based for list indexing, but clusters are 1-based in labels

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await _apiService.getClusterData(widget.k, vizMode: currentVizMode);
      setState(() {
        imageBase64 = data['image_base64'];
        elbowBase64 = data['elbow_base64'];
        clusterMeans = data['cluster_means'];
        clusterLabels = data['cluster_labels'];
        clusterSizes = data['cluster_sizes'];
        clusterColors = data['colors'];
        isLoading = false;
        error = null;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Customer Clusters',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : error != null
              ? _buildErrorState()
              : _buildMainContent(primaryColor, isDark),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(error ?? 'An unexpected error occurred'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildMainContent(Color primaryColor, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // View Toggle
                _buildVizToggle(isDark, primaryColor),
                const SizedBox(height: 24),
                
                // Chart Container
                _buildChartSection(isDark, primaryColor),
                const SizedBox(height: 32),
                
                // All Segments List
                Text(
                  'Identified Segments',
                  style: GoogleFonts.inter(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[200] : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSegmentsList(isDark, primaryColor),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        
        // Bottom Action Button
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => InsightsScreen(
                    clusterMeans: clusterMeans!,
                    clusterLabels: clusterLabels,
                    clusterImageBase64: imageBase64,
                    elbowImageBase64: elbowBase64,
                  )
                )
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: primaryColor.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('View Deep Insights', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                const Icon(Icons.insights, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildVizToggle(bool isDark, Color primaryColor) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202E36) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _toggleItem('Income vs Score', isDark, primaryColor),
          _toggleItem('Age vs Income', isDark, primaryColor),
        ],
      ),
    );
  }

  Widget _toggleItem(String title, bool isDark, Color primaryColor) {
    bool isSelected = currentVizMode == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() => currentVizMode = title);
            _loadData();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? const Color(0xFF2A3C46) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: isSelected ? primaryColor : (isDark ? Colors.grey[400] : Colors.grey[600]),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2C36) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF2A3C46) : Colors.grey[100]!),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
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
                    '${widget.k} Clusters Identified',
                    style: GoogleFonts.inter(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'K-Means Analysis Results',
                    style: GoogleFonts.inter(
                      fontSize: 13, 
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  if (imageBase64 != null) {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(10),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              color: Colors.white,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: InteractiveViewer(
                                  panEnabled: true,
                                  minScale: 1.0,
                                  maxScale: 4.0,
                                  child: Image.memory(
                                    base64Decode(imageBase64!),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF202E36) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.zoom_out_map, size: 20, color: primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (imageBase64 != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(imageBase64!),
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentsList(bool isDark, Color primaryColor) {
    if (clusterMeans == null) return const SizedBox();

    return Column(
      children: List.generate(widget.k, (index) {
        final clusterId = index + 1;
        final label = clusterLabels?[clusterId.toString()] ?? 'Group $clusterId';
        final size = clusterSizes?[clusterId.toString()] ?? 0.0;
        final income = clusterMeans!['Annual Income (k\$)']?[clusterId.toString()] ?? 0.0;
        final score = clusterMeans!['Spending Score (1-100)']?[clusterId.toString()] ?? 0.0;
        
        final hexColorStr = (clusterColors?[index] as String).replaceFirst('#', 'FF');
        final color = Color(int.parse(hexColorStr, radix: 16));

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2C36) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? const Color(0xFF2A3C46) : Colors.grey[100]!),
            boxShadow: isDark ? [] : [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.analytics, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Cluster $clusterId • ${(size * 100).toInt()}% of population',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[300], size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _miniStatItem('Avg Income', '\$${income.toInt()}k', color, isDark),
                  const SizedBox(width: 12),
                  _miniStatItem('Avg Score', '${score.toInt()}', color, isDark),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _miniStatItem(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF202E36) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white : const Color(0xFF111618),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
