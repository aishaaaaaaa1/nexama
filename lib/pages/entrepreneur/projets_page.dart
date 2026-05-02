import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class ProjetsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProjetsPage({super.key, this.userData});

  @override
  State<ProjetsPage> createState() => _ProjetsPageState();
}

class _ProjetsPageState extends State<ProjetsPage> {
  bool _isLoading = true;
  List<dynamic> _projets = [];

  @override
  void initState() {
    super.initState();
    _fetchProjets();
  }

  Future<void> _fetchProjets() async {
    try {
      final userId = widget.userData?['id'];
      if (userId == null) return;
      
      final response = await ApiService.get(ApiConfig.uri('/api/entrepreneur/projets/$userId'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _projets = json.decode(response.body);
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

  Future<void> _submitProjet(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post(
        ApiConfig.uri('/api/entrepreneur/projets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          ...data,
          'entrepreneur_id': widget.userData?['id'],
        }),
      );

      if (response.statusCode == 201) {
        _fetchProjets();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Projet déposé avec succès !'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du dépôt du projet'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddProjectDialog() {
    final formKey = GlobalKey<FormState>();
    String nom = '';
    String description = '';
    String secteur = 'Technologie';
    String ville = '';
    double budget = 0;
    String stade = 'Idée';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouveau Projet', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom du Projet', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                    onSaved: (v) => nom = v!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 3,
                    validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                    onSaved: (v) => description = v!,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: secteur,
                          decoration: const InputDecoration(labelText: 'Secteur', border: OutlineInputBorder()),
                          items: ['Technologie', 'Agriculture', 'Services', 'Industrie', 'Santé']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => secteur = v!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Ville', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                          onSaved: (v) => ville = v!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Budget (MAD)', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                          onSaved: (v) => budget = double.tryParse(v!) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: stade,
                          decoration: const InputDecoration(labelText: 'Stade', border: OutlineInputBorder()),
                          items: ['Idée', 'Amorçage', 'MVP', 'Croissance']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => stade = v!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                _submitProjet({
                  'nom': nom,
                  'description': description,
                  'secteur': secteur,
                  'ville': ville,
                  'budget_recherche': budget,
                  'stade_evolution': stade,
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Déposer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Expanded(child: SingleChildScrollView(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mes Projets', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const Text('Gérez vos projets et suivez leur avancement.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showAddProjectDialog,
              icon: const Icon(Icons.add),
              label: const Text('Déposer un Projet'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            )

          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.2),
          itemCount: _projets.length,
          itemBuilder: (context, index) {
            final p = _projets[index];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: p['statut'] == 'valide' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(p['statut'].toUpperCase(), style: TextStyle(color: p['statut'] == 'valide' ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (value) {
                          if (value == 'edit') {
                            // Logic to edit
                          } else if (value == 'delete') {
                            // Logic to delete
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Modifier')])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: Colors.red))])),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(p['titre'], style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                  const SizedBox(height: 8),
                  Text('Budget recherché: ${p['budget']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(p['progression'] * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Détails de "${p['titre']}"')));
                        },
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Détails'),
                        style: TextButton.styleFrom(foregroundColor: NexaColors.primaryGreen, padding: EdgeInsets.zero),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        )
      ],
    )));
  }
}
