import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

import 'recharge_compte_page.dart';

class PortefeuillePage extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const PortefeuillePage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Portefeuille', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Gérez vos fonds et méthodes de paiement.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Solde disponible', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text('550 000 MAD', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RechargeComptePage(userData: userData)));
                },
                icon: const Icon(Icons.add),
                label: const Text('Recharger mon compte'),
                style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
              )
            ],
          ),
        )
      ],
    );
  }
}
