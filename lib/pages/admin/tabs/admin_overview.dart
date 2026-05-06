import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../../config/api_config.dart';
import 'dart:convert';

class AdminOverview extends StatefulWidget {
  const AdminOverview({super.key});

  @override
  State<AdminOverview> createState() => _AdminOverviewState();
}

class _AdminOverviewState extends State<AdminOverview> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  List<dynamic> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final statsRes = await ApiService.get(ApiConfig.uri('/api/admin/stats'));
      final logsRes = await ApiService.get(ApiConfig.uri('/api/admin/audit-log'));
      
      if (mounted) {
        setState(() {
          if (statsRes.statusCode == 200) _stats = json.decode(statsRes.body);
          if (logsRes.statusCode == 200) _logs = json.decode(logsRes.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlatformHealthBanner(),
          const SizedBox(height: 24),
          _buildKpiGrid(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildGrowthChart()),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildUserDistribution()),
            ],
          ),
          const SizedBox(height: 24),
          _buildRecentActivityTable(),
        ],
      ),
    );
  }

  Widget _buildPlatformHealthBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Système Opérationnel : Tous les services sont en ligne. Latence moyenne : 42ms.',
              style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('Voir Status', style: TextStyle(color: Color(0xFF059669)))),
        ],
      ),
    );
  }

  Widget _buildKpiGrid() {
    final kpis = [
      {'label': 'Utilisateurs Totaux', 'value': _stats?['utilisateurs_totaux']?.toString() ?? '12,450', 'change': '+12%', 'icon': Icons.people, 'color': Colors.blue},
      {'label': 'Abonnés Premium', 'value': '1,280', 'change': '+8%', 'icon': Icons.star, 'color': Colors.orange},
      {'label': 'Volume Escrow', 'value': '450,000 MAD', 'change': '+15%', 'icon': Icons.account_balance_wallet, 'color': NexaColors.primaryGreen},
      {'label': 'Alertes Modération', 'value': '12', 'change': '-5', 'icon': Icons.gavel, 'color': Colors.redAccent},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisExtent: 130,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, i) => _buildKpiCard(kpis[i]),
    );
  }

  Widget _buildKpiCard(Map<String, dynamic> kpi) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: kpi['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(kpi['icon'], color: kpi['color'], size: 20),
              ),
              Text(kpi['change'], style: TextStyle(color: kpi['change'].startsWith('+') ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(kpi['value'], style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
              Text(kpi['label'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGrowthChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Croissance de la Plateforme (Utilisateurs)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) => Text('${v.toInt()}k', style: const TextStyle(color: Colors.grey, fontSize: 10)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                    const labs = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin'];
                    if (v.toInt() >= 0 && v.toInt() < labs.length) return Text(labs[v.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10));
                    return const Text('');
                  })),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 2), FlSpot(1, 3.5), FlSpot(2, 3), FlSpot(3, 5), FlSpot(4, 8), FlSpot(5, 12)],
                    isCurved: true,
                    color: NexaColors.primaryGreen,
                    barWidth: 4,
                    belowBarData: BarAreaData(show: true, color: NexaColors.primaryGreen.withOpacity(0.1)),
                    dotData: const FlDotData(show: true),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDistribution() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Répartition par Rôle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(color: Colors.blue, value: 45, title: '45%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: NexaColors.primaryGreen, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.orange, value: 15, title: '15%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.purple, value: 10, title: '10%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLegendRow(Colors.blue, 'Entrepreneurs'),
          _buildLegendRow(NexaColors.primaryGreen, 'Investisseurs'),
          _buildLegendRow(Colors.orange, 'Prestataires'),
          _buildLegendRow(Colors.purple, 'Formateurs'),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecentActivityTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Derniers Journaux d\'Audit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: () {}, child: const Text('Tout voir')),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(4),
              3: FlexColumnWidth(2),
            },
            children: [
              _buildTableRow(['HEURE', 'UTILISATEUR', 'ACTION', 'STATUT'], isHeader: true),
              ..._logs.take(5).map((log) => _buildTableRow([
                log['date']?.toString().split('T')[1].substring(0, 5) ?? '--:--',
                log['user']?.toString().split('@')[0] ?? '-',
                log['action'] ?? '-',
                log['status'] ?? 'OK',
              ])),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1)))),
      children: cells.map((cell) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          cell,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: isHeader ? Colors.grey : (cell == 'ALERTE' ? Colors.red : Colors.black87),
            fontSize: 12,
          ),
        ),
      )).toList(),
    );
  }
}
