import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class AdminSettings extends StatelessWidget {
  const AdminSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paramètres du Système', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: [
              _buildSettingGroup('GÉNÉRAL', [
                _buildToggleSetting('Mode Maintenance', 'Désactive l\'accès public à la plateforme.', false),
                _buildToggleSetting('Inscriptions Ouvertes', 'Permet aux nouveaux utilisateurs de s\'inscrire.', true),
                _buildToggleSetting('Vérification E-mail Obligatoire', 'Force les utilisateurs à valider leur e-mail.', true),
              ]),
              const SizedBox(height: 24),
              _buildSettingGroup('SÉCURITÉ', [
                _buildToggleSetting('2FA Obligatoire pour Admin', 'Force l\'authentification à deux facteurs.', true),
                _buildToggleSetting('Journalisation de Debug', 'Active les logs détaillés du serveur.', false),
                _buildActionSetting('Rotation des Clés API', 'Générer de nouvelles clés pour les services tiers.'),
              ]),
              const SizedBox(height: 24),
              _buildSettingGroup('INTÉGRATIONS', [
                _buildActionSetting('Configuration Stripe', 'Modifier les clés de paiement et webhooks.'),
                _buildActionSetting('Configuration Firebase', 'Gérer les notifications push et analytics.'),
                _buildActionSetting('Configuration Google Cloud', 'Paramètres de stockage et Vision API.'),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildToggleSetting(String title, String desc, bool val) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Switch(value: val, onChanged: (v) {}, activeColor: NexaColors.primaryGreen),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildActionSetting(String title, String desc) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}
