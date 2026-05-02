import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class AnalysesRapportsPage extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const AnalysesRapportsPage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analyses & Rapports', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Statistiques avancées de vos investissements.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: const Center(child: Text("Module de rapports détaillés en construction.", style: TextStyle(color: Colors.grey))),
        )
      ],
    );
  }
}
