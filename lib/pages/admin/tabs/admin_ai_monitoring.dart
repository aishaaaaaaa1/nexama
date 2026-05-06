import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../../config/api_config.dart';
import 'dart:convert';

class AdminAiMonitoring extends StatefulWidget {
  const AdminAiMonitoring({super.key});

  @override
  State<AdminAiMonitoring> createState() => _AdminAiMonitoringState();
}

class _AdminAiMonitoringState extends State<AdminAiMonitoring> {
  bool _isLoading = true;
  List<dynamic> _providers = [];
  List<dynamic> _recentQueries = [];

  @override
  void initState() {
    super.initState();
    _fetchAiStats();
  }

  Future<void> _fetchAiStats() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/admin/ai-monitoring'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            final data = json.decode(response.body);
            _providers = data['providers'] ?? [];
            _recentQueries = data['recent_queries'] ?? [];
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Monitoring des Services IA', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            Row(
              children: [
                const Text('Mode Auto-failover', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 8),
                Switch(value: true, onChanged: (v) {}, activeColor: NexaColors.primaryGreen),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisExtent: 220,
              ),
              itemCount: _providers.length,
              itemBuilder: (context, i) => _buildProviderCard(_providers[i]),
            ),
        const SizedBox(height: 24),
        _buildRecentQueries(),
      ],
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    String statut = (provider['statut'] ?? 'Inconnu').toString();
    bool isDown = statut == 'Down';
    Color statusColor = isDown ? Colors.red : (statut == 'Lent' ? Colors.orange : Colors.green);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(provider['nom'] ?? 'Inconnu', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(statut, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Latence', '${provider['latence'] ?? 0} ms'),
          _buildInfoRow('Requêtes (24h)', (provider['requetes_24h'] ?? 0).toString()),
          _buildInfoRow('Coût Est. (Mois)', '${provider['cout_estime'] ?? 0} \$'),
          const Spacer(),
          LinearProgressIndicator(
            value: (provider['latence'] ?? 0) > 1000 ? 0.9 : ((provider['latence'] ?? 0) / 1000),
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation(statusColor),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecentQueries() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Interactions IA Récentes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _recentQueries.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Aucune interaction récente', style: TextStyle(color: Colors.grey))))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('DATE')),
                      DataColumn(label: Text('REQUÊTE')),
                      DataColumn(label: Text('SOURCE')),
                      DataColumn(label: Text('LATENCE')),
                    ],
                    rows: _recentQueries.map((q) => DataRow(cells: [
                      DataCell(Text(q['timestamp']?.toString().split('T')[1].split('.')[0] ?? '-', style: const TextStyle(fontSize: 12))),
                      DataCell(Text(q['query'] ?? '-', style: const TextStyle(fontSize: 12))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: (q['source'] == 'Gemini 2.0' ? Colors.blue : Colors.green).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(q['source'] ?? '-', style: TextStyle(color: q['source'] == 'Gemini 2.0' ? Colors.blue : Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      )),
                      DataCell(Text('${q['latency'] ?? 0} ms', style: const TextStyle(fontSize: 12))),
                    ])).toList(),
                  ),
                ),
        ],
      ),
    );
  }
}
