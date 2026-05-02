import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import './pitch_viewer_page.dart';

class ProjetsDecouvrirPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProjetsDecouvrirPage({super.key, this.userData});
  @override
  State<ProjetsDecouvrirPage> createState() => _ProjetsDecouvrirPageState();
}

class _ProjetsDecouvrirPageState extends State<ProjetsDecouvrirPage> {
  bool _isLoading = true;
  List<dynamic> _projets = [];
  String? _filterSecteur;
  String? _filterRegion;
  String? _filterStade;

  final _secteurs = ['Tous', 'Agritech', 'Edtech', 'Fintech', 'HealthTech', 'Logistique', 'Energie'];
  final _regions = ['Toutes', 'Casablanca', 'Rabat', 'Marrakech', 'Agadir', 'Tanger', 'Ouarzazate'];
  final _stades = ['Tous', 'Amorçage', 'Croissance', 'Expansion'];

  final _statusLabels = {'nouveau': 'Nouveau', 'vu': 'Vu', 'interesse': 'Intéressé', 'en_discussion': 'En discussion', 'cloture': 'Clôturé'};
  final _statusColors = {'nouveau': Colors.blue, 'vu': Colors.grey, 'interesse': Colors.orange, 'en_discussion': NexaColors.primaryGreen, 'cloture': Colors.red};

  @override
  void initState() { super.initState(); _fetchProjets(); }

  Future<void> _fetchProjets() async {
    setState(() => _isLoading = true);
    try {
      String url = '/api/invest/projets?';
      if (_filterSecteur != null && _filterSecteur != 'Tous') url += 'secteur=$_filterSecteur&';
      if (_filterRegion != null && _filterRegion != 'Toutes') url += 'region=$_filterRegion&';
      if (_filterStade != null && _filterStade != 'Tous') url += 'stade=$_filterStade&';
      final response = await ApiService.get(ApiConfig.uri(url));
      if (response.statusCode == 200 && mounted) {
        setState(() { _projets = json.decode(response.body); _isLoading = false; });
      } else { if (mounted) setState(() => _isLoading = false); }
    } catch (e) { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Padding(padding: const EdgeInsets.only(bottom: 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Projets à découvrir', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          const SizedBox(height: 4),
          Text('${_projets.length} projets correspondent à vos critères.', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        ]),
        ElevatedButton.icon(onPressed: _showFilterDialog, icon: const Icon(Icons.filter_list, size: 18), label: const Text('Filtres avancés'),
          style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white)),
      ]),
      const SizedBox(height: 16),

      // Active filters
      if (_filterSecteur != null || _filterRegion != null || _filterStade != null)
        Padding(padding: const EdgeInsets.only(bottom: 16), child: Wrap(spacing: 8, children: [
          if (_filterSecteur != null && _filterSecteur != 'Tous') _filterChip('Secteur: $_filterSecteur', () => setState(() { _filterSecteur = null; _fetchProjets(); })),
          if (_filterRegion != null && _filterRegion != 'Toutes') _filterChip('Région: $_filterRegion', () => setState(() { _filterRegion = null; _fetchProjets(); })),
          if (_filterStade != null && _filterStade != 'Tous') _filterChip('Stade: $_filterStade', () => setState(() { _filterStade = null; _fetchProjets(); })),
          TextButton(onPressed: () => setState(() { _filterSecteur = null; _filterRegion = null; _filterStade = null; _fetchProjets(); }), child: const Text('Réinitialiser', style: TextStyle(color: Colors.red, fontSize: 12))),
        ])),

