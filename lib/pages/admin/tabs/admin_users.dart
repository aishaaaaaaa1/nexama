import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../../config/api_config.dart';
import 'dart:convert';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  bool _isLoading = true;
  List<dynamic> _users = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/admin/users'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _users = json.decode(response.body);
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
    final filtered = _users.where((u) {
      final nom = (u['nom'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return nom.contains(query) || email.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Gestion des Utilisateurs', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Nouvel Administrateur'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            ),
          ],
        ),
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
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Rechercher par nom ou email...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildFilterBtn('Tous'),
                  const SizedBox(width: 8),
                  _buildFilterBtn('Entrepreneur'),
                  const SizedBox(width: 8),
                  _buildFilterBtn('Investisseur'),
                ],
              ),
              const SizedBox(height: 24),
              _isLoading 
                ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 40,
                      columns: const [
                        DataColumn(label: Text('UTILISATEUR')),
                        DataColumn(label: Text('RÔLE')),
                        DataColumn(label: Text('STATUT')),
                        DataColumn(label: Text('INSCRIPTION')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: filtered.map((u) => DataRow(cells: [
                        DataCell(Row(
                          children: [
                            CircleAvatar(radius: 14, backgroundColor: Colors.blue.withOpacity(0.1), child: Text((u['nom'] ?? '?')[0].toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u['nom'] ?? 'Sans nom', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(u['email'] ?? 'Pas d\'email', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ],
                        )),
                        DataCell(_buildRoleBadge(u['role'])),
                        DataCell(_buildStatusBadge(u['statut'] ?? 'Actif')),
                        DataCell(Text(u['date_inscription'] ?? '12 Mai 2024', style: const TextStyle(fontSize: 12))),
                        DataCell(Row(
                          children: [
                            IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue)),
                            IconButton(onPressed: () {}, icon: const Icon(Icons.block_outlined, size: 18, color: Colors.redAccent)),
                          ],
                        )),
                      ])).toList(),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBtn(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color = Colors.blue;
    if (role == 'investisseur') color = NexaColors.primaryGreen;
    if (role == 'prestataire') color = Colors.orange;
    if (role == 'formateur') color = Colors.purple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(role.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isActive = status == 'Actif';
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: isActive ? Colors.green : Colors.grey, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(status, style: TextStyle(color: isActive ? Colors.green : Colors.grey, fontSize: 12)),
      ],
    );
  }
}
