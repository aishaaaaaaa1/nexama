import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../widgets/crm/deal_detail_modal.dart';
import '../../widgets/crm/pipeline_config.dart';
import 'reporting_ventes_page.dart';

class CRMPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const CRMPage({super.key, this.userData});

  @override
  State<CRMPage> createState() => _CRMPageState();
}

class _CRMPageState extends State<CRMPage> with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  bool _isLoading = true;
  List<dynamic> _deals = [];

  static final _pipeline = PipelineConfig.entrepreneur;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _fetchDeals(); // Fetch existing from API, then map them to the new columns
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDeals() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/entrepreneur/crm/$userId'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            final rawDeals = json.decode(response.body) as List<dynamic>;
            // Mapping de l'ancien statut vers le nouveau pipeline si besoin
            _deals = rawDeals.map((d) {
              if (d['statut'] == 'qualifies' || d['statut'] == 'nego') d['statut'] = 'devis';
              if (d['statut'] == 'gagne') d['statut'] = 'encaissement';
              if (!['prospects', 'devis', 'commande', 'facture', 'encaissement'].contains(d['statut'])) {
                d['statut'] = 'prospects';
              }
              // Ajout de mock data pour la fiche unifiée
              d['historique'] = ['Contact initial le 10/05', 'Appel qualif le 12/05'];
              d['documents'] = [];
              return d;
            }).toList();
            
            // On ajoute un mock pour la demo
            _deals.add({
              'id': 'd_new',
              'nom_entreprise': 'Tech Corp',
              'contact_nom': 'Amine',
              'montant_estime': 25000,
              'statut': 'commande',
              'date_creation': '2024-05-01',
              'historique': ['Contact', 'Devis envoyé'],
              'documents': [{'titre': 'Devis V1.pdf', 'signe': false}]
            });
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CRM & Pipeline Commercial', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const Text('Gérez le cycle de vie client complet : Prospect jusqu\'à l\'Encaissement.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
            Row(
              children: [
                _buildSearchBar(),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddContactDialog(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Ajouter Contact'),
                  style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => ReportingVentesPage()));
                  },
                  icon: const Icon(Icons.analytics_outlined, color: NexaColors.darkNavy),
                  tooltip: 'Reporting Avancé',
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        
        // TabBar Main
        TabBar(
          controller: _mainTabController,
          labelColor: NexaColors.primaryGreen,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: NexaColors.primaryGreen,
          tabs: const [Tab(text: 'Pipeline Kanban'), Tab(text: 'Reporting Synthèse')],
        ),
        const SizedBox(height: 24),

        // Content
        Expanded(
          child: TabBarView(
            controller: _mainTabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildPipelineView(),
              _buildReportingView(),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddContactDialog() {
    final nomController = TextEditingController();
    final entrepriseController = TextEditingController();
    final emailController = TextEditingController();
    String selectedStatus = 'prospects';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau Contact / Opportunité'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomController, decoration: const InputDecoration(labelText: 'Nom du contact')),
              TextField(controller: entrepriseController, decoration: const InputDecoration(labelText: 'Entreprise')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: 'Étape du Pipeline'),
                items: _pipeline.colonnes.map((c) => DropdownMenuItem(value: c, child: Text(_pipeline.titresColonnes[c]!))).toList(),
                onChanged: (v) => selectedStatus = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _deals.insert(0, {
                  'id': 'd_${DateTime.now().millisecondsSinceEpoch}',
                  'nom_entreprise': entrepriseController.text,
                  'contact_nom': nomController.text,
                  'montant_estime': 0.0,
                  'statut': selectedStatus,
                  'date_creation': DateTime.now().toString().split(' ')[0],
                  'historique': ['Contact créé le ${DateTime.now().toString().split(' ')[0]}'],
                  'documents': []
                });
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact ajouté avec succès'), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 250, height: 40,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 8),
        ),
      ),
    );
  }

  // ==========================================
  // VUE 1 : PIPELINE KANBAN
  // ==========================================
  Widget _buildPipelineView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _pipeline.colonnes.map((col) => _buildKanbanColumn(col)).toList(),
    );
  }

  Widget _buildKanbanColumn(String code) {
    final dealsInCol = _deals.where((d) => d['statut'] == code).toList();
    final totalMontant = dealsInCol.fold(0.0, (sum, item) => sum + (item['montant_estime'] ?? 0.0));

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9).withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _pipeline.couleursColonnes[code]!.withOpacity(0.3), width: 2))),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: _pipeline.couleursColonnes[code], shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(_pipeline.titresColonnes[code]!, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    child: Text('${dealsInCol.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Text('Total : ', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  Text('${totalMontant.toInt()} MAD', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: dealsInCol.length,
                itemBuilder: (context, index) => _buildDealCard(dealsInCol[index]),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDealCard(Map<String, dynamic> deal) {
    return InkWell(
      onTap: () => _showUnifiedDealDetail(deal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(deal['nom_entreprise'] ?? 'Inconnu', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: NexaColors.darkNavy))),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, size: 16, color: Color(0xFF94A3B8)),
                  padding: EdgeInsets.zero,
                  onSelected: (val) {
                    setState(() {
                      deal['statut'] = val;
                      deal['historique'] ??= [];
                      deal['historique'].insert(0, 'Déplacé vers ${_pipeline.titresColonnes[val]} le ${DateTime.now().toString().split(' ')[0]}');
                    });
                  },
                  itemBuilder: (ctx) => _pipeline.colonnes.where((c) => c != deal['statut']).map((c) => PopupMenuItem(value: c, child: Text('→ ${_pipeline.titresColonnes[c]}'))).toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${(deal['montant_estime'] ?? 0).toInt()} MAD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NexaColors.primaryGreen)),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(radius: 10, backgroundColor: const Color(0xFFE2E8F0), child: Text((deal['contact_nom'] ?? '?')[0], style: const TextStyle(fontSize: 9, color: NexaColors.darkNavy))),
                const SizedBox(width: 8),
                Text(deal['contact_nom'] ?? 'N/A', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FICHE CLIENT UNIFIÉE (MODALE)
  // ==========================================
  void _showUnifiedDealDetail(Map<String, dynamic> deal) {
    DealDetailModal.show(
      context,
      deal: deal,
      config: _pipeline,
      onStatusChanged: (newStatus) {
        setState(() {
          deal['statut'] = newStatus;
          deal['historique'] ??= [];
          deal['historique'].insert(0, 'Statut mis à jour : ${_pipeline.titresColonnes[newStatus]}');
        });
      },
    );
  }

  // ==========================================
  // VUE 2 : REPORTING VENTES
  // ==========================================
  Widget _buildReportingView() {
    double totalEncaisse = _deals.where((d) => d['statut'] == 'encaissement').fold(0.0, (s, d) => s + (d['montant_estime'] ?? 0));
    double totalFacture = _deals.where((d) => d['statut'] == 'facture').fold(0.0, (s, d) => s + (d['montant_estime'] ?? 0));
    double totalPipeline = _deals.fold(0.0, (s, d) => s + (d['montant_estime'] ?? 0));

    return Column(
      children: [
        Row(
          children: [
            _buildStatCard('CA Encaissé', '${totalEncaisse.toInt()} MAD', Icons.account_balance_wallet, NexaColors.primaryGreen),
            const SizedBox(width: 16),
            _buildStatCard('En attente de paiement (Facturé)', '${totalFacture.toInt()} MAD', Icons.hourglass_empty, Colors.redAccent),
            const SizedBox(width: 16),
            _buildStatCard('Valeur totale Pipeline', '${totalPipeline.toInt()} MAD', Icons.show_chart, Colors.blue),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Répartition par statut', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: _pipeline.colonnes.map((col) {
                      final amount = _deals.where((d) => d['statut'] == col).fold(0.0, (s, d) => s + (d['montant_estime'] ?? 0));
                      final percentage = totalPipeline > 0 ? amount / totalPipeline : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_pipeline.titresColonnes[col]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('${amount.toInt()} MAD', style: TextStyle(fontWeight: FontWeight.bold, color: _pipeline.couleursColonnes[col])),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(value: percentage, backgroundColor: const Color(0xFFF1F5F9), valueColor: AlwaysStoppedAnimation(_pipeline.couleursColonnes[col]), borderRadius: BorderRadius.circular(4)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 24, color: NexaColors.darkNavy)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
