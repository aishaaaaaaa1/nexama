import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';

class ReportingVentesPage extends StatefulWidget {
  const ReportingVentesPage({super.key});

  @override
  State<ReportingVentesPage> createState() => _ReportingVentesPageState();
}

class _ReportingVentesPageState extends State<ReportingVentesPage> {
  String _selectedPeriod = '6 derniers mois';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: Text('Reporting Analytique des Ventes', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: NexaColors.darkNavy),
        actions: [
          _buildPeriodSelector(),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopStats(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildRevenueChart()),
                const SizedBox(width: 24),
                Expanded(child: _buildSalesByCategory()),
              ],
            ),
            const SizedBox(height: 24),
            _buildPerformanceTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          items: ['3 derniers mois', '6 derniers mois', 'Année en cours'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: (v) => setState(() => _selectedPeriod = v!),
        ),
      ),
    );
  }

  Widget _buildTopStats() {
    return Row(
      children: [
        _statCard('Chiffre d\'Affaires Total', '452 800 MAD', '+15%', Colors.green),
        const SizedBox(width: 16),
        _statCard('Nb de Ventes', '124', '+8%', Colors.blue),
        const SizedBox(width: 16),
        _statCard('Panier Moyen', '3 650 MAD', '+2%', Colors.purple),
        const SizedBox(width: 16),
        _statCard('Taux de Conversion', '4.2%', '-1%', Colors.orange),
      ],
    );
  }

  Widget _statCard(String label, String val, String trend, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(val, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(trend, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Évolution du CA (MAD)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (val) => FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1)),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
                    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                    if (val.toInt() >= 0 && val.toInt() < months.length) return Text(months[val.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey));
                    return const Text('');
                  })),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: NexaColors.primaryGreen,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: NexaColors.primaryGreen.withOpacity(0.1)),
                    spots: const [FlSpot(0, 30), FlSpot(1, 45), FlSpot(2, 35), FlSpot(3, 55), FlSpot(4, 48), FlSpot(5, 70)],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesByCategory() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ventes par catégorie', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(color: Colors.blue, value: 40, title: '40%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  PieChartSectionData(color: Colors.green, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  PieChartSectionData(color: Colors.purple, value: 20, title: '20%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  PieChartSectionData(color: Colors.orange, value: 10, title: '10%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _legendItem('Produits Tech', Colors.blue),
          _legendItem('Services Conseil', Colors.green),
          _legendItem('Maintenance', Colors.purple),
          _legendItem('Autres', Colors.orange),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildPerformanceTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Clients par CA', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          Table(
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
            children: [
              TableRow(
                children: ['Client', 'Ventes', 'Total CA', 'Progression'].map((h) => Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 12)))).toList(),
              ),
              _tableRow('Tech Solutions Maroc', '12', '145 000 MAD', '+24%'),
              _tableRow('Atlas Consulting', '8', '82 500 MAD', '+12%'),
              _tableRow('Maghreb Food', '15', '64 200 MAD', '-5%'),
              _tableRow('Global Edu', '5', '42 000 MAD', '+40%'),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _tableRow(String client, String sales, String total, String trend) {
    bool isPos = trend.startsWith('+');
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(client, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(sales)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(total, style: const TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(trend, style: TextStyle(color: isPos ? Colors.green : Colors.red, fontWeight: FontWeight.bold))),
      ],
    );
  }
}
