import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../widgets/formateur/formateur_ui.dart';

class StatistiquesFormateurPage extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const StatistiquesFormateurPage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormateurPageHeader(
            title: 'Statistiques',
            subtitle: 'Performance pédagogique, inscriptions et satisfaction.',
          ),
          const SizedBox(height: 20),
          const FormateurStatsRow(
            items: [
              FormateurStatItem(label: 'Complétion moy.', value: '68 %', icon: Icons.check_circle_outline, color: NexaColors.primaryGreen),
              FormateurStatItem(label: 'Note moyenne', value: '4.8 / 5', icon: Icons.star_border, color: Colors.amber),
              FormateurStatItem(label: 'Nouveaux inscrits', value: '+124', icon: Icons.person_add_alt_1, color: Colors.blue, hint: 'Ce trimestre'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: FormateurSectionCard(
                  title: 'Inscriptions mensuelles',
                  child: SizedBox(
                    height: 260,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: const Color(0xFFE2E8F0), strokeWidth: 1)),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                const labels = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai'];
                                final i = v.toInt();
                                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                                return Padding(padding: const EdgeInsets.only(top: 8), child: Text(labels[i], style: GoogleFonts.inter(fontSize: 11, color: FormateurColors.muted)));
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [FlSpot(0, 10), FlSpot(1, 25), FlSpot(2, 40), FlSpot(3, 30), FlSpot(4, 55)],
                            isCurved: true,
                            color: NexaColors.primaryGreen,
                            barWidth: 4,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: true, color: NexaColors.primaryGreen.withValues(alpha: 0.15)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FormateurSectionCard(
                  title: 'Répartition par cours',
                  child: Column(
                    children: [
                      _barRow('Flutter', 0.45, FormateurColors.accent),
                      const SizedBox(height: 14),
                      _barRow('Marketing', 0.35, NexaColors.primaryGreen),
                      const SizedBox(height: 14),
                      _barRow('SEO', 0.20, Colors.orange),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _barRow(String label, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('${(pct * 100).round()} %', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: pct, minHeight: 8, color: color, backgroundColor: const Color(0xFFF1F5F9)),
        ),
      ],
    );
  }
}
