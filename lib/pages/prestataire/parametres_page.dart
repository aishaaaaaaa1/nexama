import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ParametresPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ParametresPage({super.key, this.userData});

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  bool _notifs = true;
  bool _profilePublic = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paramètres du Compte', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const Text('Gérez vos préférences et la sécurité de votre compte.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            children: [
              _buildSettingRow('Notifications Push', 'Recevoir des alertes pour les nouveaux messages et commandes.', _notifs, (v) => setState(() => _notifs = v)),
              const Divider(height: 48),
              _buildSettingRow('Profil Public', 'Permettre aux clients de trouver votre profil dans la recherche.', _profilePublic, (v) => setState(() => _profilePublic = v)),
              const Divider(height: 48),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Changer le mot de passe', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Sécurisez votre compte avec un mot de passe fort.'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              const Divider(height: 48),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Langue de l\'interface', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Français (Maroc)'),
                trailing: const Icon(Icons.language, size: 20),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: NexaColors.primaryGreen),
      ],
    );
  }
}
