import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../../config/api_config.dart';
import 'dart:convert';

class AdminAuditLog extends StatefulWidget {
  const AdminAuditLog({super.key});

  @override
  State<AdminAuditLog> createState() => _AdminAuditLogState();
}

class _AdminAuditLogState extends State<AdminAuditLog> {
  bool _isLoading = true;
  List<dynamic> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/admin/audit-log'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _logs = json.decode(response.body);
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
        Text('Journal d\'audit système', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Filtrer par action ou utilisateur...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(onPressed: _fetchLogs, icon: const Icon(Icons.refresh), label: const Text('Actualiser')),
                ],
              ),
              const SizedBox(height: 24),
              _isLoading 
                ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                : _logs.isEmpty 
                  ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Aucun log trouvé.')))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('DATE')),
                          DataColumn(label: Text('UTILISATEUR')),
                          DataColumn(label: Text('ACTION')),
                          DataColumn(label: Text('DÉTAILS')),
                          DataColumn(label: Text('IP')),
                        ],
                        rows: _logs.map((log) => DataRow(cells: [
                          DataCell(Text(log['date']?.toString().split('T')[0] ?? '-', style: const TextStyle(fontSize: 12))),
                          DataCell(Text(log['user'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataCell(_buildActionBadge(log['action'] ?? '-')),
                          DataCell(Text(log['detail'] ?? '-', style: const TextStyle(fontSize: 12))),
                          DataCell(Text(log['ip'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 11))),
                        ])).toList(),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionBadge(String action) {
    Color color = Colors.blueGrey;
    if (action.contains('VALIDATION')) color = Colors.green;
    if (action.contains('CONNEXION')) color = Colors.blue;
    if (action.contains('ALERTE')) color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(action, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
