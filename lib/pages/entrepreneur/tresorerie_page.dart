import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class TresoreriePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const TresoreriePage({super.key, this.userData});

  @override
  State<TresoreriePage> createState() => _TresoreriePageState();
}

class _TresoreriePageState extends State<TresoreriePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/entrepreneur/tresorerie/$userId'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _data = json.decode(response.body);
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gestion de la Trésorerie', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const SizedBox(height: 4),
                Text('Suivi des liquidités et prévisions', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportation Excel en cours...'), backgroundColor: Colors.blue)),
                  icon: const Icon(Icons.table_chart, size: 18, color: Colors.green),
                  label: const Text('Export Excel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportation PDF en cours...'), backgroundColor: Colors.blue)),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('Rapport PDF'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildBalanceCard('Solde Actuel', _data?['solde_actuel'] ?? '0 MAD', Icons.account_balance_wallet, NexaColors.primaryGreen)),
            const SizedBox(width: 16),
            Expanded(child: _buildBalanceCard('Entrées Prévues', _data?['entrees_prevues'] ?? '0 MAD', Icons.trending_up, Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _buildBalanceCard('Sorties Prévues', _data?['sorties_prevues'] ?? '0 MAD', Icons.trending_down, Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Évolution et Prévisions du Flux de Trésorerie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(width: 12, height: 12, decoration: const BoxDecoration(color: NexaColors.primaryGreen, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('Réel', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 16),
                  Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('Prévisionnel', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1)),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text('${val.toInt()}k', style: const TextStyle(color: Colors.grey, fontSize: 10)))),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
                        const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil'];
                        if (val.toInt() >= 0 && val.toInt() < months.length) return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(months[val.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10)));
                        return const Text('');
                      })),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Real data
                      LineChartBarData(
                        spots: const [FlSpot(0, 10), FlSpot(1, 15), FlSpot(2, 12), FlSpot(3, 18), FlSpot(4, 25)],
                        isCurved: true, color: NexaColors.primaryGreen, barWidth: 4,
                        belowBarData: BarAreaData(show: true, color: NexaColors.primaryGreen.withOpacity(0.1)),
                        dotData: const FlDotData(show: true),
                      ),
                      // Forecast
                      LineChartBarData(
                        spots: const [FlSpot(4, 25), FlSpot(5, 22), FlSpot(6, 28)],
                        isCurved: true, color: Colors.orange, barWidth: 4, isStrokeCapRound: true,
                        dashArray: [5, 5],
                        belowBarData: BarAreaData(show: true, color: Colors.orange.withOpacity(0.1)),
                        dotData: const FlDotData(show: true),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        ],
      ),
    );
  }
}
