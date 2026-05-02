import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';

class StatistiquesFormateurPage extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const StatistiquesFormateurPage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Statistiques & Performance', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildStatCard('Taux de complétion moyen', '68%', Icons.check_circle_outline, NexaColors.primaryGreen),
            const SizedBox(width: 16),
            _buildStatCard('Note moyenne', '4.8/5', Icons.star_border, Colors.orange),
            const SizedBox(width: 16),
            _buildStatCard('Nouveaux inscrits', '+124', Icons.trending_up, Colors.blue),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Inscriptions mensuelles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 32),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 10),
                          FlSpot(1, 25),
                          FlSpot(2, 40),
                          FlSpot(3, 30),
                          FlSpot(4, 55),
                        ],
                        isCurved: true,
                        color: NexaColors.primaryGreen,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(show: true, color: NexaColors.primaryGreen.withValues(alpha: 0.2)),
                      ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                  Text(val, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
