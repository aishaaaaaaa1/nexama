import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class PitchViewerPage extends StatelessWidget {
  final Map<String, dynamic> projet;
  const PitchViewerPage({super.key, required this.projet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Pitch : ${projet['nom']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: NexaColors.darkNavy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_circle_fill, color: Colors.white, size: 80),
                              SizedBox(height: 16),
                              Text('Lecture de la vidéo du pitch...', style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text('À propos du projet', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(projet['pitch'] ?? 'Aucun détail de pitch fourni pour ce projet.', style: const TextStyle(fontSize: 16, height: 1.6)),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Résumé financier', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        _buildDetailRow('Montant recherché', '${projet['budget_recherche']} MAD'),
                        _buildDetailRow('Secteur', projet['secteur'] ?? 'N/A'),
                        _buildDetailRow('Stade', projet['stade_evolution'] ?? 'N/A'),
                        _buildDetailRow('Trust Score', '${projet['trust_score']}/10'),
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Votre demande de rendez-vous pour "${projet['nom']}" a été envoyée !'),
                                  backgroundColor: NexaColors.primaryGreen,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
                            child: const Text('Prendre rendez-vous', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Téléchargement du Business Plan en cours...'),
                                  backgroundColor: NexaColors.darkNavy,
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(foregroundColor: NexaColors.darkNavy),
                            child: const Text('Télécharger le Business Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: NexaColors.darkNavy)),
        ],
      ),
    );
  }
}
