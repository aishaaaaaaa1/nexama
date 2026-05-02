import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class RHPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const RHPage({super.key, this.userData});

  @override
  State<RHPage> createState() => _RHPageState();
}

class _RHPageState extends State<RHPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _employes = [];

  final List<Map<String, dynamic>> _conges = [
    {'employe': 'Anas Benali', 'type': 'Congé annuel', 'debut': '20/05/2024', 'fin': '24/05/2024', 'jours': 5, 'statut': 'approuve'},
    {'employe': 'Khadija Idrissi', 'type': 'Congé maladie', 'debut': '15/05/2024', 'fin': '16/05/2024', 'jours': 2, 'statut': 'en_attente'},
  ];

  final List<Map<String, dynamic>> _recrutements = [
    {'poste': 'Développeur React', 'candidats': 12, 'entretiens': 3, 'statut': 'En cours'},
    {'poste': 'Commercial B2B', 'candidats': 5, 'entretiens': 1, 'statut': 'Nouveau'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchEmployes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmployes() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/entrepreneur/rh/$userId'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _employes = json.decode(response.body);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to fetch');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Mock data if API fails
          _employes = [
            {'id': 'e1', 'nom': 'Anas Benali', 'poste': 'Directeur Tech', 'salaire_brut': 15000, 'date_entree': '01/01/2024', 'photo': 'A'},
            {'id': 'e2', 'nom': 'Khadija Idrissi', 'poste': 'Responsable Marketing', 'salaire_brut': 12000, 'date_entree': '15/02/2024', 'photo': 'K'},
            {'id': 'e3', 'nom': 'Youssef Alami', 'poste': 'Commercial', 'salaire_brut': 8000, 'date_entree': '10/03/2024', 'photo': 'Y'},
          ];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: NexaColors.primaryGreen,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: NexaColors.primaryGreen,
          tabs: const [
            Tab(text: 'Équipe'),
            Tab(text: 'Congés'),
            Tab(text: 'Paie & CNSS'),
            Tab(text: 'Organigramme'),
            Tab(text: 'Recrutement'),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEquipeTab(),
              _buildCongesTab(),
              _buildPaieTab(),
              _buildOrganigrammeTab(),
              _buildRecrutementTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ressources Humaines', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            const Text('Gérez votre capital humain en conformité avec le code du travail marocain.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Nouvel Employé'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  // --- TABS ---

  Widget _buildEquipeTab() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.5),
      itemCount: _employes.length,
      itemBuilder: (ctx, i) => _buildEmployeCard(_employes[i]),
    );
  }

  Widget _buildEmployeCard(Map<String, dynamic> e) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: NexaColors.primaryGreen, child: Text(e['photo'] ?? '?', style: const TextStyle(color: Colors.white))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(e['nom'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(e['poste'], style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          ])),
          IconButton(onPressed: () => _showEmployeDetail(e), icon: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildCongesTab() {
    return Column(
      children: [
        Row(children: [
          _buildStatMini('Congés pris (Mois)', '8 jours', Colors.blue),
          const SizedBox(width: 16),
          _buildStatMini('Demandes en attente', '2', Colors.orange),
        ]),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: ListView.separated(
              itemCount: _conges.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final c = _conges[i];
                return ListTile(
                  title: Text(c['employe'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${c['type']} : du ${c['debut']} au ${c['fin']}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: c['statut'] == 'approuve' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(c['statut'].toUpperCase(), style: TextStyle(color: c['statut'] == 'approuve' ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaieTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Simulation de Paie (Normes Maroc)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ..._employes.map((e) => _buildPaieRow(e)).toList(),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _paieSummaryLine('Masse Salariale Brute', '35 000 MAD'),
              _paieSummaryLine('Charges Patronales (CNSS/AMO)', '8 400 MAD'),
              const Divider(height: 32),
              _paieSummaryLine('Total à décaisser', '43 400 MAD', isTotal: true),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildPaieRow(Map<String, dynamic> e) {
    double brut = (e['salaire_brut'] ?? 0).toDouble();
    double cnss = brut * 0.0448; // Part ouvrière simplifiée
    double net = brut - cnss; // Simplifié (hors IR)

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Text(e['nom'], style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Net: ${net.toInt()} MAD', style: const TextStyle(fontWeight: FontWeight.bold, color: NexaColors.primaryGreen)),
            Text('Brut: ${brut.toInt()} | CNSS: ${cnss.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ]),
          const SizedBox(width: 16),
          TextButton(onPressed: () {}, child: const Text('Générer Bulletin')),
        ],
      ),
    );
  }

  Widget _paieSummaryLine(String label, String val, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 13)),
        Text(val, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: isTotal ? 20 : 14, color: isTotal ? NexaColors.darkNavy : Colors.black)),
      ],
    );
  }

  Widget _buildOrganigrammeTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _orgNode('Gérant (Vous)', NexaColors.darkNavy, Colors.white),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _orgNode('Tech', Colors.blue, Colors.white),
              const SizedBox(width: 64),
              _orgNode('Sales', Colors.orange, Colors.white),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Vue hiérarchique dynamique', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _orgNode(String title, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: bg.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Text(title, style: TextStyle(color: text, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRecrutementTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Offres d\'emploi actives', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          ElevatedButton(onPressed: () {}, child: const Text('Publier une offre')),
        ]),
        const SizedBox(height: 16),
        ..._recrutements.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(children: [
            const Icon(Icons.work, color: Colors.purple),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r['poste'], style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${r['candidats']} candidats | ${r['entretiens']} entretiens', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ])),
            Text(r['statut'], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
          ]),
        )).toList(),
      ],
    );
  }

  Widget _buildStatMini(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          Text(val, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        ]),
      ),
    );
  }

  void _showEmployeDetail(Map<String, dynamic> e) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 30, backgroundColor: NexaColors.primaryGreen, child: Text(e['photo'], style: const TextStyle(color: Colors.white, fontSize: 24))),
            const SizedBox(width: 24),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e['nom'], style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(e['poste'], style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ]),
          ]),
          const SizedBox(height: 32),
          _detailLine('Salaire Brut', '${e['salaire_brut']} MAD'),
          _detailLine('Date d\'entrée', e['date_entree']),
          _detailLine('Statut Contrat', 'CDI (Confirmé)'),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer'))),
        ]),
      ),
    );
  }

  Widget _detailLine(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