      // Quick filter chips
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _stades.map((s) {
        final active = _filterStade == s || (s == 'Tous' && _filterStade == null);
        return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(
          label: Text(s),
          selected: active,
          onSelected: (_) { setState(() => _filterStade = s == 'Tous' ? null : s); _fetchProjets(); },
          selectedColor: NexaColors.primaryGreen.withOpacity(0.1),
          checkmarkColor: NexaColors.primaryGreen,
          labelStyle: TextStyle(color: active ? NexaColors.primaryGreen : const Color(0xFF64748B), fontWeight: active ? FontWeight.bold : FontWeight.normal, fontSize: 12),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: active ? NexaColors.primaryGreen : const Color(0xFFE2E8F0))),
        ));
      }).toList())),
      const SizedBox(height: 24),

      if (_isLoading) const Center(child: CircularProgressIndicator())
      else if (_projets.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(60), child: Text("Aucun projet ne correspond à vos critères.", style: TextStyle(color: Color(0xFF64748B)))))
      else GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.35),
        itemCount: _projets.length,
        itemBuilder: (context, i) => _buildProjectCard(_projets[i]),
      ),
    ])));
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Chip(label: Text(label, style: const TextStyle(fontSize: 11)), deleteIcon: const Icon(Icons.close, size: 14), onDeleted: onRemove,
      backgroundColor: NexaColors.primaryGreen.withOpacity(0.1), side: BorderSide.none);
  }

  Widget _buildProjectCard(dynamic p) {
    final statut = p['statut_matching'] ?? 'nouveau';
    final statusColor = _statusColors[statut] ?? Colors.blue;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
              child: Text(p['secteur'] ?? '', style: const TextStyle(color: NexaColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_on, size: 10, color: Color(0xFF64748B)), const SizedBox(width: 2), Text(p['ville'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)))])),
          ]),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(_statusLabels[statut] ?? statut, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            const Icon(Icons.shield, color: NexaColors.primaryGreen, size: 14), const SizedBox(width: 2),
            Text('${p['trust_score'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ]),
        const SizedBox(height: 14),
        Text(p['nom'] ?? '', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const SizedBox(height: 6),
        Expanded(child: Text(p['description'] ?? '', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis)),
        const Divider(height: 20, color: Color(0xFFE2E8F0)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Budget', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
            Text('${p['budget_recherche']} MAD', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: NexaColors.darkNavy)),
          ]),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6)),
              child: Text(p['stade_evolution'] ?? '', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.bookmark_border, size: 20, color: Color(0xFF64748B)),
              onSelected: (val) async {
                try {
                  await ApiService.post(ApiConfig.uri('/api/invest/projets/${p['id']}/interet'), headers: {'Content-Type': 'application/json'}, body: json.encode({'investisseur_id': widget.userData?['id'], 'statut': val}));
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Statut: ${_statusLabels[val]}'), backgroundColor: Colors.green));
                  _fetchProjets();
                } catch (_) {}
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'interesse', child: Row(children: [Icon(Icons.thumb_up, size: 16, color: Colors.orange), SizedBox(width: 8), Text('Intéressé')])),
                const PopupMenuItem(value: 'en_discussion', child: Row(children: [Icon(Icons.chat, size: 16, color: Colors.green), SizedBox(width: 8), Text('En discussion')])),
                const PopupMenuItem(value: 'cloture', child: Row(children: [Icon(Icons.check_circle, size: 16, color: Colors.red), SizedBox(width: 8), Text('Clôturer')])),
              ],
            ),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PitchViewerPage(projet: p))),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16)),
              child: const Text('Pitch', style: TextStyle(fontSize: 12))),
          ]),
        ]),
      ]),
    );
  }

  void _showFilterDialog() {
    String? tempSecteur = _filterSecteur;
    String? tempRegion = _filterRegion;
    String? tempStade = _filterStade;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Filtres Avancés', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(value: tempSecteur ?? 'Tous', decoration: const InputDecoration(labelText: 'Secteur', border: OutlineInputBorder()),
          items: _secteurs.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => tempSecteur = v),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(value: tempRegion ?? 'Toutes', decoration: const InputDecoration(labelText: 'Région / Ville', border: OutlineInputBorder()),
          items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(), onChanged: (v) => tempRegion = v),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(value: tempStade ?? 'Tous', decoration: const InputDecoration(labelText: 'Stade de développement', border: OutlineInputBorder()),
          items: _stades.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => tempStade = v),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        ElevatedButton(onPressed: () {
          setState(() { _filterSecteur = tempSecteur; _filterRegion = tempRegion; _filterStade = tempStade; });
          Navigator.pop(ctx);
          _fetchProjets();
        }, style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white), child: const Text('Appliquer')),
      ],
    ));
  }
}
