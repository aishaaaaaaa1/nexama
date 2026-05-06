import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../shared/chat_page.dart';

class MesInvestissementsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MesInvestissementsPage({super.key, this.userData});

  @override
  State<MesInvestissementsPage> createState() => _MesInvestissementsPageState();
}

class _MesInvestissementsPageState extends State<MesInvestissementsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _investissements = [];
  List<dynamic> _pipeline = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    await Future.wait([
      _fetchInvestissements(),
      _fetchPipeline(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchInvestissements() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/invest/mes-investissements/${widget.userData?['id']}'));
      if (response.statusCode == 200) {
        _investissements = json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching investments: $e');
    }
  }

  Future<void> _fetchPipeline() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/matching/investisseur/pipeline'));
      if (response.statusCode == 200) {
        _pipeline = json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching pipeline: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Investissements & Matchs', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Gérez vos participations et suivez vos projets favoris.', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          
          const TabBar(
            labelColor: NexaColors.primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: NexaColors.primaryGreen,
            tabs: [
              Tab(text: 'Mon Portefeuille'),
              Tab(text: 'Pipeline (Intéressé)'),
            ],
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: TabBarView(
              children: [
                _buildPortefeuilleTab(),
                _buildPipelineTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortefeuilleTab() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(flex: 3, child: Text('Projet', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
                Expanded(flex: 2, child: Text('Montant', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
                Expanded(flex: 2, child: Text('Statut', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
              ],
            ),
            const SizedBox(height: 16),
            if (_investissements.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: Text("Aucun investissement confirmé.")))
            else
              ..._investissements.map((inv) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(inv['projet_nom'] ?? 'Projet', style: const TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('${inv['montant']} MAD')),
                    Expanded(flex: 2, child: _buildStatusBadge(inv['statut'] ?? 'Actif')),
                  ],
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineTab() {
    if (_pipeline.isEmpty) {
      return const Center(child: Text("Vous n'avez pas encore de projets dans votre pipeline.\nSwipez à droite sur les projets qui vous plaisent !", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: _pipeline.length,
      itemBuilder: (context, index) {
        final item = _pipeline[index];
        final projet = item['projet'];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(projet['nom'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                  _buildStatusBadge(item['statut'], isPipeline: true),
                ],
              ),
              const SizedBox(height: 8),
              Text(projet['description'], style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Budget: ${projet['budget_recherche']} MAD', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            otherUser: {
                              'id': projet['entrepreneur_id'],
                              'nom_complet': projet['entrepreneur']?['nom_complet'] ?? 'Entrepreneur',
                              'role': 'Entrepreneur',
                            },
                            userData: widget.userData,
                          ),
                        ),
                      );
                    },
                    child: const Text('Contacter'),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status, {bool isPipeline = false}) {
    Color color = NexaColors.primaryGreen;
    if (status == 'INTÉRESSÉ') color = Colors.orange;
    if (status == 'EN_DISCUSSION') color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status.replaceAll('_', ' '), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
