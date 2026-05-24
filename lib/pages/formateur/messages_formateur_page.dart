import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../widgets/formateur/formateur_ui.dart';

class MessagesFormateurPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final ValueChanged<int>? onUnreadChanged;

  const MessagesFormateurPage({super.key, this.userData, this.onUnreadChanged});

  @override
  State<MessagesFormateurPage> createState() => MessagesFormateurPageState();
}

class MessagesFormateurPageState extends State<MessagesFormateurPage> {

  static const _surface = Color(0xFFF4F6F9);
  static const _border = Color(0xFFE8ECF2);

  bool _loadingConvs = true;
  bool _loadingThread = false;
  bool _sending = false;
  String? _error;
  String _filterRole = 'Tous';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  final _composer = TextEditingController();
  final _scrollChat = ScrollController();

  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _thread = [];
  String? _selectedId;

  String get _formateurId => widget.userData?['id']?.toString() ?? 'user_123';

  static List<Map<String, dynamic>> _demoConversations() => [
        {
          'id': 'yassine',
          'expediteur': 'Yassine Mansouri',
          'role': 'Apprenant',
          'cours': 'Maîtriser Flutter',
          'dernier_message': 'Est-ce que le cours Flutter sera mis à jour ?',
          'date': '15 Mai 2024',
          'heure': '14:32',
          'non_lus': 2,
          'en_ligne': true,
        },
        {
          'id': 'laila',
          'expediteur': 'Laila Bennani',
          'role': 'Apprenant',
          'cours': 'Marketing Digital',
          'dernier_message': 'Merci pour la correction du module 3 !',
          'date': '14 Mai 2024',
          'heure': '09:15',
          'non_lus': 0,
          'en_ligne': false,
        },
        {
          'id': 'admin',
          'expediteur': 'Admin NexaMa',
          'role': 'Support',
          'cours': 'Plateforme',
          'dernier_message': 'Votre compte formateur est vérifié.',
          'date': '12 Mai 2024',
          'heure': '16:00',
          'non_lus': 1,
          'en_ligne': true,
        },
        {
          'id': 'mehdi',
          'expediteur': 'Mehdi O.',
          'role': 'Apprenant',
          'cours': 'Création de Site Web',
          'dernier_message': 'Pouvez-vous ajouter un quiz sur le SEO ?',
          'date': '11 Mai 2024',
          'heure': '18:45',
          'non_lus': 0,
          'en_ligne': false,
        },
      ];

  static Map<String, List<Map<String, dynamic>>> _demoThreads() => {
        'yassine': [
          {'id': 'm1', 'auteur': 'Yassine Mansouri', 'texte': 'Bonjour, j\'ai une question sur le module 4.', 'date': '14 Mai', 'heure': '10:20', 'expediteur_apprenant': true},
          {'id': 'm2', 'auteur': 'Vous', 'texte': 'Bonjour Yassine, je vous réponds dans la journée.', 'date': '14 Mai', 'heure': '11:05', 'expediteur_apprenant': false},
          {'id': 'm3', 'auteur': 'Yassine Mansouri', 'texte': 'Est-ce que le cours Flutter sera mis à jour ?', 'date': '15 Mai', 'heure': '14:32', 'expediteur_apprenant': true},
        ],
        'laila': [
          {'id': 'm1', 'auteur': 'Laila Bennani', 'texte': 'Merci pour la correction du module 3 !', 'date': '14 Mai', 'heure': '09:15', 'expediteur_apprenant': true},
        ],
        'admin': [
          {'id': 'm1', 'auteur': 'Admin NexaMa', 'texte': 'Votre compte formateur est vérifié.', 'date': '12 Mai', 'heure': '16:00', 'expediteur_apprenant': true},
        ],
        'mehdi': [
          {'id': 'm1', 'auteur': 'Mehdi O.', 'texte': 'Pouvez-vous ajouter un quiz sur le SEO ?', 'date': '11 Mai', 'heure': '18:45', 'expediteur_apprenant': true},
        ],
      };

  final Map<String, List<Map<String, dynamic>>> _localThreads = {};
  bool _useLocalOnly = false;

  void _notifyUnread() => widget.onUnreadChanged?.call(_totalUnread);

