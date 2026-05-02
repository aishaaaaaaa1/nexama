import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class BaseLegalePage extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const BaseLegalePage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Base Documentaire Légale', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const Text('Toute la réglementation et les formulaires de l\'Auto-Entrepreneur au Maroc.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: NexaColors.primaryGreen, borderRadius: BorderRadius.circular(8)),
              child: const Row(children: [Icon(Icons.search, color: Colors.white, size: 18), SizedBox(width: 8), Text('Rechercher...', style: TextStyle(color: Colors.white))]),
            )
          ],
        ),
        const SizedBox(height: 32),
        const Text('Dahirs & Lois', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3,
          children: [
            _buildDocCard('Loi n° 114-13', 'Statut de l\'Auto-Entrepreneur', 'PDF • 1.2 MB', Icons.gavel),
            _buildDocCard('Dahir n° 1-15-06', 'Promulgation de la loi 114-13', 'PDF • 800 KB', Icons.menu_book),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Impôts & Déclarations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3,
          children: [
            _buildDocCard('Guide de la DGI', 'Régime Fiscal de l\'AE', 'PDF • 2.5 MB', Icons.account_balance),
            _buildDocCard('Formulaire', 'Déclaration du Chiffre d\'Affaires', 'DOCX • 50 KB', Icons.description),
            _buildDocCard('Formulaire CNSS', 'Immatriculation au régime AMO', 'PDF • 1.1 MB', Icons.health_and_safety),
          ],
        )
      ],
    );
  }

  Widget _buildDocCard(String title, String subtitle, String meta, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF64748B), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(meta, style: const TextStyle(color: NexaColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.download_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
