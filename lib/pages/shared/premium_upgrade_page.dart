import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class PremiumUpgradePage extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const PremiumUpgradePage({super.key, this.userData});

  Future<void> _upgrade(BuildContext context, String plan) async {
    try {
      final userId = userData?['id'] ?? 'user_123';
      final role = userData?['role'] ?? 'entrepreneur';
      
      // Determine the correct endpoint based on role
      String endpoint = '/api/entrepreneur/premium';
      if (role == 'investisseur') endpoint = '/api/invest/premium/$userId';
      if (role == 'prestataire') endpoint = '/api/prestataire/premium/$userId';
      if (role == 'formateur') endpoint = '/api/formateur/premium/$userId';

      final response = await ApiService.post(
        ApiConfig.uri(endpoint),
        body: {'plan': plan},
      );

      if (context.mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Félicitations ! Vous êtes maintenant membre Premium ($plan).')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors du passage au premium. Veuillez réessayer.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Une erreur est survenue.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Passer au Premium', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: NexaColors.darkNavy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text('Choisissez votre plan Premium', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
            const SizedBox(height: 16),
            const Text('Accélérez votre croissance avec des outils exclusifs.', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPlanCard(
                  context,
                  'Plan Pro',
                  '290 MAD',
                  '/ mois',
                  [
                    'Visibilité accrue',
                    'Support prioritaire',
                    'Analyses basiques',
                    'Accès communauté'
                  ],
                  Colors.white,
                  NexaColors.darkNavy,
                ),
                const SizedBox(width: 32),
                _buildPlanCard(
                  context,
                  'Plan Elite',
                  '790 MAD',
                  '/ mois',
                  [
                    'Tout du plan Pro',
                    'Analyses avancées IA',
                    'Certifications NexaMa',
                    'Mise en relation directe',
                    'Zéro commission'
                  ],
                  NexaColors.darkNavy,
                  Colors.white,
                  isFeatured: true,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String title, String price, String period, List<String> features, Color bgColor, Color textColor, {bool isFeatured = false}) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          if (isFeatured) BoxShadow(color: NexaColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFeatured)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: NexaColors.primaryGreen, borderRadius: BorderRadius.circular(20)),
              child: const Text('RECOMMANDÉ', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, color: isFeatured ? Colors.white : NexaColors.darkNavy)),
              const SizedBox(width: 4),
              Text(period, style: TextStyle(color: isFeatured ? Colors.white70 : Colors.grey)),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: NexaColors.primaryGreen, size: 20),
                const SizedBox(width: 12),
                Text(f, style: TextStyle(color: isFeatured ? Colors.white : NexaColors.darkNavy, fontSize: 14)),
              ],
            ),
          )),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _upgrade(context, title),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFeatured ? NexaColors.primaryGreen : const Color(0xFFF1F5F9),
                foregroundColor: isFeatured ? Colors.white : NexaColors.darkNavy,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Choisir ce plan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
