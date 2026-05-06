import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:html' as html;
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
  List<dynamic> _projects = [];
  Map<String, dynamic>? _selectedProjectData;
  List<dynamic> _tasks = [];
  List<dynamic> _messages = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get(ApiConfig.uri('/api/projects-execution'));
      if (res.statusCode == 200) {
        _projects = json.decode(res.body);
        if (_projects.isNotEmpty) {
          await _selectProject(_projects[0]);
        }
      }
    } catch (e) {
      debugPrint('Load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectProject(dynamic project) async {
    setState(() {
      _selectedProjectData = project;
      _isLoading = true;
    });
    try {
      final tasksRes = await ApiService.get(ApiConfig.uri('/api/projects-execution/${project['id']}/tasks'));
      final statsRes = await ApiService.get(ApiConfig.uri('/api/projects-execution/${project['id']}/stats'));
      final msgRes = await ApiService.get(ApiConfig.uri('/api/projects-execution/${project['id']}/messages'));
      
      if (mounted) {
        setState(() {
          _tasks = json.decode(tasksRes.body);
          _stats = json.decode(statsRes.body);
          _messages = json.decode(msgRes.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Select project error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      await ApiService.put(
        ApiConfig.uri('/api/projects-execution/tasks/$taskId'),
        body: {'statut': newStatus}
      );
      _selectProject(_selectedProjectData); // Refresh
    } catch (e) {
      debugPrint('Update task error: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_msgController.text.isEmpty || _selectedProjectData == null) return;
    try {
      final res = await ApiService.post(
        ApiConfig.uri('/api/projects-execution/${_selectedProjectData!['id']}/messages'),
        body: {'contenu': _msgController.text}
      );
      if (res.statusCode == 201) {
        _msgController.clear();
        _selectProject(_selectedProjectData); // Refresh messages
      }
    } catch (e) {
      debugPrint('Send message error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _projects.isEmpty) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildTabs(),
        const SizedBox(height: 24),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildKanbanView(),
              _buildTimelineView(),
              _buildBudgetKpiView(),
              _buildChatView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Suivi de Projet Collaboratif', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          const Text('Gérez les tâches, le budget et l\'équipe.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        ]),
        Row(children: [
          if (_projects.isNotEmpty)
            DropdownButton<String>(
              value: _selectedProjectData?['id'],
              items: _projects.map<DropdownMenuItem<String>>((p) => DropdownMenuItem(value: p['id'], child: Text(p['nom']))).toList(),
              onChanged: (id) => _selectProject(_projects.firstWhere((p) => p['id'] == id)),
            ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Nouveau Projet'),
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
          ),
        ]),
      ],
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: NexaColors.primaryGreen,
      indicatorColor: NexaColors.primaryGreen,
      tabs: const [
        Tab(text: 'Kanban'),
        Tab(text: 'Timeline'),
        Tab(text: 'Budget & KPIs'),
        Tab(text: 'Chat d\'Équipe')
      ],
    );
  }

  // --- KANBAN VIEW ---
  Widget _buildKanbanView() {
    return Row(
      children: [
        _buildKanbanColumn('À Faire', 'todo'),
        _buildKanbanColumn('En Cours', 'in_progress'),
        _buildKanbanColumn('Terminé', 'done'),
      ],
    );
  }

  Widget _buildKanbanColumn(String title, String status) {
    final columnTasks = _tasks.where((t) => t['statut'] == status).toList();
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  CircleAvatar(radius: 10, backgroundColor: Colors.white, child: Text('${columnTasks.length}', style: const TextStyle(fontSize: 10))),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: columnTasks.length,
                itemBuilder: (context, i) => _buildTaskCard(columnTasks[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(dynamic task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(task['titre'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        subtitle: Text(task['assignee']?['nom_complet'] ?? 'Non assigné', style: const TextStyle(fontSize: 11)),
        trailing: PopupMenuButton<String>(
          onSelected: (val) => _updateTaskStatus(task['id'], val),
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'todo', child: Text('À Faire')),
            const PopupMenuItem(value: 'in_progress', child: Text('En Cours')),
            const PopupMenuItem(value: 'done', child: Text('Terminé')),
          ],
        ),
      ),
    );
  }

  // --- TIMELINE VIEW (Interactive) ---
  Widget _buildTimelineView() {
    if (_tasks.isEmpty) return const Center(child: Text('Aucune tâche avec date limite pour la timeline.'));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calendrier d\'Exécution', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (ctx, i) {
                final task = _tasks[i];
                if (task['date_limite'] == null) return const SizedBox();
                
                final deadline = DateTime.parse(task['date_limite']);
                final now = DateTime.now();
                final diff = deadline.difference(now).inDays;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      SizedBox(width: 150, child: Text(task['titre'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(height: 20, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10))),
                            FractionallySizedBox(
                              widthFactor: (diff.clamp(0, 30) / 30).toDouble(),
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [NexaColors.primaryGreen, NexaColors.primaryGreen.withOpacity(0.7)]),
                                  borderRadius: BorderRadius.circular(10)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${diff}j restants', style: TextStyle(fontSize: 10, color: diff < 3 ? Colors.red : Colors.grey)),
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

  // --- BUDGET & KPI VIEW ---
  Widget _buildBudgetKpiView() {
    if (_stats.isEmpty) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard('Avancement', '${_stats['progress']}%', NexaColors.primaryGreen),
              const SizedBox(width: 24),
              _buildStatCard('Budget Consommé', '${_stats['budgetBurnRate']}%', Colors.blue),
            ],
          ),
          const SizedBox(height: 40),
          _buildBudgetProgress(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetProgress() {
    final double burn = (_stats['budgetBurnRate'] as num).toDouble() / 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Utilisation du budget global', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: burn, minHeight: 10, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(burn > 0.9 ? Colors.red : NexaColors.primaryGreen)),
        const SizedBox(height: 8),
        Text('Dépensé: ${_stats['totalSpent']} MAD / Restant: ${_stats['budgetRemaining']} MAD', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Future<void> _uploadAttachment(String taskId) async {
    // Note: Utilisation de dart:html pour le web
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.pdf,.doc,.docx,.jpg,.png';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isEmpty) return;
      final reader = html.FileReader();
      reader.readAsDataUrl(files[0]);
      reader.onLoadEnd.listen((e) async {
        final base64 = reader.result as String;
        try {
          await ApiService.post(
            ApiConfig.uri('/api/projects-execution/tasks/$taskId/attachments'),
            body: {
              'fileData': base64,
              'fileName': files[0].name,
              'mimeType': files[0].type
            }
          );
          _selectProject(_selectedProjectData); // Refresh
        } catch (e) {
          debugPrint('Upload error: $e');
        }
      });
    });
  }

  Widget _buildAttachment(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attach_file, size: 14, color: Colors.blue),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontSize: 11, color: Colors.blue)),
        ],
      ),
    );
  }
  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              final msg = _messages[i];
              final isMe = msg['expediteur_id'] == widget.userData?['id'];
              return _buildChatMessage(msg, isMe);
            },
          ),
        ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildChatMessage(dynamic msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? NexaColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isMe ? null : Border.all(color: Colors.grey[200]!)
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe) Text(msg['expediteur']['nom_complet'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text(msg['contenu'], style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _msgController, decoration: const InputDecoration(hintText: 'Discutez avec l\'équipe...', border: InputBorder.none))),
          IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: NexaColors.primaryGreen)),
        ],
      ),
    );
  }
}
