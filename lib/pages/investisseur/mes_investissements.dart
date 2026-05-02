import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class MesInvestissementsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MesInvestissementsPage({super.key, this.userData});

  @override
  State<MesInvestissementsPage> createState() => _MesInvestissementsPageState();
}

class _MesInvestissementsPageState extends State<MesInvestissementsPage> {
  bool _isLoading = true;
  List<dynamic> _investissements = [];

  @override
  void initState() {
    super.initState();
    _fetchInvestissements();
  }

  Future<void> _fetchInvestissements() async {
    try {
      final userId = widget.userData?['id'] ?? 'inv_123';
      final response = await ApiService.get(ApiConfig.uri('/api/invest/mes-investissements/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          _investissements = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mes investissements', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Suivez vos opérations et le rendement de votre portefeuille.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Expanded(flex: 3, child: Text('Projet', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
                  Expanded(flex: 2, child: Text('Montant', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
                  Expanded(flex: 2, child: Text('Statut', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
                  Expanded(flex: 2, child: Text('Rendement estimé', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
                ],
              ),
              const SizedBox(height: 16),
              if (_investissements.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: Text("Aucun investissement trouvé.")))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _investissements.length,
                  separatorBuilder: (c, i) => const Divider(),
                  itemBuilder: (context, index) {
                    final inv = _investissements[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(inv['projet_nom'] ?? 'Nom du projet', style: const TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('${inv['montant']} MAD')),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(4)),
                                child: Text(inv['statut'] ?? 'Actif', style: const TextStyle(color: NexaColors.primaryGreen, fontSize: 11)),
                              ),
                            ),
                          ),
                          Expanded(flex: 2, child: Text(inv['rendement'] ?? 'N/A', style: const TextStyle(color: NexaColors.primaryGreen, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    );
                  },
                )
            ],
          ),
        )
      ],
    );
  }
}
