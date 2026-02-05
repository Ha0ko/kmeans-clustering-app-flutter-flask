import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'elbow_screen.dart';

class DataInputScreen extends StatefulWidget {
  const DataInputScreen({super.key});

  @override
  State<DataInputScreen> createState() => _DataInputScreenState();
}

class _DataInputScreenState extends State<DataInputScreen> {
  final ApiService _apiService = ApiService();
  String? selectedDataset = 'mall';
  String? selectedFileName;
  bool isUploading = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedFileName = result.files.single.name;
          isUploading = true;
        });

        try {
          final file = File(result.files.single.path!);
          await _apiService.uploadFile(file);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Uploaded: $selectedFileName'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload failed: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          setState(() {
            isUploading = false;
          });
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File picker error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFile() {
    setState(() {
      selectedFileName = null;
      selectedDataset = 'mall'; // Default back to demo
    });
  }

  String get _activeSource {
    if (selectedFileName != null) return 'Custom: $selectedFileName';
    switch (selectedDataset) {
      case 'mall': return 'Demo: Mall Customers';
      case 'telecom': return 'Demo: Telecom Churn';
      case 'retail': return 'Demo: Online Retail';
      default: return 'Demo: Mall Customers';
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13A4EC);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Data Input',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, child) {
              return IconButton(
                icon: Icon(mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  themeNotifier.value = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.analytics_outlined, color: primaryColor, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'Customer Segmentation Tool',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your data to start K-Means clustering analysis and unlock insights.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            // Active Source Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selectedFileName != null ? Colors.green.withOpacity(0.1) : primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: selectedFileName != null ? Colors.green.withOpacity(0.2) : primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selectedFileName != null ? Icons.check_circle : Icons.info_outline,
                    size: 16,
                    color: selectedFileName != null ? Colors.green : primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Active Source: $_activeSource',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: selectedFileName != null ? Colors.green : primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A3C46) : Colors.grey.shade100, width: 2),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_upload_outlined, color: primaryColor, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload CSV Dataset',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Supports .csv files up to 10MB',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  if (selectedFileName == null)
                    ElevatedButton(
                      onPressed: isUploading ? null : _pickFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.upload_file, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Browse Files',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.insert_drive_file, color: primaryColor, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              selectedFileName!,
                              style: GoogleFonts.inter(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close, color: primaryColor, size: 18),
                            onPressed: _removeFile,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Divider(color: const Color(0xFFDBE2E6))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR LOAD DEMO DATA',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: const Color(0xFFDBE2E6))),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Dataset',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A3C46) : Colors.grey.shade100),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Select a demo dataset...', style: GoogleFonts.inter(color: Colors.grey)),
                  value: selectedDataset,
                  items: const [
                    DropdownMenuItem(value: 'mall', child: Text('Mall Customers Dataset')),
                    DropdownMenuItem(value: 'telecom', child: Text('Telecom Churn Data')),
                    DropdownMenuItem(value: 'retail', child: Text('Online Retail Transaction')),
                  ],
                  onChanged: (val) async {
                    if (val != null) {
                      try {
                        await _apiService.selectDataset(val);
                        setState(() {
                          selectedDataset = val;
                          selectedFileName = null;
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Switched to ${_activeSource}'),
                              backgroundColor: primaryColor,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to switch dataset'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline, color: primaryColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Pre-cleaned data optimized for clustering demos.',
                  style: GoogleFonts.inter(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
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
          onPressed: isUploading
              ? null
              : () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ElbowScreen()));
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isUploading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Analyze Dataset', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}
