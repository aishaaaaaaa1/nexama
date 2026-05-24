import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'pipeline_config.dart';

class PipelineStatsRow extends StatelessWidget {
  final List<Map<String, dynamic>> deals;
  final PipelineConfig config;
  final String wonStatus;

  const PipelineStatsRow({
    super.key,
    required this.deals,
    required this.config,
    this.wonStatus = 'gagne',
  });

  @override
  Widget build(BuildContext context) {
    final totalValue = deals.fold(0.0, (s, d) => s + dealAmount(d));
    final activeCount = deals.where((d) => d['statut'] != wonStatus).length;
    final wonCount = deals.where((d) => d['statut'] == wonStatus).length;
    final conversion = deals.isEmpty ? 0.0 : wonCount / deals.length;

    return Row(
      children: [
        _StatCard(
          label: 'Valeur pipeline',
          value: '${totalValue.toInt()} MAD',
          icon: Icons.show_chart,
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
        _StatCard(
          label: 'Deals actifs',
          value: '$activeCount',
          icon: Icons.people_outline,
          color: NexaColors.primaryGreen,
        ),
        const SizedBox(width: 16),
        _StatCard(
          label: 'Taux conversion',
          value: '${(conversion * 100).toInt()} %',
          icon: Icons.trending_up,
          color: Colors.orange,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
