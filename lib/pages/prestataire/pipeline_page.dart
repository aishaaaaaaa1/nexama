import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../widgets/crm/deal_detail_modal.dart';
import '../../widgets/crm/pipeline_config.dart';
import '../../widgets/crm/pipeline_stats_row.dart';

class PipelinePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const PipelinePage({super.key, this.userData});

  @override
  State<PipelinePage> createState() => _PipelinePageState();
}

class _PipelinePageState extends State<PipelinePage> with SingleTickerProviderStateMixin {
  static final _pipeline = PipelineConfig.prestataire;
  static String _formatMad(num value) {
    final n = value.toInt().abs();
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  late TabController _mainTabController;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<Map<String, dynamic>> _deals = [];
  String? _draggingDealId;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() => setState(() {}));
    _fetchDeals();
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String get _userId => widget.userData?['id']?.toString() ?? 'user_123';

  List<Map<String, dynamic>> get _filteredDeals {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _deals;
    return _deals.where((d) => dealCompanyName(d).toLowerCase().contains(q)).toList();
  }

  Future<void> _fetchDeals() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/prestataire/crm/$_userId'));
      if (response.statusCode == 200 && mounted) {
        final raw = json.decode(response.body) as List<dynamic>;
        setState(() {
          _deals = raw.map((e) => normalizeDeal(Map<String, dynamic>.from(e as Map))).toList();
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : NexaColors.primaryGreen),
    );
  }

