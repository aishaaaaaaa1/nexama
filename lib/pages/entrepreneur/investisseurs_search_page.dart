import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class InvestisseursSearchPage extends StatefulWidget {
  final VoidCallback? onContact;
  final Map<String, dynamic>? userData;
  const InvestisseursSearchPage({super.key, this.onContact, this.userData});
  @override
  State<InvestisseursSearchPage> createState() => _InvestisseursSearchPageState();
}

class _InvestisseursSearchPageState extends State<InvestisseursSearchPage> {
  String? _filterSecteur;
  String? _filterRegion;
  String? _filterStade;

  final _investisseurs = [
    {'nom': 'Karim Alami', 'type': 'Business Angel', 'secteurs': ['AgriTech', 'Fintech'], 'region': 'Casablanca', 'stade': 'Amorçage', 'budget_min': 100000, 'budget_max': 500000, 'score': 92, 'investissements': 8},
    {'nom': 'Sara Bennis', 'type': 'Venture Capital', 'secteurs': ['Edtech', 'HealthTech'], 'region': 'Rabat', 'stade': 'Croissance', 'budget_min': 500000, 'budget_max': 5000000, 'score': 87, 'investissements': 15},
    {'nom': 'Omar Tazi', 'type': 'Business Angel', 'secteurs': ['Logistique', 'Energie'], 'region': 'Tanger', 'stade': 'Amorçage', 'budget_min': 200000, 'budget_max': 1000000, 'score': 78, 'investissements': 4},
    {'nom': 'Fatima Zohra El Amri', 'type': 'Fonds d\'investissement', 'secteurs': ['HealthTech', 'AgriTech'], 'region': 'Marrakech', 'stade': 'Expansion', 'budget_min': 1000000, 'budget_max': 10000000, 'score': 95, 'investissements': 22},
    {'nom': 'Rachid Kettani', 'type': 'Business Angel', 'secteurs': ['Fintech', 'Edtech'], 'region': 'Casablanca', 'stade': 'Croissance', 'budget_min': 300000, 'budget_max': 2000000, 'score': 84, 'investissements': 11},
  ];

