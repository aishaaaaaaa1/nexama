import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class PortfolioPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const PortfolioPage({super.key, this.userData});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _projects = [];

  String get _userId => widget.userData?['id']?.toString() ?? 'user_123';

  @override
  void initState() {
    super.initState();
    _fetchPortfolio();
  }

  Future<void> _fetchPortfolio() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/prestataire/portfolio/$_userId'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && mounted) {
          setState(() {
            _projects = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Mon Portfolio', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy))),
            ElevatedButton.icon(
              onPressed: _showAddProjectDialog,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Ajouter un projet'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _projects.isEmpty
              ? const Center(child: Text('Aucun projet dans le portfolio.'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) => _buildProjectCard(_projects[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
              child: const Center(child: Icon(Icons.image_outlined, size: 48, color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${project['titre']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${project['categorie']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddProjectDialog() async {
    final titleCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter au Portfolio', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Titre du projet', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {'titre': titleCtrl.text.trim(), 'categorie': categoryCtrl.text.trim()}),
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    titleCtrl.dispose();
    categoryCtrl.dispose();
    if (result == null || result['titre']!.isEmpty || !mounted) return;

    var project = <String, dynamic>{...result, 'id': 'local-${DateTime.now().millisecondsSinceEpoch}'};
    try {
      final response = await ApiService.post(ApiConfig.uri('/api/prestataire/portfolio/$_userId'), body: result);
      if (response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['project'] is Map) project = Map<String, dynamic>.from(decoded['project'] as Map);
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() => _projects.insert(0, project));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Projet ajouté avec succès.'), backgroundColor: NexaColors.primaryGreen, behavior: SnackBarBehavior.floating));
  }
}
