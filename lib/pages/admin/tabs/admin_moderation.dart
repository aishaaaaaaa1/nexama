import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class AdminModeration extends StatelessWidget {
  const AdminModeration({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Centre de Modération', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildStatBox('Signalements en attente', '8', Colors.orange),
            const SizedBox(width: 16),
            _buildStatBox('Contenus bloqués', '142', Colors.redAccent),
            const SizedBox(width: 16),
            _buildStatBox('Approbations profils', '5', NexaColors.primaryGreen),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Signalements récents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              _buildModerationItem('Contenu inapproprié', 'Publié par Mehdi T. dans Marketplace', 'Il y a 2 heures', 'HAUTE'),
              const Divider(height: 32),
              _buildModerationItem('Spam / Arnaque suspectée', 'Profil de InvestX Maroc', 'Il y a 5 heures', 'CRITIQUE'),
              const Divider(height: 32),
              _buildModerationItem('Violation droits d\'auteur', 'Cours "Marketing 2024" par Salma R.', 'Il y a 1 jour', 'MOYENNE'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(val, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildModerationItem(String title, String desc, String time, String priority) {
    Color pColor = Colors.orange;
    if (priority == 'CRITIQUE') pColor = Colors.red;
    if (priority == 'HAUTE') pColor = Colors.orangeAccent;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: pColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.report_problem_outlined, color: pColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              children: [
                TextButton(onPressed: () {}, child: const Text('Ignorer', style: TextStyle(color: Colors.grey, fontSize: 12))),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), minimumSize: Size.zero),
                  child: const Text('Bloquer', style: TextStyle(fontSize: 11)),
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}
