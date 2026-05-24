import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'pipeline_config.dart';

class DealDetailModal extends StatefulWidget {
  final Map<String, dynamic> deal;
  final PipelineConfig config;
  final void Function(String newStatus) onStatusChanged;

  const DealDetailModal({
    super.key,
    required this.deal,
    required this.config,
    required this.onStatusChanged,
  });

  static void show(
    BuildContext context, {
    required Map<String, dynamic> deal,
    required PipelineConfig config,
    required void Function(String newStatus) onStatusChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DealDetailModal(
        deal: deal,
        config: config,
        onStatusChanged: onStatusChanged,
      ),
    );
  }

  @override
  State<DealDetailModal> createState() => _DealDetailModalState();
}

class _DealDetailModalState extends State<DealDetailModal> with SingleTickerProviderStateMixin {
  late TabController _dealTabController;
  late Map<String, dynamic> _deal;

  @override
  void initState() {
    super.initState();
    _deal = Map<String, dynamic>.from(widget.deal);
    _dealTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _dealTabController.dispose();
    super.dispose();
  }

  void _changeStatus(String v) {
    setState(() {
      _deal['statut'] = v;
      (_deal['historique'] as List?)?.insert(0, 'Déplacé vers ${widget.config.titresColonnes[v]}');
    });
    widget.onStatusChanged(v);
  }

  bool get _canTriggerRelance {
    final s = _deal['statut']?.toString() ?? '';
    return s == 'facture' || s == 'devis' || s == 'nego';
  }

  @override
  Widget build(BuildContext context) {
    final statut = _deal['statut']?.toString() ?? widget.config.colonnes.first;
    final statutColor = widget.config.couleursColonnes[statut] ?? NexaColors.primaryGreen;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dealCompanyName(_deal),
                        style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: NexaColors.darkNavy),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            dealContactName(_deal).isEmpty ? 'Contact N/A' : dealContactName(_deal),
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.monetization_on, size: 16, color: NexaColors.primaryGreen),
                          const SizedBox(width: 4),
                          Text(
                            '${dealAmount(_deal).toInt()} MAD',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: NexaColors.primaryGreen, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statutColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        widget.config.titresColonnes[statut] ?? statut,
                        style: TextStyle(color: statutColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: widget.config.colonnes.contains(statut) ? statut : widget.config.colonnes.first,
                      underline: const SizedBox(),
                      items: widget.config.colonnes
                          .map((c) => DropdownMenuItem(value: c, child: Text(widget.config.titresColonnes[c]!)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) _changeStatus(v);
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
          ),
          TabBar(
            controller: _dealTabController,
            labelColor: NexaColors.primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: NexaColors.primaryGreen,
            tabs: const [
              Tab(text: 'Historique & Interactions'),
              Tab(text: 'Devis & Documents'),
              Tab(text: 'Relances Auto'),
            ],
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.all(32),
              child: TabBarView(
                controller: _dealTabController,
                children: [
                  _buildHistoriqueTab(),
                  _buildDocumentsTab(),
                  _buildRelancesTab(statut),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoriqueTab() {
    final hist = (_deal['historique'] as List?)?.cast<String>() ?? <String>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Ajouter une note d\'appel...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  hist.insert(0, 'Note ajoutée à l\'instant');
                  _deal['historique'] = hist;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NexaColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(Icons.send),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: hist.isEmpty
              ? Center(child: Text('Aucune interaction enregistrée.', style: GoogleFonts.inter(color: const Color(0xFF64748B))))
              : ListView.builder(
                  itemCount: hist.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 10, color: NexaColors.primaryGreen),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(hist[i]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab() {
    final docs = (_deal['documents'] as List?) ?? <dynamic>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Documents commerciaux', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  docs.insert(0, {'titre': 'Devis_${DateTime.now().millisecondsSinceEpoch}.pdf', 'signe': false});
                  _deal['documents'] = docs;
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Générer Devis'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.darkNavy, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: docs.isEmpty
              ? Center(child: Text('Aucun document.', style: GoogleFonts.inter(color: const Color(0xFF64748B))))
              : ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final doc = docs[i] as Map<String, dynamic>;
                    final isSigne = doc['signe'] == true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: isSigne ? Colors.green : Colors.red),
                          const SizedBox(width: 16),
                          Expanded(child: Text(doc['titre']?.toString() ?? 'Document', style: const TextStyle(fontWeight: FontWeight.bold))),
                          if (isSigne)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: const Text('SIGNÉ', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: () => _showSignaturePad(doc),
                              icon: const Icon(Icons.draw, size: 16),
                              label: const Text('Faire Signer'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRelancesTab(String statut) {
    final canRelance = _canTriggerRelance;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_lock_outlined, size: 64, color: canRelance ? Colors.red : Colors.grey),
          const SizedBox(height: 24),
          Text('Alertes & Relances Automatiques', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            canRelance
                ? 'Vous pouvez lancer une relance automatique pour ce prospect.'
                : 'Aucune relance nécessaire (statut : ${widget.config.titresColonnes[statut] ?? statut}).',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: canRelance
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('E-mail et SMS de relance envoyés avec succès !'), backgroundColor: Colors.green),
                    );
                  }
                : null,
            icon: const Icon(Icons.send),
            label: const Text('Déclencher la Relance'),
            style: ElevatedButton.styleFrom(
              backgroundColor: canRelance ? Colors.red : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignaturePad(Map<String, dynamic> doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Signature Électronique'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Veuillez signer dans le cadre ci-dessous :'),
            const SizedBox(height: 16),
            Container(
              width: 400,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFF1F5F9),
              ),
              child: const Center(child: Text('Zone de signature (Canvas)', style: TextStyle(color: Colors.grey))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              setState(() => doc['signe'] = true);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document signé électroniquement !'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Valider la signature'),
          ),
        ],
      ),
    );
  }
}
