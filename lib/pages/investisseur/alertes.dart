import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class AlertesPage extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const AlertesPage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Alertes & Notifications', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Toutes vos alertes systèmes et rappels importants.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('Nouveau projet dans le secteur Agritech'),
                subtitle: const Text('Il y a 2 heures'),
                trailing: const Icon(Icons.circle, size: 12, color: Colors.blue),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: NexaColors.primaryGreen),
                title: const Text('Le porteur de GreenTech a répondu à votre message'),
                subtitle: const Text('Hier'),
                onTap: () {},
              ),
            ],
          ),
        )
      ],
    );
  }
}
