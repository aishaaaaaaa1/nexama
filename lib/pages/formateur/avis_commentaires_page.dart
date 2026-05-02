import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

class AvisCommentairesPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const AvisCommentairesPage({super.key, this.userData});

  @override
  State<AvisCommentairesPage> createState() => _AvisCommentairesPageState();
}

class _AvisCommentairesPageState extends State<AvisCommentairesPage> {
  bool _isLoading = true;
  List<dynamic> _avis = [];

  @override
  void initState() {
    super.initState();
    _fetchAvis();
  }

  Future<void> _fetchAvis() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/avis/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          _avis = json.decode(response.body);
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
        Text('Avis & Commentaires', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const Text('Ce que vos apprenants disent de vos cours.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            itemCount: _avis.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final a = _avis[index];
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(child: Text(a['eleve'][0])),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a['eleve'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(a['date'] ?? 'Récemment', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(5, (i) => Icon(Icons.star, color: i < a['note'] ? Colors.amber : Colors.grey[300], size: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(a['texte'], style: const TextStyle(height: 1.5)),
                    const SizedBox(height: 16),
                    TextButton(onPressed: () {}, child: const Text('Répondre'))
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
