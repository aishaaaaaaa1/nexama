import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class SuiviProjetsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const SuiviProjetsPage({super.key, this.userData});

  @override
  State<SuiviProjetsPage> createState() => _SuiviProjetsPageState();
}

class _SuiviProjetsPageState extends State<SuiviProjetsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedProject = 'Refonte du site web';
  final List<String> _projects = ['Refonte du site web', 'Campagne Marketing', 'Recrutement CTO'];

  // Données Kanban mockées (élargies avec logs)
  final Map<String, List<Map<String, dynamic>>> _kanbanData = {
    'a_faire': [
      {'id': '1', 'titre': 'Maquettes pages intérieures', 'assignee': 'Khadija', 'priorite': 'haute', 'debut': '10/05', 'echeance': '18/05', 'couleur': Colors.blue, 'commentaires': 2, 'logs': ['Créée le 10/05 par Anas']},
      {'id': '2', 'titre': 'Rédaction contenu SEO', 'assignee': 'Youssef', 'priorite': 'moyenne', 'debut': '11/05', 'echeance': '20/05', 'couleur': Colors.green, 'commentaires': 0, 'logs': ['Créée le 11/05 par Youssef']},
    ],
    'en_cours': [
      {'id': '3', 'titre': 'Développement frontend React', 'assignee': 'Anas', 'priorite': 'haute', 'debut': '05/05', 'echeance': '15/05', 'couleur': Colors.orange, 'commentaires': 5, 'logs': ['Créée le 05/05', 'Déplacée vers En Cours le 06/05']},
      {'id': '4', 'titre': 'Intégration API paiement', 'assignee': 'Anas', 'priorite': 'haute', 'debut': '08/05', 'echeance': '16/05', 'couleur': Colors.orange, 'commentaires': 3, 'logs': ['Créée le 08/05']},
    ],
    'en_revue': [
      {'id': '5', 'titre': 'Design page d\'accueil', 'assignee': 'Khadija', 'priorite': 'haute', 'debut': '01/05', 'echeance': '12/05', 'couleur': Colors.blue, 'commentaires': 8, 'logs': ['Déplacée vers En Revue le 10/05']},
    ],
    'termine': [
      {'id': '6', 'titre': 'Cahier des charges', 'assignee': 'Youssef', 'priorite': 'basse', 'debut': '20/04', 'echeance': '01/05', 'couleur': Colors.green, 'commentaires': 4, 'logs': ['Terminée le 01/05']},
      {'id': '7', 'titre': 'Choix hébergement', 'assignee': 'Anas', 'priorite': 'basse', 'debut': '01/05', 'echeance': '03/05', 'couleur': Colors.orange, 'commentaires': 1, 'logs': ['Terminée le 03/05']},
    ],
  };

  final Map<String, String> _columnTitles = {
    'a_faire': 'À FAIRE',
    'en_cours': 'EN COURS',
    'en_revue': 'EN REVUE',
    'termine': 'TERMINÉ',
  };

  final Map<String, Color> _columnColors = {
    'a_faire': const Color(0xFF94A3B8),
    'en_cours': const Color(0xFF3B82F6),
    'en_revue': const Color(0xFFF59E0B),
    'termine': NexaColors.primaryGreen,
  };

  // KPI & Budget data
  final double _budgetTotal = 85000;
  final double _budgetDepense = 52000;
  final List<Map<String, dynamic>> _depensesDetail = [
    {'titre': 'Hébergement annuel AWS', 'montant': 15000, 'date': '02/05/2024'},
    {'titre': 'Licences Figma & Adobe', 'montant': 7000, 'date': '05/05/2024'},
    {'titre': 'Acompte Prestataire SEO', 'montant': 30000, 'date': '10/05/2024'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Suivi de Projet Collaboratif', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
              const SizedBox(height: 4),
              const Text('Gérez les tâches, le budget et l\'équipe.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ]),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: DropdownButton<String>(
                  value: _selectedProject,
                  underline: const SizedBox(),
                  items: _projects.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) => setState(() => _selectedProject = v!),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showInviteMemberDialog(context),
                icon: const Icon(Icons.group_add_outlined, size: 18),
                label: const Text('Inviter'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9), foregroundColor: NexaColors.darkNavy, elevation: 0),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddTaskDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nouvelle tâche'),
                style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
              ),
            ]),
          ],
        ),
        const SizedBox(height: 24),
        
        // TabBar
        TabBar(
          controller: _tabController,
          labelColor: NexaColors.primaryGreen,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: NexaColors.primaryGreen,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Vue Kanban'),
            Tab(text: 'Timeline (Gantt)'),
            Tab(text: 'Budget & KPIs'),
          ],
        ),
        const SizedBox(height: 24),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(), // Pas de swipe pour éviter les conflits avec le kanban
            children: [
              _buildKanbanView(),
              _buildTimelineView(),
              _buildBudgetKpiView(),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: KANBAN
  // ==========================================
  Widget _buildKanbanView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ['a_faire', 'en_cours', 'en_revue', 'termine'].map((col) => _buildKanbanColumn(col)).toList(),
    );
  }

  Widget _buildKanbanColumn(String code) {
    final tasks = _kanbanData[code] ?? [];
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          // Column header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _columnColors[code]!.withOpacity(0.4), width: 3))),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: _columnColors[code], shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(_columnTitles[code]!, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                child: Text('${tasks.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _showAddTaskDialog(context, defaultColumn: code),
                child: Icon(Icons.add, size: 16, color: _columnColors[code]),
              ),
            ]),
          ),
          // Task cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: tasks.length,
              itemBuilder: (context, i) => _buildTaskCard(tasks[i], code),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, String column) {
    final prioriteColor = task['priorite'] == 'haute' ? Colors.red : (task['priorite'] == 'moyenne' ? Colors.orange : Colors.grey);
    return InkWell(
      onTap: () => _showTaskDetail(context, task, column),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: prioriteColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(task['priorite'].toString().toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: prioriteColor)),
            ),
            const Spacer(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, size: 16, color: Color(0xFF94A3B8)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onSelected: (val) {
                if (val == 'supprimer') {
                  setState(() => _kanbanData[column]?.removeWhere((t) => t['id'] == task['id']));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tâche supprimée')));
                } else {
                  setState(() {
                    _kanbanData[column]?.removeWhere((t) => t['id'] == task['id']);
                    task['logs']?.insert(0, 'Déplacée vers ${_columnTitles[val]} le 12/05 par Anas');
                    _kanbanData[val]?.add(task);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Déplacée vers ${_columnTitles[val]}')));
                }
              },
              itemBuilder: (ctx) => [
                if (column != 'a_faire') const PopupMenuItem(value: 'a_faire', child: Text('→ À faire')),
                if (column != 'en_cours') const PopupMenuItem(value: 'en_cours', child: Text('→ En cours')),
                if (column != 'en_revue') const PopupMenuItem(value: 'en_revue', child: Text('→ En revue')),
                if (column != 'termine') const PopupMenuItem(value: 'termine', child: Text('→ Terminé')),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'supprimer', child: Text('Supprimer', style: TextStyle(color: Colors.red))),
              ],
            ),
          ]),
          const SizedBox(height: 8),
          Text(task['titre'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: NexaColors.darkNavy)),
          const SizedBox(height: 10),
          Row(children: [
            CircleAvatar(radius: 10, backgroundColor: task['couleur'] as Color, child: Text(task['assignee'][0], style: const TextStyle(fontSize: 9, color: Colors.white))),
            const SizedBox(width: 6),
            Text(task['assignee'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            const Spacer(),
            const Icon(Icons.access_time, size: 12, color: Color(0xFF94A3B8)),
            const SizedBox(width: 3),
            Text(task['echeance'], style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          ]),
          if ((task['commentaires'] as int) > 0) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.chat_bubble_outline, size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text('${task['commentaires']} commentaires', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            ]),
          ],
        ]),
      ),
    );
  }

  // ==========================================
  // TAB 2: TIMELINE / GANTT SIMPLIFIÉ
  // ==========================================
  Widget _buildTimelineView() {
    List<Map<String, dynamic>> allTasks = [];
    _kanbanData.values.forEach((list) => allTasks.addAll(list));
    // Tri simplifié
    allTasks.sort((a, b) => (a['echeance'] as String).compareTo(b['echeance'] as String));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Timeline du Mois (Mai 2024)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          // En-tête des jours (simplifié : 01 au 31)
          Row(
            children: [
              const SizedBox(width: 150), // Espace pour titre
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) => Text('${(index * 5) + 1} Mai', style: const TextStyle(color: Colors.grey, fontSize: 11))),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: allTasks.length,
              itemBuilder: (ctx, i) {
                final task = allTasks[i];
                // Simulation position Gantt (très basique pour l'UI)
                int startDay = int.parse(task['debut'].toString().split('/')[0]);
                int endDay = int.parse(task['echeance'].toString().split('/')[0]);
                double startFraction = startDay / 31.0;
                double widthFraction = (endDay - startDay).clamp(1, 31) / 31.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      SizedBox(width: 150, child: Text(task['titre'], overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                // Ligne de fond
                                Container(height: 24, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4))),
                                // Barre de tâche
                                Positioned(
                                  left: constraints.maxWidth * startFraction,
                                  width: constraints.maxWidth * widthFraction,
                                  child: Container(
                                    height: 24,
                                    decoration: BoxDecoration(color: task['couleur'], borderRadius: BorderRadius.circular(4)),
                                    child: Center(child: Text('${task['assignee']}', style: const TextStyle(color: Colors.white, fontSize: 10, overflow: TextOverflow.ellipsis))),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: BUDGET & KPI
  // ==========================================
  Widget _buildBudgetKpiView() {
    final totalTasks = _kanbanData.values.fold(0, (s, l) => s + l.length);
    final doneTasks = _kanbanData['termine']?.length ?? 0;
    final progress = totalTasks > 0 ? doneTasks / totalTasks : 0.0;
    final budgetPercent = (_budgetDepense / _budgetTotal);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Column
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildStatCard('Avancement Global', '${(progress * 100).toInt()}%', Icons.pie_chart_outline, NexaColors.primaryGreen, '$doneTasks / $totalTasks tâches', progress: progress),
              const SizedBox(height: 16),
              _buildStatCard('Consommation Budget', '${budgetPercent * 100}%', Icons.account_balance_wallet_outlined, budgetPercent > 0.8 ? Colors.red : Colors.blue, '${_budgetDepense.toInt()} MAD sur ${_budgetTotal.toInt()} MAD', progress: budgetPercent),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Objectifs (OKR)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildOkrItem('Lancement Beta', 0.8),
                  const SizedBox(height: 12),
                  _buildOkrItem('Acquisition B2B', 0.4),
                  const SizedBox(height: 12),
                  _buildOkrItem('Stabilité Serveur', 0.9),
                ]),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Budget Breakdown Column
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Détails des Dépenses du Projet', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    itemCount: _depensesDetail.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, i) {
                      final dep = _depensesDetail[i];
                      return ListTile(
                        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.arrow_downward, color: Colors.red, size: 16)),
                        title: Text(dep['titre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(dep['date']),
                        trailing: Text('- ${dep['montant']} MAD', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, String sub, {double? progress}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 28, color: NexaColors.darkNavy)),
        const SizedBox(height: 8),
        Text(sub, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        if (progress != null) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(color), borderRadius: BorderRadius.circular(10)),
        ]
      ]),
    );
  }

  Widget _buildOkrItem(String title, double val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontSize: 13)),
          Text('${(val * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: val, backgroundColor: const Color(0xFFF1F5F9), valueColor: const AlwaysStoppedAnimation(NexaColors.primaryGreen), borderRadius: BorderRadius.circular(10)),
      ],
    );
  }

  // ==========================================
  // DIALOGS & ACTIONS
  // ==========================================
  void _showTaskDetail(BuildContext context, Map<String, dynamic> task, String column) {
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Task Detail
            Expanded(
              flex: 2,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(task['titre'], style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: NexaColors.darkNavy))),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  _buildDetailBadge('Colonne', _columnTitles[column]!, _columnColors[column]!),
                  const SizedBox(width: 8),
                  _buildDetailBadge('Priorité', task['priorite'], task['priorite'] == 'haute' ? Colors.red : Colors.orange),
                  const SizedBox(width: 8),
                  _buildDetailBadge('Échéance', task['echeance'], const Color(0xFF64748B)),
                ]),
                const SizedBox(height: 24),
                Text('Description', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Détails de la tâche à compléter. Cliquez pour modifier la description.', style: TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.5)),
                ),
                const SizedBox(height: 24),
                Text('Pièces jointes', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Row(children: [
                  _buildAttachment('maquette_v2.fig', Icons.design_services, const Color(0xFF8B5CF6)),
                  const SizedBox(width: 8),
                  _buildAttachment('brief.pdf', Icons.picture_as_pdf, Colors.red),
                ]),
                const SizedBox(height: 24),
                Text('Commentaires (${task['commentaires']})', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Expanded(child: ListView(children: [
                  _buildComment('Anas', 'La maquette est validée, on peut passer au dev.', 'Il y a 2h'),
                  _buildComment('Khadija', 'J\'ai ajouté les retours du client dans le Figma.', 'Il y a 5h'),
                ])),
                Row(children: [
                  Expanded(child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(hintText: 'Ajouter un commentaire...', hintStyle: const TextStyle(fontSize: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  )),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (commentController.text.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commentaire ajouté !')));
                        commentController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.all(14)),
                    child: const Icon(Icons.send, size: 18),
                  ),
                ]),
              ]),
            ),
            const SizedBox(width: 32),
            // Right Column: Sidebar (Logs, Assign, Notifications)
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Assigné à', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(children: [
                    CircleAvatar(radius: 14, backgroundColor: task['couleur'] as Color, child: Text(task['assignee'][0], style: const TextStyle(fontSize: 11, color: Colors.white))),
                    const SizedBox(width: 8),
                    Text(task['assignee'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 24),
                  
                  // Notifications Intelligentes
                  Text('Notifications Intelligentes', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final res = await ApiService.post(
                          ApiConfig.uri('/api/entrepreneur/projet/notifications/deadline'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode({'tache_id': task['id'], 'message': 'Attention, deadline imminente pour ${task['titre']}'}),
                        );
                        if (res.statusCode == 200 && mounted) {
                          final data = json.decode(res.body);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['alerte']), backgroundColor: Colors.orange));
                        }
                      } catch (e) {
                         // Fallback UI simulée si API non démarrée
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Simulation : Push & Email envoyés à l'équipe !"), backgroundColor: Colors.orange));
                      }
                    },
                    icon: const Icon(Icons.notifications_active, size: 16),
                    label: const Text('Simuler Alerte Deadline'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  ),
                  
                  const SizedBox(height: 24),
                  Text('Déplacer vers', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 6, children: ['a_faire', 'en_cours', 'en_revue', 'termine'].map((c) {
                    final isActive = c == column;
                    return InkWell(
                      onTap: isActive ? null : () {
                        setState(() {
                          _kanbanData[column]?.removeWhere((t) => t['id'] == task['id']);
                          task['logs']?.insert(0, 'Déplacée vers ${_columnTitles[c]} le 12/05 par Anas');
                          _kanbanData[c]?.add(task);
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Déplacée vers ${_columnTitles[c]}')));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? _columnColors[c]!.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isActive ? _columnColors[c]! : const Color(0xFFE2E8F0)),
                        ),
                        child: Text(_columnTitles[c]!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? _columnColors[c] : const Color(0xFF64748B))),
                      ),
                    );
                  }).toList()),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Journal d'activité (Logs)
                  Text('Journal d\'Activité', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: task['logs']?.length ?? 0,
                      itemBuilder: (context, idx) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.circle, size: 8, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(child: Text(task['logs'][idx], style: const TextStyle(fontSize: 11, color: Colors.grey))),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$label: ', style: TextStyle(fontSize: 11, color: color)),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }

  Widget _buildAttachment(String name, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(name, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildComment(String author, String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 14, backgroundColor: const Color(0xFFE2E8F0), child: Text(author[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 8),
            Text(time, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          ]),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4)),
        ])),
      ]),
    );
  }

  void _showAddTaskDialog(BuildContext context, {String defaultColumn = 'a_faire'}) {
    final titreController = TextEditingController();
    String assignee = 'Anas';
    String priorite = 'moyenne';
    String colonne = defaultColumn;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nouvelle Tâche', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 450,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titreController, decoration: const InputDecoration(labelText: 'Titre de la tâche', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: assignee,
                decoration: const InputDecoration(labelText: 'Assignée à', border: OutlineInputBorder()),
                items: ['Anas', 'Khadija', 'Youssef'].map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                onChanged: (v) => assignee = v!,
              )),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(
                value: priorite,
                decoration: const InputDecoration(labelText: 'Priorité', border: OutlineInputBorder()),
                items: ['basse', 'moyenne', 'haute'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => priorite = v!,
              )),
            ]),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: colonne,
              decoration: const InputDecoration(labelText: 'Colonne', border: OutlineInputBorder()),
              items: _columnTitles.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (v) => colonne = v!,
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (titreController.text.isEmpty) return;
              final colors = {'Anas': Colors.orange, 'Khadija': Colors.blue, 'Youssef': Colors.green};
              setState(() {
                _kanbanData[colonne]?.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'titre': titreController.text,
                  'assignee': assignee,
                  'priorite': priorite,
                  'debut': '12/05',
                  'echeance': '25/05',
                  'couleur': colors[assignee] ?? Colors.grey,
                  'commentaires': 0,
                  'logs': ['Créée le 12/05'],
                });
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tâche ajoutée !'), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog(BuildContext context) {
    String role = 'Admin';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Inviter un collaborateur', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 400,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const TextField(decoration: InputDecoration(labelText: 'Email du membre', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Rôle & Permissions', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Admin', child: Text('Administrateur (Accès total)')),
                    DropdownMenuItem(value: 'Éditeur', child: Text('Éditeur (Peut modifier tâches)')),
                    DropdownMenuItem(value: 'Lecteur', child: Text('Lecteur (Vue uniquement)')),
                  ],
                  onChanged: (v) => setDialogState(() => role = v!),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        role == 'Admin' ? 'Aura les mêmes droits que vous (budget, invitation, tâches).' : 
                        (role == 'Éditeur' ? 'Pourra modifier et déplacer les tâches, mais sans accès au budget.' : 'Pourra uniquement consulter l\'avancement sans rien modifier.'),
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ]),
                )
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await ApiService.post(ApiConfig.uri('/api/entrepreneur/projet/invite'), headers: {'Content-Type': 'application/json'}, body: json.encode({'email': 'test@test.com', 'role': role, 'projet_id': '1'}));
                  } catch(e) {}
                  if(mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation envoyée !'), backgroundColor: Colors.green));
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
                child: const Text('Envoyer l\'invitation'),
              ),
            ],
          );
        }
      ),
    );
  }
}