  List<Map<String, dynamic>> get _filtered {
    return _investisseurs.where((inv) {
      if (_filterSecteur != null && !(inv['secteurs'] as List).contains(_filterSecteur)) return false;
      if (_filterRegion != null && inv['region'] != _filterRegion) return false;
      if (_filterStade != null && inv['stade'] != _filterStade) return false;
      return true;
    }).toList()..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Trouver des Investisseurs', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          Text('${results.length} investisseurs correspondent à votre profil.', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        ]),
        ElevatedButton.icon(onPressed: _showFilterDialog, icon: const Icon(Icons.filter_list, size: 18), label: const Text('Filtres Avancés'),
          style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white)),
      ]),
      const SizedBox(height: 16),

      // Active filters
      if (_filterSecteur != null || _filterRegion != null || _filterStade != null)
        Padding(padding: const EdgeInsets.only(bottom: 16), child: Wrap(spacing: 8, children: [
          if (_filterSecteur != null) _chip('Secteur: $_filterSecteur', () => setState(() => _filterSecteur = null)),
          if (_filterRegion != null) _chip('Région: $_filterRegion', () => setState(() => _filterRegion = null)),
          if (_filterStade != null) _chip('Stade: $_filterStade', () => setState(() => _filterStade = null)),
          TextButton(onPressed: () => setState(() { _filterSecteur = null; _filterRegion = null; _filterStade = null; }),
            child: const Text('Réinitialiser', style: TextStyle(color: Colors.red, fontSize: 12))),
        ])),

      // Quick stade chips
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['Tous', 'Amorçage', 'Croissance', 'Expansion'].map((s) {
        final active = _filterStade == s || (s == 'Tous' && _filterStade == null);
        return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(label: Text(s), selected: active,
          onSelected: (_) => setState(() => _filterStade = s == 'Tous' ? null : s),
          selectedColor: NexaColors.primaryGreen.withOpacity(0.1), checkmarkColor: NexaColors.primaryGreen,
          labelStyle: TextStyle(color: active ? NexaColors.primaryGreen : const Color(0xFF64748B), fontWeight: active ? FontWeight.bold : FontWeight.normal, fontSize: 12),
          backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: active ? NexaColors.primaryGreen : const Color(0xFFE2E8F0)))));
      }).toList())),
      const SizedBox(height: 24),

      // Results
      ListView.separated(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: results.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final inv = results[i];
          final score = inv['score'] as int;
          final scoreColor = score >= 90 ? NexaColors.primaryGreen : (score >= 80 ? Colors.orange : const Color(0xFF64748B));
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)]),
            child: Row(children: [
              // Avatar + Score
              Stack(children: [
                CircleAvatar(radius: 28, backgroundColor: scoreColor.withOpacity(0.1), child: Text(inv['nom'].toString().split(' ').map((w) => w[0]).join(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: scoreColor))),
                Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: scoreColor, borderRadius: BorderRadius.circular(8)),
                  child: Text('$score%', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))),
              ]),
              const SizedBox(width: 20),
              // Info
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(inv['nom'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: NexaColors.darkNavy)),
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                    child: Text(inv['type'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold))),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  ...(inv['secteurs'] as List).map((s) => Padding(padding: const EdgeInsets.only(right: 6), child: _tag(s))),
                  _tag(inv['region'] as String),
                  _tag(inv['stade'] as String),
                ]),
                const SizedBox(height: 6),
                Text('${inv['investissements']} investissements • ${inv['budget_min']}–${inv['budget_max']} MAD', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              ])),
              // Actions
              Column(children: [
                ElevatedButton.icon(onPressed: () => _showContactDialog(inv), icon: const Icon(Icons.chat_bubble_outline, size: 16), label: const Text('Contacter'),
                  style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, elevation: 0)),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: () => _showProfilSheet(inv),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE2E8F0))),
                  child: const Text('Voir profil', style: TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
              ]),
            ]),
          );
        },
      ),
    ]));
  }

  Widget _chip(String label, VoidCallback onRemove) => Chip(label: Text(label, style: const TextStyle(fontSize: 11)), deleteIcon: const Icon(Icons.close, size: 14),
    onDeleted: onRemove, backgroundColor: NexaColors.primaryGreen.withOpacity(0.1), side: BorderSide.none);

  Widget _tag(String label) => Container(margin: const EdgeInsets.only(right: 4), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.bold)));

  void _showFilterDialog() {
    String? ts = _filterSecteur, tr = _filterRegion, tst = _filterStade;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Filtres Avancés', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(value: ts, decoration: const InputDecoration(labelText: 'Secteur', border: OutlineInputBorder()),
          items: [null, 'AgriTech', 'Fintech', 'Edtech', 'HealthTech', 'Logistique', 'Energie'].map((s) => DropdownMenuItem(value: s, child: Text(s ?? 'Tous'))).toList(), onChanged: (v) => ts = v),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(value: tr, decoration: const InputDecoration(labelText: 'Région', border: OutlineInputBorder()),
          items: [null, 'Casablanca', 'Rabat', 'Marrakech', 'Tanger', 'Agadir'].map((r) => DropdownMenuItem(value: r, child: Text(r ?? 'Toutes'))).toList(), onChanged: (v) => tr = v),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(value: tst, decoration: const InputDecoration(labelText: 'Stade préféré', border: OutlineInputBorder()),
          items: [null, 'Amorçage', 'Croissance', 'Expansion'].map((s) => DropdownMenuItem(value: s, child: Text(s ?? 'Tous'))).toList(), onChanged: (v) => tst = v),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        ElevatedButton(onPressed: () { setState(() { _filterSecteur = ts; _filterRegion = tr; _filterStade = tst; }); Navigator.pop(ctx); },
          style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white), child: const Text('Appliquer')),
      ],
    ));
  }

  void _showContactDialog(Map<String, dynamic> inv) {
    final msgController = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Contacter ${inv['nom']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      content: SizedBox(width: 450, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          CircleAvatar(radius: 20, backgroundColor: NexaColors.primaryGreen.withOpacity(0.1),
            child: Text((inv['nom'] as String).split(' ').map((w) => w[0]).join(), style: const TextStyle(fontWeight: FontWeight.bold, color: NexaColors.primaryGreen))),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(inv['nom'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(inv['type'] as String, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          ]),
        ]),
        const SizedBox(height: 20),
        TextField(controller: msgController, maxLines: 4,
          decoration: const InputDecoration(labelText: 'Votre message', hintText: 'Bonjour, je souhaite vous présenter mon projet...', border: OutlineInputBorder(), alignLabelWithHint: true)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message envoyé à ${inv['nom']} !'), backgroundColor: Colors.green));
          },
          icon: const Icon(Icons.send, size: 16),
          label: const Text('Envoyer'),
          style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
        ),
      ],
    ));
  }

  void _showProfilSheet(Map<String, dynamic> inv) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Profil Investisseur', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 24),
          // Header
          Row(children: [
            CircleAvatar(radius: 32, backgroundColor: NexaColors.primaryGreen.withOpacity(0.1),
              child: Text((inv['nom'] as String).split(' ').map((w) => w[0]).join(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: NexaColors.primaryGreen))),
            const SizedBox(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(inv['nom'] as String, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                child: Text(inv['type'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold))),
            ]),
          ]),
          const SizedBox(height: 24),
          // Stats
          Row(children: [
            _profilStat('Score Matching', '${inv['score']}%', NexaColors.primaryGreen),
            const SizedBox(width: 16),
            _profilStat('Investissements', '${inv['investissements']}', const Color(0xFF3B82F6)),
            const SizedBox(width: 16),
            _profilStat('Région', inv['region'] as String, const Color(0xFFF59E0B)),
          ]),
          const SizedBox(height: 24),
          // Détails
          Text('Secteurs d\'intérêt', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: (inv['secteurs'] as List).map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 12)),
            backgroundColor: NexaColors.primaryGreen.withOpacity(0.1), side: BorderSide.none)).toList()),
          const SizedBox(height: 20),
          _profilRow('Stade préféré', inv['stade'] as String),
          _profilRow('Budget d\'investissement', '${inv['budget_min']} – ${inv['budget_max']} MAD'),
          _profilRow('Localisation', inv['region'] as String),
          _profilRow('Membre depuis', 'Janvier 2024'),
          const SizedBox(height: 24),
          // Action
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () { Navigator.pop(ctx); _showContactDialog(inv); },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Envoyer un message'),
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
          )),
        ])),
      ),
    );
  }

  Widget _profilStat(String label, String val, Color color) {
    return Expanded(child: Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ]),
    ));
  }

  Widget _profilRow(String label, String val) => Padding(padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [Text('$label : ', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)), Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]));
}
