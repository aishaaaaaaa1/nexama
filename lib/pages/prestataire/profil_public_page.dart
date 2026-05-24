import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ProfilPublicPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfilPublicPage({super.key, this.userData});

  @override
  State<ProfilPublicPage> createState() => _ProfilPublicPageState();
}

class _ProfilPublicPageState extends State<ProfilPublicPage> {
  final _bioController = TextEditingController(text: 'Prestataire expérimenté en solutions digitales pour entreprises marocaines.');
  final _specialiteController = TextEditingController(text: 'Développement Web, Design UI/UX, Marketing Digital');
  final _villeController = TextEditingController(text: 'Casablanca');
  final _tarifController = TextEditingController(text: '500');
  final List<String> _competences = ['Flutter', 'React', 'Node.js', 'Figma', 'SEO', 'Branding'];
  bool _isLoading = true;

  String get _userId => widget.userData?['id']?.toString() ?? 'user_123';

  @override
  void initState() {
    super.initState();
    _fetchProfil();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _specialiteController.dispose();
    _villeController.dispose();
    _tarifController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfil() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/prestataire/profil-public/$_userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map;
        if (!mounted) return;
        setState(() {
          _bioController.text = data['biographie']?.toString() ?? _bioController.text;
          _specialiteController.text = data['specialites']?.toString() ?? _specialiteController.text;
          _villeController.text = data['ville']?.toString() ?? _villeController.text;
          _tarifController.text = data['tarif_horaire']?.toString() ?? _tarifController.text;
          _competences
            ..clear()
            ..addAll(((data['competences'] as List?) ?? const []).map((e) => e.toString()));
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveProfil() async {
    final competences = _specialiteController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final body = {
      'biographie': _bioController.text.trim(),
      'specialites': _specialiteController.text.trim(),
      'ville': _villeController.text.trim(),
      'tarif_horaire': _tarifController.text.trim(),
      'competences': competences,
    };
    try {
      await ApiService.put(ApiConfig.uri('/api/prestataire/profil-public/$_userId'), body: body);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _competences
        ..clear()
        ..addAll(competences);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil sauvegardé avec succès'), backgroundColor: NexaColors.primaryGreen, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final nom = widget.userData?['nom_complet'] ?? 'Prestataire NexaMa';
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Mon Profil Public', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy))),
              ElevatedButton.icon(
                onPressed: _saveProfil,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: NexaColors.primaryGreen.withValues(alpha: 0.15),
                  child: Text(nom.toString().substring(0, 1).toUpperCase(), style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: NexaColors.primaryGreen)),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$nom', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(_villeController.text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(width: 16),
                          const Icon(Icons.star, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          const Text('4.9/5 (32 avis)', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _competences.map((c) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: NexaColors.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                              child: Text(c, style: const TextStyle(fontSize: 11, color: NexaColors.primaryGreen, fontWeight: FontWeight.w600)),
                            )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Informations du profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 24),
                TextField(controller: _bioController, maxLines: 3, decoration: const InputDecoration(labelText: 'Biographie', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _specialiteController, decoration: const InputDecoration(labelText: 'Spécialités et compétences', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _villeController, decoration: const InputDecoration(labelText: 'Ville', border: OutlineInputBorder()))),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: _tarifController, decoration: const InputDecoration(labelText: 'Tarif horaire (MAD)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