  Future<void> _addDeal() async {
    final entrepriseController = TextEditingController();
    final contactController = TextEditingController();
    final montantController = TextEditingController();
    String selectedStatus = 'prospects';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Nouveau prospect', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: entrepriseController,
                  decoration: const InputDecoration(labelText: 'Entreprise / client', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact (optionnel)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: montantController,
                  decoration: const InputDecoration(labelText: 'Montant estimé (MAD)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Étape initiale', border: OutlineInputBorder()),
                  items: _pipeline.colonnes
                      .map((c) => DropdownMenuItem(value: c, child: Text(_pipeline.titresColonnes[c]!)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedStatus = v ?? 'prospects'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (entrepriseController.text.trim().isEmpty) return;
                try {
                  final response = await ApiService.post(
                    ApiConfig.uri('/api/prestataire/crm/$_userId'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'nom_entreprise': entrepriseController.text.trim(),
                      'contact_nom': contactController.text.trim(),
                      'montant_estime': double.tryParse(montantController.text) ?? 0.0,
                      'statut': selectedStatus,
                    }),
                  );
                  if (response.statusCode == 201 && ctx.mounted) {
                    Navigator.pop(ctx);
                    _snack('Prospect ajouté avec succès');
                    _fetchDeals();
                  } else {
                    _snack('Erreur lors de l\'ajout', error: true);
                  }
                } catch (_) {
                  _snack('Erreur réseau', error: true);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateDealStatus(String dealId, String nouveauStatut, {bool silent = false}) async {
    final idx = _deals.indexWhere((d) => d['id']?.toString() == dealId);
    if (idx >= 0) {
      setState(() {
        _deals[idx]['statut'] = nouveauStatut;
        (_deals[idx]['historique'] as List?)?.insert(0, 'Déplacé vers ${_pipeline.titresColonnes[nouveauStatut]}');
      });
    }

    try {
      final response = await ApiService.put(
        ApiConfig.uri('/api/prestataire/crm/deal/$dealId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'statut': nouveauStatut}),
      );
      if (response.statusCode == 200) {
        if (!silent) _snack('Prospect déplacé vers ${_pipeline.titresColonnes[nouveauStatut]}');
        await _fetchDeals();
      } else if (!silent) {
        _snack('Échec de la mise à jour', error: true);
        await _fetchDeals();
      }
    } catch (_) {
      if (!silent) _snack('Erreur réseau', error: true);
    }
  }

  void _openDealDetail(Map<String, dynamic> deal) {
    DealDetailModal.show(
      context,
      deal: deal,
      config: _pipeline,
      onStatusChanged: (s) => _updateDealStatus(deal['id'].toString(), s),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: NexaColors.primaryGreen));
    }

    final filtered = _filteredDeals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pipeline CRM', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                  const SizedBox(height: 4),
                  Text(
                    'Suivez vos prospects de la prise de contact à la signature.',
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            _buildSearchBar(),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _addDeal,
              icon: const Icon(Icons.add),
              label: const Text('Nouveau prospect'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        PipelineStatsRow(deals: filtered, config: _pipeline, wonStatus: 'gagne'),
        const SizedBox(height: 20),
        TabBar(
          controller: _mainTabController,
          labelColor: NexaColors.primaryGreen,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: NexaColors.primaryGreen,
          tabs: const [
            Tab(text: 'Pipeline Kanban'),
            Tab(text: 'Reporting Synthèse'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _mainTabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildPipelineView(filtered),
              _buildReportingView(filtered),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: 220,
      height: 40,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        ),
      ),
    );
  }

  Widget _buildPipelineView(List<Map<String, dynamic>> deals) {
    if (_deals.isEmpty) {
      return _buildGlobalEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const boardHeight = 560.0;
        final useExpanded = constraints.maxWidth >= 900;

        final columns = _pipeline.colonnes.map((col) {
          final colDeals = deals.where((d) => d['statut'] == col).toList();
          final column = _buildPipelineColumn(col, colDeals, boardHeight);
          return useExpanded ? Expanded(child: column) : column;
        }).toList();

        if (useExpanded) {
          return SizedBox(
            height: boardHeight,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: columns),
          );
        }

        return SizedBox(
          height: boardHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: columns),
          ),
        );
      },
    );
  }

  Widget _buildGlobalEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.handshake_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Votre pipeline est vide', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre premier prospect pour commencer à suivre vos opportunités commerciales.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addDeal,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un prospect'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineColumn(String colonneId, List<Map<String, dynamic>> dealsInColumn, double height) {
    final color = _pipeline.couleursColonnes[colonneId]!;
    final totalMontant = dealsInColumn.fold(0.0, (s, d) => s + dealAmount(d));

    return Container(
      width: 280,
      height: height,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.35), width: 2)),
            ),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _pipeline.titresColonnes[colonneId]!,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: NexaColors.darkNavy),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  child: Text('${dealsInColumn.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Text('Total : ', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                Text(
                  '${_formatMad(totalMontant)} MAD',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NexaColors.darkNavy),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<String>(
              onWillAcceptWithDetails: (d) {
                Map<String, dynamic>? found;
                for (final x in _deals) {
                  if (x['id']?.toString() == d.data) {
                    found = x;
                    break;
                  }
                }
                return found != null && found['statut'] != colonneId;
              },
              onAcceptWithDetails: (d) {
                final dealId = d.data;
                _updateDealStatus(dealId, colonneId);
                setState(() => _draggingDealId = null);
              },
              builder: (context, candidate, rejected) {
                final highlight = candidate.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: highlight ? Border.all(color: NexaColors.primaryGreen, width: 2) : null,
                    color: highlight ? NexaColors.lightGreen.withValues(alpha: 0.3) : Colors.transparent,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      if (dealsInColumn.isEmpty && !highlight) _buildColumnEmptyState(colonneId),
                      ...dealsInColumn.map((d) => _buildDealCard(d, colonneId)),
                      if (colonneId == 'prospects')
                        TextButton.icon(
                          onPressed: _addDeal,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Ajouter'),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnEmptyState(String colonneId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 32, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            colonneId == 'prospects' ? 'Aucun prospect' : 'Aucun deal ici',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
          ),
          if (colonneId == 'prospects') ...[
            const SizedBox(height: 4),
            Text('Glissez une carte ou ajoutez-en une', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFCBD5E1))),
          ],
        ],
      ),
    );
  }

  Widget _buildDealCard(Map<String, dynamic> deal, String colonneId) {
    final dealId = deal['id']?.toString() ?? '';
    final contact = dealContactName(deal);
    final isDragging = _draggingDealId == dealId;

    final card = Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: isDragging ? 4 : 1,
      child: InkWell(
        onTap: () => _openDealDetail(deal),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dealCompanyName(deal),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: NexaColors.darkNavy),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, size: 16, color: Color(0xFF94A3B8)),
                    padding: EdgeInsets.zero,
                    onSelected: (s) => _updateDealStatus(dealId, s),
                    itemBuilder: (ctx) => _pipeline.colonnes
                        .where((c) => c != deal['statut'])
                        .map((c) => PopupMenuItem(value: c, child: Text('→ ${_pipeline.titresColonnes[c]}', style: const TextStyle(fontSize: 12))))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${_formatMad(dealAmount(deal))} MAD',
                style: const TextStyle(color: NexaColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              if (contact.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: Text(contact[0].toUpperCase(), style: const TextStyle(fontSize: 9, color: NexaColors.darkNavy)),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(contact, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
              const SizedBox(height: 6),
              Text(
                'Modif. ${dealLastInteractionLabel(deal)}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );

    return LongPressDraggable<String>(
      data: dealId,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Opacity(opacity: 0.85, child: SizedBox(width: 248, child: card)),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      onDragStarted: () => setState(() => _draggingDealId = dealId),
      onDragEnd: (_) => setState(() => _draggingDealId = null),
      onDraggableCanceled: (_, _) => setState(() => _draggingDealId = null),
      child: Padding(padding: const EdgeInsets.only(bottom: 8), child: card),
    );
  }

  Widget _buildReportingView(List<Map<String, dynamic>> deals) {
    final totalPipeline = deals.fold(0.0, (s, d) => s + dealAmount(d));
    final totalGagne = deals.where((d) => d['statut'] == 'gagne').fold(0.0, (s, d) => s + dealAmount(d));
    final totalEnCours = deals.where((d) => d['statut'] != 'gagne').fold(0.0, (s, d) => s + dealAmount(d));

    return Column(
      children: [
        Row(
          children: [
            _buildReportStatCard('CA gagné', '${_formatMad(totalGagne)} MAD', Icons.emoji_events_outlined, NexaColors.primaryGreen),
            const SizedBox(width: 16),
            _buildReportStatCard('En cours', '${_formatMad(totalEnCours)} MAD', Icons.hourglass_empty, Colors.orange),
            const SizedBox(width: 16),
            _buildReportStatCard('Pipeline total', '${_formatMad(totalPipeline)} MAD', Icons.show_chart, Colors.blue),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Répartition par étape', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: _pipeline.colonnes.map((col) {
                      final amount = deals.where((d) => d['statut'] == col).fold(0.0, (s, d) => s + dealAmount(d));
                      final pct = totalPipeline > 0 ? amount / totalPipeline : 0.0;
                      final colColor = _pipeline.couleursColonnes[col]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_pipeline.titresColonnes[col]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('${_formatMad(amount)} MAD', style: TextStyle(fontWeight: FontWeight.bold, color: colColor)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: pct,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation(colColor),
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 8,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
