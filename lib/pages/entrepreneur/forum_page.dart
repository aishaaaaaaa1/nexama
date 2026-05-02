import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class ForumPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ForumPage({super.key, this.userData});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  bool _isLoading = true;
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/entrepreneur/forum'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _posts = json.decode(response.body);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addPost() async {
    final titreController = TextEditingController();
    final contenuController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Poser une question'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titreController, decoration: const InputDecoration(labelText: 'Titre de la question', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: contenuController, decoration: const InputDecoration(labelText: 'Détails', border: OutlineInputBorder()), maxLines: 4),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            onPressed: () async {
              if (titreController.text.isEmpty) return;
              final response = await ApiService.post(
                ApiConfig.uri('/api/entrepreneur/forum'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'utilisateur_id': 'user_123', // Dummy ID
                  'titre': titreController.text,
                  'contenu': contenuController.text,
                  'categorie': 'Général'
                }),
              );
              if (response.statusCode == 201) {
                if (mounted) Navigator.pop(context);
                _fetchPosts();
              }
            },
            child: const Text('Publier'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Forum Communautaire', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const Text('Posez vos questions et entraidez-vous entre auto-entrepreneurs.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _addPost,
              icon: const Icon(Icons.add),
              label: const Text('Poser une question'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            final post = _posts[index];
            final userName = post['utilisateur']?['nom_complet'] ?? 'Moi';
            final repliesCount = (post['replies'] as List?)?.length ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(backgroundColor: NexaColors.primaryGreen.withValues(alpha: 0.1), child: const Icon(Icons.person, color: NexaColors.primaryGreen)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(post['titre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                              child: Text(post['categorie'] ?? 'Général', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(post['contenu'], style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text('Par $userName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 8),
                            Text(post['created_at'].toString().substring(0, 10), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('$repliesCount réponses', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
