import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../../theme/app_theme.dart';
import '../../../config/api_config.dart';
import '../../../services/api_service.dart';

class ServiceDetailPage extends StatefulWidget {
  final Map<String, dynamic> service;
  final Map<String, dynamic>? userData;
  
  const ServiceDetailPage({super.key, required this.service, this.userData});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  String _selectedTier = 'basique';

  Future<void> _placeOrder() async {
    try {
      final body = {
        'serviceId': widget.service['id'],
        'tier': _selectedTier,
        'brief': 'Brief de test pour la commande NexaMa.',
      };

      final response = await ApiService.post(
        ApiConfig.uri('/api/marketplace/orders'),
        body: body
      );

      if (response.statusCode == 201 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande créée avec succès ! Paiement mis sous séquestre.'), backgroundColor: Colors.green)
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Order error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final p = s['prestataire'];

    return Scaffold(
      appBar: AppBar(
        title: Text(s['titre'], style: const TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: const Color(0xFFFAFBFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Details & Portfolio
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainImage(),
                  const SizedBox(height: 32),
                  Text('À propos de ce service', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(s['description'] ?? 'Pas de description disponible.', style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87)),
                  const SizedBox(height: 40),
                  Text('À propos du prestataire', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildProviderCard(p),
                ],
              ),
            ),
            const SizedBox(width: 40),
            // Right Column: Pricing Tiers
            Expanded(
              flex: 1,
              child: _buildPricingSidebar(s),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainImage() {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(image: NetworkImage('https://via.placeholder.com/800x500'), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildProviderCard(dynamic p) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(p['avatar_url'] ?? '')),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['nom_complet'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(p['prestataire_profile']['bio'] ?? 'Expert certifié NexaMa', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('${p['prestataire_profile']['score_reputation']} (24 avis)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(onPressed: () {}, child: const Text('Contacter')),
        ],
      ),
    );
  }

  Widget _buildPricingSidebar(dynamic s) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          Row(
            children: [
              _buildTierTab('Basique', 'basique'),
              _buildTierTab('Standard', 'standard'),
              _buildTierTab('Premium', 'premium'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    Text('${_getPrice(s)} MAD', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: NexaColors.primaryGreen)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Détails du pack :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildPackFeature(Icons.timer_outlined, '${s['delai_livraison']} jours de livraison'),
                _buildPackFeature(Icons.refresh, '2 Révisions incluses'),
                _buildPackFeature(Icons.file_present, 'Fichiers sources fournis'),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _placeOrder,
                    style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('COMMANDER MAINTENANT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(child: Text('Paiement sécurisé par Séquestre NexaMa', style: TextStyle(fontSize: 11, color: Colors.grey))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierTab(String label, String value) {
    final isSelected = _selectedTier == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTier = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSelected ? NexaColors.primaryGreen : Colors.transparent, width: 2)),
            color: isSelected ? Colors.white : Colors.grey[50],
          ),
          child: Center(
            child: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? NexaColors.primaryGreen : Colors.grey)),
          ),
        ),
      ),
    );
  }

  Widget _buildPackFeature(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  double _getPrice(dynamic s) {
    if (_selectedTier == 'standard') return s['prix_standard']?.toDouble() ?? s['prix_basique'].toDouble();
    if (_selectedTier == 'premium') return s['prix_premium']?.toDouble() ?? s['prix_basique'].toDouble();
    return s['prix_basique'].toDouble();
  }
}
