import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<dynamic> _posts = [];
  bool _isLoading = true;
  String _selectedCategory = 'Tous';
  final List<String> _categories = ['Tous', 'Entraide', 'Fiscalité', 'Opportunités', 'Juridique', 'Conseils'];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final cat = _selectedCategory == 'Tous' ? '' : '?categorie=$_selectedCategory';
      final res = await ApiService.get(ApiConfig.uri('/api/forum$cat'));
      if (res.statusCode == 200) {
        setState(() {
          _posts = json.decode(res.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load forum error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildCategoryTabs(),
        const SizedBox(height: 24),
        _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Expanded(child: _buildPostList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Forum Communautaire NexaMa', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          const Text('Échangez, posez vos questions et aidez la communauté d\'entrepreneurs.', style: TextStyle(color: Color(0xFF64748B))),
        ]),
        ElevatedButton.icon(
          onPressed: () => _showCreatePostDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Nouvelle Discussion'),
          style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((c) {
          final isSelected = _selectedCategory == c;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(c),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedCategory = c);
                  _loadPosts();
                }
              },
              selectedColor: NexaColors.primaryGreen.withOpacity(0.1),
              labelStyle: TextStyle(color: isSelected ? NexaColors.primaryGreen : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPostList() {
    if (_posts.isEmpty) return const Center(child: Text('Aucune discussion dans cette catégorie. Soyez le premier !'));

    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (context, i) => _buildPostCard(_posts[i]),
    );
  }

  Widget _buildPostCard(dynamic post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
      elevation: 0,
      child: InkWell(
        onTap: () => _showPostDetail(post),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: NexaColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(post['categorie'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NexaColors.primaryGreen)),
                  ),
                  const Spacer(),
                  Text('il y a 2h', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Text(post['titre'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
              const SizedBox(height: 8),
              Text(post['contenu'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF475569), height: 1.5)),
              const SizedBox(height: 20),
              Row(
                children: [
                  const CircleAvatar(radius: 12, backgroundColor: Color(0xFFF1F5F9), child: Icon(Icons.person, size: 14, color: Colors.grey)),
                  const SizedBox(width: 8),
                  Text(post['utilisateur']['nom_complet'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Row(children: [const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey), const SizedBox(width: 6), Text('${post['_count']['replies']}', style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostDetail(dynamic post) {
    // Navigate to post detail (simulated here with a dialog for brevity)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(post['titre']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post['contenu']),
            const Divider(height: 32),
            const Text('Réponses (en cours d\'implémentation)', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer'))],
      ),
    );
  }

  void _showCreatePostDialog() {
    final titreController = TextEditingController();
    final contenuController = TextEditingController();
    String category = 'Entraide';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle Discussion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: category,
              isExpanded: true,
              items: _categories.where((c) => c != 'Tous').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => category = val!,
            ),
            TextField(controller: titreController, decoration: const InputDecoration(labelText: 'Titre')),
            TextField(controller: contenuController, decoration: const InputDecoration(labelText: 'Contenu'), maxLines: 4),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (titreController.text.isNotEmpty && contenuController.text.isNotEmpty) {
                await ApiService.post(ApiConfig.uri('/api/forum'), body: {
                  'titre': titreController.text,
                  'contenu': contenuController.text,
                  'categorie': category
                });
                Navigator.pop(ctx);
                _loadPosts();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Publier'),
          ),
        ],
      ),
    );
  }
}