  void _applyConversations(List<Map<String, dynamic>> list) {
    setState(() {
      _conversations = list;
      _loadingConvs = false;
      if (_selectedId == null && list.isNotEmpty) {
        _selectedId = list.first['id']?.toString();
      }
    });
    _notifyUnread();
    if (_selectedId != null) _fetchThread(_selectedId!);
  }

  void _loadDemoFallback() {
    _useLocalOnly = true;
    for (final e in _demoThreads().entries) {
      _localThreads[e.key] = List.from(e.value);
    }
    _applyConversations(_demoConversations());
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase()));
    _fetchConversations();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _composer.dispose();
    _scrollChat.dispose();
    super.dispose();
  }

  Future<void> _fetchConversations() async {
    setState(() {
      _loadingConvs = true;
      _error = null;
    });
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/messages/$_formateurId'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        _useLocalOnly = false;
        final raw = json.decode(response.body) as List<dynamic>;
        final list = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _applyConversations(list);
      } else {
        _loadDemoFallback();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mode démo (API ${response.statusCode}). Démarrez le backend NexaMa sur le port 3000.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        _loadDemoFallback();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mode démo — backend indisponible. Les messages restent utilisables localement.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _fetchThread(String convId) async {
    setState(() => _loadingThread = true);

    if (_useLocalOnly) {
      setState(() {
        _thread = List.from(_localThreads[convId] ?? _demoThreads()[convId] ?? []);
        _loadingThread = false;
        final i = _conversations.indexWhere((c) => c['id'] == convId);
        if (i >= 0) _conversations[i]['non_lus'] = 0;
      });
      _notifyUnread();
      _scrollToEnd();
      return;
    }

    try {
      try {
        await ApiService.patch(ApiConfig.uri('/api/formateur/messages/$_formateurId/$convId/read'));
      } catch (_) {
        /* marquer lu : non bloquant */
      }
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/messages/$_formateurId/$convId'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final msgs = (data['messages'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        setState(() {
          _thread = msgs;
          _loadingThread = false;
          final i = _conversations.indexWhere((c) => c['id'] == convId);
          if (i >= 0) _conversations[i]['non_lus'] = 0;
        });
        _notifyUnread();
        _scrollToEnd();
      } else {
        setState(() => _loadingThread = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _thread = List.from(_localThreads[convId] ?? []);
          _loadingThread = false;
        });
        _scrollToEnd();
      }
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollChat.hasClients) {
        _scrollChat.jumpTo(_scrollChat.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _composer.text.trim();
    final convId = _selectedId;
    if (text.isEmpty || convId == null || _sending) return;

    final now = TimeOfDay.now();
    final heure = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final optimistic = {
      'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      'auteur': 'Vous',
      'texte': text,
      'date': 'Aujourd\'hui',
      'heure': heure,
      'expediteur_apprenant': false,
    };

    _composer.clear();
    setState(() {
      _sending = true;
      _thread = [..._thread, optimistic];
      final i = _conversations.indexWhere((c) => c['id'] == convId);
      if (i >= 0) {
        _conversations[i]['dernier_message'] = text;
        _conversations[i]['heure'] = heure;
        _conversations[i]['date'] = 'Aujourd\'hui';
      }
    });
    _scrollToEnd();

    if (_useLocalOnly) {
      _localThreads.putIfAbsent(convId, () => []).add(optimistic);
      setState(() => _sending = false);
      return;
    }

    try {
      final response = await ApiService.post(
        ApiConfig.uri('/api/formateur/messages/$_formateurId/$convId'),
        body: {'texte': text},
      );
      if (!mounted) return;
      if (response.statusCode == 201) {
        await _fetchConversations();
        await _fetchThread(convId);
      } else {
        setState(() => _thread.removeWhere((m) => m['id'] == optimistic['id']));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Envoi refusé (${response.statusCode}).'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (_) {
      _localThreads.putIfAbsent(convId, () => List.from(_thread));
      _useLocalOnly = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message enregistré en local (hors ligne).'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showContactProfile(Map<String, dynamic> conv) {
    final name = conv['expediteur']?.toString() ?? '';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileRow(Icons.school_outlined, 'Cours : ${conv['cours']}'),
            _profileRow(Icons.badge_outlined, 'Rôle : ${conv['role']}'),
            _profileRow(
              conv['en_ligne'] == true ? Icons.circle : Icons.circle_outlined,
              conv['en_ligne'] == true ? 'En ligne' : 'Hors ligne',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
          if (conv['role'] == 'Apprenant')
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ouverture fiche apprenant — $name'), behavior: SnackBarBehavior.floating),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: FormateurColors.accent),
              child: const Text('Voir la progression'),
            ),
        ],
      ),
    );
  }

  Widget _profileRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: FormateurColors.muted),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 14))),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredConvs {
    return _conversations.where((c) {
      final role = c['role']?.toString() ?? '';
      if (_filterRole == 'Apprenants' && role != 'Apprenant') return false;
      if (_filterRole == 'Support' && role != 'Support') return false;
      if (_searchQuery.isEmpty) return true;
      final blob = '${c['expediteur']} ${c['cours']} ${c['dernier_message']}'.toLowerCase();
      return blob.contains(_searchQuery);
    }).toList();
  }

  Map<String, dynamic>? get _selected {
    if (_selectedId == null) return null;
    for (final c in _conversations) {
      if (c['id'] == _selectedId) return c;
    }
    return null;
  }

  int get _totalUnread => _conversations.fold(0, (s, c) => s + ((c['non_lus'] as num?)?.toInt() ?? 0));

  Color _avatarColor(String id) {
    switch (id) {
      case 'yassine':
        return const Color(0xFF1565C0);
      case 'laila':
        return const Color(0xFF7B1FA2);
      case 'admin':
        return NexaColors.primaryGreen;
      case 'mehdi':
        return const Color(0xFF00897B);
      default:
        return FormateurColors.accent;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _selectConversation(String id) {
    setState(() => _selectedId = id);
    _fetchThread(id);
  }

  /// Ouvre une conversation depuis une autre page (ex. Mes apprenants).
  void openConversation(String conversationId) {
    if (_conversations.any((c) => c['id'] == conversationId)) {
      _selectConversation(conversationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingConvs) return const FormateurLoading();

    if (_error != null) {
      return FormateurEmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Messages indisponibles',
        message: _error!,
        actionLabel: 'Réessayer',
        onAction: _fetchConversations,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormateurPageHeader(
          title: 'Messages',
          subtitle: 'Échanges sécurisés avec vos apprenants et l\'équipe NexaMa.',
          trailing: _totalUnread > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: FormateurColors.accentLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: FormateurColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '$_totalUnread non lu${_totalUnread > 1 ? 's' : ''}',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: FormateurColors.accent),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: FormateurColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                SizedBox(width: 320, child: _buildConversationPanel()),
                Container(width: 1, color: _border),
                Expanded(child: _buildChatPanel()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConversationPanel() {
    return ColoredBox(
      color: _surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conversations', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _searchCtrl,
                    style: GoogleFonts.inter(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Rechercher…',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: FormateurColors.accent, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: ['Tous', 'Apprenants', 'Support'].map((f) {
                    return FormateurChip(
                      label: f,
                      selected: _filterRole == f,
                      onTap: () => setState(() => _filterRole = f),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredConvs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Aucune conversation', style: GoogleFonts.inter(fontSize: 13, color: FormateurColors.muted)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredConvs.length,
                    itemBuilder: (_, i) {
                      final c = _filteredConvs[i];
                      final id = c['id']?.toString() ?? '';
                      final selected = id == _selectedId;
                      final unread = ((c['non_lus'] as num?)?.toInt() ?? 0) > 0;
                      final name = c['expediteur']?.toString() ?? '—';
                      return Material(
                        color: selected ? Colors.white : Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectConversation(id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: _border.withValues(alpha: 0.6))),
                              boxShadow: selected
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(2, 0))]
                                  : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: _avatarColor(id).withValues(alpha: 0.15),
                                      child: Text(_initials(name), style: TextStyle(color: _avatarColor(id), fontWeight: FontWeight.w800, fontSize: 13)),
                                    ),
                                    if (c['en_ligne'] == true)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: NexaColors.primaryGreen,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: GoogleFonts.inter(
                                                fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                                                fontSize: 13,
                                                color: NexaColors.darkNavy,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            c['heure']?.toString() ?? '',
                                            style: GoogleFonts.inter(fontSize: 10, color: FormateurColors.muted),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        c['cours']?.toString() ?? '',
                                        style: GoogleFonts.inter(fontSize: 10, color: FormateurColors.accent, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c['dernier_message']?.toString() ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: unread ? NexaColors.darkNavy : FormateurColors.muted,
                                          fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (unread)
                                  Container(
                                    margin: const EdgeInsets.only(left: 6, top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: FormateurColors.accent, borderRadius: BorderRadius.circular(10)),
                                    child: Text(
                                      '${c['non_lus']}',
                                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatPanel() {
    final sel = _selected;
    if (sel == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Sélectionnez une conversation', style: GoogleFonts.inter(color: FormateurColors.muted, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    final id = sel['id']?.toString() ?? '';
    final name = sel['expediteur']?.toString() ?? '';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: _border)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _avatarColor(id).withValues(alpha: 0.15),
                child: Text(_initials(name), style: TextStyle(color: _avatarColor(id), fontWeight: FontWeight.w800, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15, color: NexaColors.darkNavy)),
                    Text(
                      '${sel['role']} · ${sel['cours']}',
                      style: GoogleFonts.inter(fontSize: 12, color: FormateurColors.muted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Actualiser',
                onPressed: () => _fetchThread(id),
                icon: const Icon(Icons.refresh, size: 20, color: FormateurColors.muted),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: FormateurColors.muted),
                onSelected: (v) {
                  if (v == 'profile') _showContactProfile(sel);
                  if (v == 'mark_unread') {
                    setState(() {
                      final i = _conversations.indexWhere((c) => c['id'] == id);
                      if (i >= 0) _conversations[i]['non_lus'] = 1;
                    });
                    _notifyUnread();
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'profile', child: Text('Voir le profil')),
                  const PopupMenuItem(value: 'mark_unread', child: Text('Marquer non lu')),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: const Color(0xFFFAFBFC),
            child: _loadingThread
                ? const Center(child: CircularProgressIndicator(color: FormateurColors.accent))
                : ListView.builder(
                    controller: _scrollChat,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: _thread.length,
                    itemBuilder: (_, i) => _MessageBubble(msg: _thread[i]),
                  ),
          ),
        ),
        _buildComposer(),
      ],
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            tooltip: 'Pièce jointe',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pièce jointe — démo (PDF, image).'), behavior: SnackBarBehavior.floating),
              );
            },
            icon: const Icon(Icons.attach_file, color: FormateurColors.muted),
          ),
          IconButton(
            onPressed: () {
              const emojis = ['👋', '✅', '📚', '💡', '🙏'];
              showModalBottomSheet<void>(
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Wrap(
                    spacing: 12,
                    children: emojis
                        .map(
                          (e) => InkWell(
                            onTap: () {
                              _composer.text += e;
                              Navigator.pop(ctx);
                            },
                            child: Text(e, style: const TextStyle(fontSize: 28)),
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.emoji_emotions_outlined, color: FormateurColors.muted),
          ),
          Expanded(
            child: TextField(
              controller: _composer,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Écrire un message…',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
                filled: true,
                fillColor: _surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: FormateurColors.accent, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _sending ? null : _sendMessage,
            style: FilledButton.styleFrom(
              backgroundColor: FormateurColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _sending
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final fromLearner = msg['expediteur_apprenant'] == true;
    final text = msg['texte']?.toString() ?? '';
    final time = '${msg['date'] ?? ''} · ${msg['heure'] ?? ''}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: fromLearner ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (fromLearner) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: FormateurColors.accentLight,
              child: Text(
                (msg['auteur']?.toString() ?? '?')[0],
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: FormateurColors.accent),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: fromLearner ? Colors.white : FormateurColors.accent,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(fromLearner ? 4 : 14),
                  bottomRight: Radius.circular(fromLearner ? 14 : 4),
                ),
                border: fromLearner ? Border.all(color: const Color(0xFFE8ECF2)) : null,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (fromLearner)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        msg['auteur']?.toString() ?? '',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: FormateurColors.accent),
                      ),
                    ),
                  Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.4,
                      color: fromLearner ? NexaColors.darkNavy : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: fromLearner ? FormateurColors.muted : Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
