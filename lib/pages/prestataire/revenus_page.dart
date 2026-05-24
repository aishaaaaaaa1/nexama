import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class RevenusPrestatairePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const RevenusPrestatairePage({super.key, this.userData});

  @override
  State<RevenusPrestatairePage> createState() => _RevenusPrestatairePageState();
}

class _RevenusPrestatairePageState extends State<RevenusPrestatairePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchRevenus();
  }

  Future<void> _fetchRevenus() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/prestataire/revenus/$userId'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _data = json.decode(response.body);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gestion des Revenus', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildStatCard('Total Encaissé', _data?['total_revenus'] ?? '0 MAD', Icons.payments_outlined, NexaColors.primaryGreen),
            const SizedBox(width: 16),
            _buildStatCard('En Attente', _data?['en_attente'] ?? '0 MAD', Icons.pending_actions, Colors.orange),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Performance mensuelle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 32),
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: NexaColors.primaryGreen, width: 16)]),
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 12, color: NexaColors.primaryGreen, width: 16)]),
                      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 10, color: NexaColors.primaryGreen, width: 16)]),
                      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: NexaColors.primaryGreen, width: 16)]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(val, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
