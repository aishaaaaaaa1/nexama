import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class MarketplacePrestatairePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MarketplacePrestatairePage({super.key, this.userData});

  @override
  State<MarketplacePrestatairePage> createState() => _MarketplacePrestatairePageState();
}

class _MarketplacePrestatairePageState extends State<MarketplacePrestatairePage> {
  final List<Map<String, dynamic>> _opportunities = [
    {
      'titre': 'Développement Application Mobile E-commerce',
      'client': 'Sanae Boutique',
      'budget': '15 000 - 25 000 MAD',
      'delai': '2 mois',
      'tags': ['Flutter', 'Firebase'],
      'description': 'Nous recherchons un développeur Flutter pour créer une application mobile pour notre boutique en ligne.'
    },
    {
      'titre': 'Refonte Identité Visuelle (Branding)',
      'client': 'Atlas Tech',
      'budget': '5 000 MAD',
      'delai': '2 semaines',
      'tags': ['Design', 'Logo'],
      'description': 'Besoin d\'un nouveau logo et d\'une charte graphique moderne pour une startup.'
    },
    {
      'titre': 'Campagne Marketing Digital SEO/Ads',
      'client': 'Hotel Riad Marrakesh',
      'budget': '3 000 MAD / mois',
      'delai': 'Long terme',
      'tags': ['SEO', 'Google Ads'],
      'description': 'Amélioration de la visibilité sur Google pour un riad de luxe.'
    },
  ];

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
                Text('Marketplace des Opportunités', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const Text('Trouvez de nouveaux projets et développez votre activité.', style: TextStyle(color: Colors.grey)),
              ],
            ),
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list), label: const Text('Filtrer'))
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            itemCount: _opportunities.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final opp = _opportunities[index];
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(opp['titre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        Text(opp['budget'], style: const TextStyle(fontWeight: FontWeight.bold, color: NexaColors.primaryGreen, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Client: ${opp['client']} • Délai: ${opp['delai']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 16),
                    Text(opp['description'], style: const TextStyle(height: 1.5)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ...(opp['tags'] as List).map((t) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                          child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        )),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Votre candidature pour "${opp['titre']}" a été envoyée !'),
                                backgroundColor: NexaColors.primaryGreen,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: NexaColors.darkNavy, foregroundColor: Colors.white),
                          child: const Text('Postuler'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
