import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class TrainerDashboardPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const TrainerDashboardPage({super.key, this.userData});

  @override
  State<TrainerDashboardPage> createState() => _TrainerDashboardPageState();
}

class _TrainerDashboardPageState extends State<TrainerDashboardPage> {
  Map<String, dynamic>? _stats;
  List<dynamic> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrainerData();
  }

  Future<void> _loadTrainerData() async {
    setState(() => _isLoading = true);
    try {
      final statsRes = await ApiService.get(ApiConfig.uri('/api/trainer/stats'));
      final studentsRes = await ApiService.get(ApiConfig.uri('/api/trainer/students'));
      
      if (statsRes.statusCode == 200) {
        setState(() {
          _stats = json.decode(statsRes.body);
          _students = json.decode(studentsRes.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load trainer data error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_stats == null) return const Center(child: Text('Erreur de chargement ou accès non autorisé.'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildKpiSection(),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildCourseManagement()),
              const SizedBox(width: 32),
              Expanded(flex: 1, child: _buildRecentStudents()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dashboard Formateur', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          const Text('Analysez la performance de vos formations et gérez vos étudiants.', style: TextStyle(color: Color(0xFF64748B))),
        ]),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Créer un nouveau cours'),
          style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
        ),
      ],
    );
  }

  Widget _buildKpiSection() {
    return Row(
      children: [
        _buildKpiCard('Revenus Totaux', '${_stats!['totalEarnings']} MAD', Icons.payments_outlined, NexaColors.primaryGreen),
        const SizedBox(width: 24),
        _buildKpiCard('Étudiants Inscrits', '${_stats!['totalStudents']}', Icons.group_outlined, Colors.blue),
        const SizedBox(width: 24),
        _buildKpiCard('Cours Actifs', '${_stats!['totalCourses']}', Icons.school_outlined, Colors.orange),
        const SizedBox(width: 24),
        _buildKpiCard('Taux de Complétion', '${_stats!['avgCompletion']}%', Icons.trending_up, Colors.purple),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseManagement() {
    final List courses = _stats!['courses'] ?? [];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gestion des Cours', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          Table(
            columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
            children: [
              const TableRow(children: [
                Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Cours', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Étudiants', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Revenus', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
              ]),
              ...courses.map((c) => TableRow(
                children: [
                  Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(c['titre'], style: const TextStyle(fontWeight: FontWeight.w600))),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('${c['students']}')),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('${c['revenue']} MAD', style: const TextStyle(color: NexaColors.primaryGreen, fontWeight: FontWeight.bold))),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 20))),
                ]
              )).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentStudents() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Inscriptions Récentes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          ..._students.take(5).map((s) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(backgroundColor: Color(0xFFF1F5F9), child: Icon(Icons.person, size: 18, color: Colors.grey)),
            title: Text(s['utilisateur']['nom_complet'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(s['cours']['titre'], style: const TextStyle(fontSize: 11)),
          )).toList(),
        ],
      ),
    );
  }
}
