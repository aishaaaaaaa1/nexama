import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfilePage({super.key, this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = widget.userData ?? {};
    final fullName = user['nom_complet'] ?? user['nom'] ?? 'Utilisateur';
    final email = user['email'] ?? 'Non renseigné';
    final role = user['role']?.toString().toUpperCase() ?? 'ENTREPRENEUR';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mon Profil', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          const SizedBox(height: 24),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Info Card
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildProfileHeader(fullName, role, email),
                    const SizedBox(height: 24),
                    _buildAccountSettings(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right: Trust Score & Stats
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildTrustScoreCard(),
                    const SizedBox(height: 24),
                    _buildQuickStats(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String name, String role, String email) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: NexaColors.primaryGreen.withValues(alpha: 0.1),
                child: Text(name[0], style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.bold, color: NexaColors.primaryGreen)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: NexaColors.primaryGreen, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: NexaColors.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(role, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: NexaColors.primaryGreen)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(email, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildHeaderStat('Projets', '12'),
                    const SizedBox(width: 24),
                    _buildHeaderStat('Collaborateurs', '5'),
                    const SizedBox(width: 24),
                    _buildHeaderStat('Score', '85%'),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showEditProfileDialog(context, name, email);
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Modifier le profil'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Paramètres du compte', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          const SizedBox(height: 24),
          _buildSettingItem(Icons.lock_outline, 'Sécurité', 'Changer votre mot de passe et activer la 2FA'),
          _buildSettingItem(Icons.notifications_none, 'Notifications', 'Gérer vos alertes e-mail et push'),
          _buildSettingItem(Icons.payment_outlined, 'Abonnement', 'Gérer votre forfait NexaMa Premium'),
          _buildSettingItem(Icons.privacy_tip_outlined, 'Confidentialité', 'Contrôler la visibilité de votre profil'),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String sub) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF64748B), size: 20),
      ),
      title: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: NexaColors.darkNavy)),
      subtitle: Text(sub, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFFCBD5E1)),
      onTap: () {},
    );
  }

  Widget _buildTrustScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [NexaColors.primaryGreen, NexaColors.darkGreen], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: NexaColors.primaryGreen.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trust Score', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
              const Icon(Icons.verified, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(value: 0.85, strokeWidth: 10, backgroundColor: Colors.white.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation(Colors.white)),
              ),
              Text('85', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          Text('Niveau : Très Fiable', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Votre score est supérieur à 90% des utilisateurs de votre secteur.', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activité récente', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          const SizedBox(height: 20),
          _buildStatRow('Matching Investisseur', '92%'),
          _buildStatRow('Taux de réponse', '1.2h'),
          _buildStatRow('Projets validés', '8'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13)),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: NexaColors.darkNavy, fontSize: 13)),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentName, String currentEmail) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier le profil', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Nom complet'), controller: TextEditingController(text: currentName)),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Email'), controller: TextEditingController(text: currentEmail)),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Bio / Description'), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour !'), backgroundColor: Colors.green));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
