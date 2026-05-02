import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

class FavorisPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const FavorisPage({super.key, this.userData});

  @override
  State<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  bool _isLoading = true;
  List<dynamic> _favoris = [];

  @override
  void initState() {
    super.initState();
    _fetchFavoris();
  }

  Future<void> _fetchFavoris() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/invest/favoris/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          _favoris = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Projets Favoris', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Retrouvez la liste des projets que vous avez sauvegardés.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),
        if (_favoris.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('Aucun projet en favoris pour le moment.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        else
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.8),
              itemCount: _favoris.length,
              itemBuilder: (context, index) {
                final p = _favoris[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: NexaColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(p['secteur'] ?? 'Secteur', style: const TextStyle(color: NexaColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold))),
                          const Icon(Icons.favorite, color: Colors.red, size: 18),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(p['nom'] ?? 'Projet', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: NexaColors.darkNavy)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${p['budget_recherche']} MAD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Score: ${p['trust_score']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          )
      ],
    );
  }
}
