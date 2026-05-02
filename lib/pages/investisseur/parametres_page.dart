import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ParametresPage extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const ParametresPage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paramètres', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Gérez les paramètres de votre compte et vos préférences.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Informations personnelles'),
                subtitle: Text(userData?['email'] ?? 'votre_email@exemple.com'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Sécurité & Mot de passe'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const SizedBox(height: 24),
              const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              SwitchListTile(
                title: const Text('Alertes de nouveaux projets'),
                value: true,
                onChanged: (bool value) {},
                activeColor: NexaColors.primaryGreen,
              ),
              SwitchListTile(
                title: const Text('Rapports hebdomadaires de portefeuille'),
                value: false,
                onChanged: (bool value) {},
                activeColor: NexaColors.primaryGreen,
              ),
            ],
          ),
        )
      ],
    );
  }
}
