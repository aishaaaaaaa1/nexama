import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

enum _SecureChatMsgKind { text, attachment, voice }

/// Messagerie sécurisée NexaMa — zone principale (3 colonnes).
/// Le cadre sidebar / topbar est fourni par [PrestataireDashboard].
class MessagesSecurePrestatairePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const MessagesSecurePrestatairePage({super.key, this.userData});

  @override
  State<MessagesSecurePrestatairePage> createState() => _MessagesSecurePrestatairePageState();
}

class _Conv {
  const _Conv({
    required this.id,
    required this.name,
    required this.metier,
    required this.lastMsg,
    required this.time,
    required this.online,
    required this.initials,
    required this.avatarColor,
    this.unread,
  });

  final String id;
  final String name;
  final String metier;
  final String lastMsg;
  final String time;
  final bool online;
  final String initials;
  final Color avatarColor;
  final int? unread;
}

/// Modèle d’un message dans le fil (remplace l’ancienne classe `_ChatLine` en `const`, renommée
/// pour permettre le hot reload sans erreur « Const class cannot become non-const »).
class _SecureChatMsg {
  _SecureChatMsg({
    required this.text,
    required this.fromClient,
    required this.time,
    this.read = false,
    _SecureChatMsgKind? kind,
    this.voiceDurationSec = 0,
  }) : _kind = kind;

  final String text;
  final bool fromClient;
  final String time;
  final bool read;
  final _SecureChatMsgKind? _kind;
  _SecureChatMsgKind get kind => _kind ?? _SecureChatMsgKind.text;
  final int voiceDurationSec;
}

class _MessagesSecurePrestatairePageState extends State<MessagesSecurePrestatairePage> with TickerProviderStateMixin {
  final _searchConv = TextEditingController();
  final _composer = TextEditingController();
  final _composerFocus = FocusNode();
  final _scrollChat = ScrollController();
  final _devisMontantCtrl = TextEditingController();
  final _devisNoteCtrl = TextEditingController();

  late final AnimationController _pulseOnline;
  Timer? _recordTimer;
  bool _recordingVoice = false;
  int _recordElapsed = 0;

  static const _kSurface = Color(0xFFF4F6F9);
  static const _kBorder = Color(0xFFE8ECF2);
  static const _kMuted = Color(0xFF64748B);

  static final List<_Conv> _allConversations = [
    _Conv(
      id: 'ahmed',
      name: 'Ahmed Benali',
      metier: 'Entrepreneur · E-commerce',
      lastMsg: 'Bonjour, j\'aimerais discuter du projet e-commerce.',
      time: '10:42',
      unread: 2,
      online: true,
      initials: 'AB',
      avatarColor: const Color(0xFF1565C0),
    ),
    _Conv(
      id: 'sara',
      name: 'Sara Digital',
      metier: 'Directrice marketing',
      lastMsg: 'Merci pour votre devis.',
      time: '09:15',
      online: false,
      initials: 'SD',
      avatarColor: const Color(0xFF7B1FA2),
    ),
    _Conv(
      id: 'support',
      name: 'NexaMa Support',
      metier: 'Équipe conformité',
      lastMsg: 'Votre compte a été vérifié.',
      time: 'Hier',
      online: true,
      initials: 'NX',
      avatarColor: NexaColors.primaryGreen,
    ),
    _Conv(
      id: 'youssef',
      name: 'Youssef Startup',
      metier: 'Fondateur SaaS',
      lastMsg: 'Pouvez-vous commencer cette semaine ?',
      time: 'Hier',
      online: false,
      initials: 'YS',
      avatarColor: const Color(0xFF00897B),
    ),
  ];

  late Map<String, List<_SecureChatMsg>> _threads;
  String _selectedId = 'ahmed';
  String _query = '';
  int _narrowIndex = 1;
  final Set<String> _markedReadIds = {};

  @override
  void initState() {
    super.initState();
    _pulseOnline = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _threads = {
      'ahmed': [
        _SecureChatMsg(text: 'Bonjour, je cherche un développeur React pour ma plateforme.', fromClient: true, time: '10:38'),
        _SecureChatMsg(
          text: 'Bonjour Ahmed 👋\nJe serais ravi de collaborer avec vous.',
          fromClient: false,
          time: '10:39',
          read: true,
        ),
        _SecureChatMsg(text: 'Excellent. Quel serait votre délai estimé ?', fromClient: true, time: '10:40'),
        _SecureChatMsg(text: 'Environ 3 semaines selon les fonctionnalités.', fromClient: false, time: '10:40', read: true),
        _SecureChatMsg(text: 'Parfait. Pouvez-vous m\'envoyer un devis ?', fromClient: true, time: '10:41'),
        _SecureChatMsg(text: 'Bien sûr, je prépare cela aujourd\'hui.', fromClient: false, time: '10:42', read: true),
      ],
      'sara': [
        _SecureChatMsg(text: 'Bonjour, nous avons bien reçu votre proposition.', fromClient: true, time: '08:50'),
        _SecureChatMsg(text: 'Merci pour votre retour rapide.', fromClient: false, time: '09:00', read: true),
        _SecureChatMsg(text: 'Merci pour votre devis.', fromClient: true, time: '09:15'),
      ],
      'support': [
        _SecureChatMsg(text: 'Bonjour, votre dossier KYC est complet.', fromClient: true, time: 'Hier 16:20'),
        _SecureChatMsg(text: 'Votre compte a été vérifié.', fromClient: true, time: 'Hier 16:22'),
      ],
      'youssef': [
        _SecureChatMsg(text: 'Salut, on avance sur le MVP ?', fromClient: true, time: 'Hier 11:02'),
        _SecureChatMsg(text: 'Oui, je peux démarrer dès validation du scope.', fromClient: false, time: 'Hier 11:30', read: true),
        _SecureChatMsg(text: 'Pouvez-vous commencer cette semaine ?', fromClient: true, time: 'Hier 14:05'),
      ],
    };
    _searchConv.addListener(_onSearchChanged);
    _markedReadIds.add(_selectedId);
    _devisNoteCtrl.text = 'Prestations développement & intégration selon cahier des charges.';
  }

  void _onSearchChanged() {
    setState(() => _query = _searchConv.text.trim().toLowerCase());
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _pulseOnline.dispose();
    _searchConv.removeListener(_onSearchChanged);
    _searchConv.dispose();
    _composer.dispose();
    _composerFocus.dispose();
    _devisMontantCtrl.dispose();
    _devisNoteCtrl.dispose();
    _scrollChat.dispose();
    super.dispose();
  }

  _Conv? get _selected {
    for (final c in _allConversations) {
      if (c.id == _selectedId) return c;
    }
    return null;
  }

  List<_Conv> get _filtered {
    if (_query.isEmpty) return _allConversations;
    return _allConversations.where((c) {
      final blob = '${c.name} ${c.metier} ${c.lastMsg}'.toLowerCase();
      return blob.contains(_query);
    }).toList();
  }

  List<_SecureChatMsg> get _currentThread => List<_SecureChatMsg>.from(_threads[_selectedId] ?? []);

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _scrollChatToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollChat.hasClients) {
        _scrollChat.animateTo(
          _scrollChat.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _appendOutgoing(_SecureChatMsg line) {
    setState(() {
      _threads[_selectedId] = [..._currentThread, line];
    });
    _scrollChatToEnd();
  }

  void _sendMessage() {
    final t = _composer.text.trim();
    if (t.isEmpty) return;
    _appendOutgoing(_SecureChatMsg(text: t, fromClient: false, time: 'À l\'instant', read: true));
    _composer.clear();
  }

  void _toggleVoiceRecord() {
    if (_recordingVoice) {
      _recordTimer?.cancel();
      _recordTimer = null;
      final secs = _recordElapsed;
      setState(() {
        _recordingVoice = false;
        if (secs > 0) {
          _threads[_selectedId] = [
            ..._currentThread,
            _SecureChatMsg(
              text: 'Message vocal',
              fromClient: false,
              time: 'À l\'instant',
              read: true,
              kind: _SecureChatMsgKind.voice,
              voiceDurationSec: secs,
            ),
          ];
        }
        _recordElapsed = 0;
      });
      if (secs > 0) {
        _toast('Message vocal envoyé (${secs}s)');
        _scrollChatToEnd();
      } else {
        _toast('Enregistrement annulé');
      }
    } else {
      setState(() {
        _recordingVoice = true;
        _recordElapsed = 0;
      });
      _toast('Enregistrement… Appuyez à nouveau sur le micro pour envoyer.');
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _recordElapsed++);
      });
    }
  }

  void _showEmojiPicker() {
    const emojis = ['👋', '😊', '👍', '🙏', '✅', '🚀', '💼', '📎', '📅', '💡', '🔒', '🇲🇦'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Réactions', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: NexaColors.darkNavy)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: emojis
                  .map(
                    (e) => Material(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          final v = _composer.text;
                          final sel = _composer.selection;
                          final start = sel.isValid ? sel.start.clamp(0, v.length) : v.length;
                          final end = sel.isValid ? sel.end.clamp(0, v.length) : v.length;
                          final newText = v.replaceRange(start, end, e);
                          _composer.value = TextEditingValue(
                            text: newText,
                            selection: TextSelection.collapsed(offset: start + e.length),
                          );
                          Navigator.pop(ctx);
                          _composerFocus.requestFocus();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(padding: const EdgeInsets.all(12), child: Text(e, style: const TextStyle(fontSize: 26))),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined, color: NexaColors.primaryGreen),
                title: Text('Document', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                subtitle: Text('Joindre un fichier au fil', style: GoogleFonts.inter(fontSize: 12, color: _kMuted)),
                onTap: () {
                  Navigator.pop(ctx);
                  _promptAttachmentName();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined, color: Color(0xFF1565C0)),
                title: Text('Image', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                subtitle: Text('Capture ou visuel projet', style: GoogleFonts.inter(fontSize: 12, color: _kMuted)),
                onTap: () {
                  Navigator.pop(ctx);
                  _appendOutgoing(
                    _SecureChatMsg(text: 'maquette_home.png', fromClient: false, time: 'À l\'instant', read: true, kind: _SecureChatMsgKind.attachment),
                  );
                  _toast('Image ajoutée à la conversation');
                },
              ),
              ListTile(
                leading: const Icon(Icons.link_rounded, color: Color(0xFF7B1FA2)),
                title: Text('Lien', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                subtitle: Text('Partager une URL', style: GoogleFonts.inter(fontSize: 12, color: _kMuted)),
                onTap: () {
                  Navigator.pop(ctx);
                  _promptLink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _promptAttachmentName() async {
    final ctrl = TextEditingController(text: 'document.pdf');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Pièce jointe', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: 'Nom du fichier',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Ajouter')),
        ],
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;
    _appendOutgoing(_SecureChatMsg(text: name, fromClient: false, time: 'À l\'instant', read: true, kind: _SecureChatMsgKind.attachment));
    _toast('Fichier ajouté : $name');
  }

  Future<void> _promptLink() async {
    final ctrl = TextEditingController(text: 'https://nexama.ma/projet');
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Lien à partager', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: TextField(controller: ctrl, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Envoyer')),
        ],
      ),
    );
    if (url == null || url.isEmpty || !mounted) return;
    _appendOutgoing(_SecureChatMsg(text: url, fromClient: false, time: 'À l\'instant', read: true));
    _toast('Lien envoyé');
  }

  Future<void> _showVideoCallDialog() async {
    final c = _selected;
    if (c == null) return;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.videocam_rounded, color: NexaColors.primaryGreen),
            const SizedBox(width: 10),
            Expanded(child: Text('Appel vidéo sécurisé', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 17))),
          ],
        ),
        content: Text(
          'Lancer un appel chiffré NexaMa avec ${c.name} ?\n\nConnexion peer-to-peer simulée (démo).',
          style: GoogleFonts.inter(height: 1.4, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen),
            child: const Text('Rejoindre'),
          ),
        ],
      ),
    );
    if (go == true && mounted) {
      _toast('Connexion à la salle sécurisée…');
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam, size: 48, color: NexaColors.primaryGreen),
              const SizedBox(height: 16),
              Text('Appel avec ${c.name}', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Démo — fermez pour quitter.', style: GoogleFonts.inter(color: _kMuted, fontSize: 13)),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Raccrocher'))],
        ),
      );
    }
  }

  void _showClientProfileSheet() {
    final c = _selected;
    if (c == null) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _avatarCircle(c.initials, c.avatarColor, 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18)),
                        Text(c.metier, style: GoogleFonts.inter(color: _kMuted, fontSize: 13)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: NexaColors.primaryGreen, size: 18),
                            const SizedBox(width: 4),
                            Text('Profil vérifié NexaMa', style: GoogleFonts.inter(fontSize: 12, color: NexaColors.primaryGreen, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _profileDialogRow(Icons.location_on_outlined, 'Casablanca, Maroc'),
              _profileDialogRow(Icons.email_outlined, '${c.id}@exemple.ma'),
              _profileDialogRow(Icons.phone_outlined, '+212 6 12 34 56 78'),
              _profileDialogRow(Icons.calendar_today_outlined, 'Membre depuis 2024'),
            ],
          ),
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer'))],
      ),
    );
  }

  Widget _profileDialogRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _kMuted),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 14, height: 1.35))),
        ],
      ),
    );
  }

  Future<void> _showDevisDialog() async {
    _devisMontantCtrl.text = '15000';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Envoyer un devis', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _devisMontantCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant (DH)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _devisNoteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen),
            child: const Text('Envoyer au client'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final dh = _devisMontantCtrl.text.trim();
    _appendOutgoing(
      _SecureChatMsg(
        text: 'Devis NexaMa — $dh DH\n${_devisNoteCtrl.text.trim()}',
        fromClient: false,
        time: 'À l\'instant',
        read: true,
      ),
    );
    _toast('Devis transmis dans la conversation');
  }

  Future<void> _showMeetingPicker() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
    if (!mounted || time == null) return;
    final when = '${date.day}/${date.month}/${date.year} à ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    _appendOutgoing(
      _SecureChatMsg(
        text: 'Réunion NexaMa planifiée le $when (lien calendrier envoyé par e-mail).',
        fromClient: false,
        time: 'À l\'instant',
        read: true,
      ),
    );
    _toast('Invitation enregistrée');
  }

  void _openSharedFile(String name) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Fichier partagé dans l’espace sécurisé NexaMa.', style: GoogleFonts.inter(color: _kMuted, fontSize: 13)),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _toast('Ouverture de $name (aperçu)');
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Ouvrir'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _toast('Téléchargement démarré : $name');
                },
                style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Télécharger'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openClientPanelDrawer() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: _buildColumnClient(scroll: scroll),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final threeCols = constraints.maxWidth >= 1080;
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kBorder),
              boxShadow: NexaShadows.dashboard,
            ),
            child: threeCols
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 32, child: _buildColumnConversations()),
                      Expanded(flex: 45, child: _buildColumnChat(showInfoButton: false)),
                      if (_selected != null) Expanded(flex: 28, child: _buildColumnClient()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                        child: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 0, label: Text('Conversations'), icon: Icon(Icons.forum_outlined, size: 18)),
                            ButtonSegment(value: 1, label: Text('Chat'), icon: Icon(Icons.chat_bubble_outline, size: 18)),
                            ButtonSegment(value: 2, label: Text('Client'), icon: Icon(Icons.person_outline, size: 18)),
                          ],
                          selected: {_narrowIndex},
                          onSelectionChanged: (s) => setState(() => _narrowIndex = s.first),
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            textStyle: WidgetStateProperty.all(GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: _narrowIndex,
                          children: [
                            _buildColumnConversations(),
                            _buildColumnChat(showInfoButton: true),
                            _selected != null ? _buildColumnClient() : const Center(child: Text('—')),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildColumnConversations() {
    return Container(
      color: _kSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user_outlined, size: 22, color: NexaColors.primaryGreen.withValues(alpha: 0.9)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Messages Sécurisés',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: NexaColors.darkNavy, letterSpacing: -0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Échanges sécurisés avec les entrepreneurs et l’administration.',
                  style: GoogleFonts.inter(fontSize: 12.5, height: 1.35, color: _kMuted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchConv,
              decoration: InputDecoration(
                hintText: 'Rechercher une conversation…',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                suffixIcon: _searchConv.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Effacer',
                        icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                        onPressed: () {
                          _searchConv.clear();
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: NexaColors.primaryGreen.withValues(alpha: 0.65), width: 1.4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final c = _filtered[i];
                final sel = c.id == _selectedId;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 280 + i * 40),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, child) => Opacity(opacity: t, child: Transform.translate(offset: Offset(-8 * (1 - t), 0), child: child)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedId = c.id;
                            _markedReadIds.add(c.id);
                            if (MediaQuery.sizeOf(context).width < 1080) {
                              _narrowIndex = 1;
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: sel ? Colors.white : Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: sel ? NexaColors.primaryGreen.withValues(alpha: 0.45) : _kBorder),
                            boxShadow: sel ? NexaShadows.card : null,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _avatarCircle(c.initials, c.avatarColor, 48),
                                  if (c.online)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: FadeTransition(
                                        opacity: Tween<double>(begin: 0.55, end: 1).animate(
                                          CurvedAnimation(parent: _pulseOnline, curve: Curves.easeInOut),
                                        ),
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF22C55E),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            c.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: NexaColors.darkNavy),
                                          ),
                                        ),
                                        Text(c.time, style: GoogleFonts.inter(fontSize: 11, color: _kMuted, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.metier,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      c.lastMsg,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(fontSize: 12.5, height: 1.3, color: const Color(0xFF475569)),
                                    ),
                                    if (c.unread != null && c.unread! > 0 && !_markedReadIds.contains(c.id)) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: NexaColors.primaryGreen,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${c.unread} messages non lus',
                                          style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildColumnChat({required bool showInfoButton}) {
    final c = _selected;
    if (c == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: _kBorder)),
            boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showClientProfileSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: _avatarCircle(c.initials, c.avatarColor, 44),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _showClientProfileSheet,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(c.name, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: NexaColors.darkNavy)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            c.metier,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 12, color: _kMuted, fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (c.online) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 4),
                                Text('En ligne', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: _showVideoCallDialog,
                style: IconButton.styleFrom(backgroundColor: const Color(0xFFE8EAF6)),
                icon: const Icon(Icons.videocam_outlined, color: NexaColors.darkNavy),
              ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                onPressed: _showAttachmentPicker,
                style: IconButton.styleFrom(backgroundColor: const Color(0xFFE8F5E9)),
                icon: const Icon(Icons.attach_file_rounded, color: NexaColors.primaryGreen),
              ),
              if (showInfoButton)
                IconButton.filledTonal(
                  onPressed: _openClientPanelDrawer,
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9)),
                  icon: const Icon(Icons.info_outline_rounded, color: NexaColors.darkNavy),
                ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFFAFBFC),
            child: ListView.builder(
              controller: _scrollChat,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              itemCount: _currentThread.length,
              itemBuilder: (context, i) {
                final m = _currentThread[i];
                return _buildBubble(m, i, c.name);
              },
            ),
          ),
        ),
        _buildComposer(),
      ],
    );
  }

  Widget _buildBubble(_SecureChatMsg m, int index, String contactName) {
    final isClient = m.fromClient;
    final clientLabel = contactName.split(' ').first;

    if (m.kind == _SecureChatMsgKind.attachment && !isClient) {
      return _buildAttachmentBubble(m, index, alignRight: true);
    }
    if (m.kind == _SecureChatMsgKind.voice && !isClient) {
      return _buildVoiceBubble(m, index);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + (index % 4) * 30),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Align(
          alignment: isClient ? Alignment.centerLeft : Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: isClient ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isClient ? Colors.white : NexaColors.primaryGreen,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isClient ? 4 : 18),
                      bottomRight: Radius.circular(isClient ? 18 : 4),
                    ),
                    border: Border.all(color: isClient ? _kBorder : Colors.transparent),
                    boxShadow: isClient ? NexaShadows.card : [BoxShadow(color: NexaColors.primaryGreen.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: Text(
                    isClient ? '$clientLabel :\n${m.text}' : m.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.45,
                      color: isClient ? const Color(0xFF1E293B) : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: isClient ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    Text(m.time, style: GoogleFonts.inter(fontSize: 11, color: _kMuted, fontWeight: FontWeight.w500)),
                    if (!isClient && m.read) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.done_all_rounded, size: 15, color: isClient ? NexaColors.primaryGreen.withValues(alpha: 0.85) : Colors.white70),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentBubble(_SecureChatMsg m, int index, {required bool alignRight}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 200 + (index % 4) * 25),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Align(
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: NexaColors.primaryGreen,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: NexaColors.primaryGreen.withValues(alpha: 0.22), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_file_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          m.text,
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(m.time, style: GoogleFonts.inter(fontSize: 11, color: _kMuted, fontWeight: FontWeight.w500)),
                    if (m.read) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.done_all_rounded, size: 15, color: NexaColors.primaryGreen),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceBubble(_SecureChatMsg m, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 200 + (index % 4) * 25),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: NexaColors.greenGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: NexaColors.primaryGreen.withValues(alpha: 0.28), blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.graphic_eq_rounded, color: Colors.white.withValues(alpha: 0.95), size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Message vocal', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                          Text('${m.voiceDurationSec}s', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _toast('Lecture du message vocal (démo)'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(m.time, style: GoogleFonts.inter(fontSize: 11, color: _kMuted, fontWeight: FontWeight.w500)),
                    if (m.read) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.done_all_rounded, size: 15, color: NexaColors.primaryGreen.withValues(alpha: 0.85)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_recordingVoice)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFFF1F2),
            child: Row(
              children: [
                Icon(Icons.fiber_manual_record_rounded, color: Colors.red.shade600, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Enregistrement… ${_recordElapsed}s — appuyez sur le micro pour envoyer',
                    style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFFB91C1C)),
                  ),
                ),
              ],
            ),
          ),
        Container(
      padding: EdgeInsets.fromLTRB(14, 10, 14, 14 + MediaQuery.paddingOf(context).bottom * 0.02),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton.filledTonal(
            onPressed: _showEmojiPicker,
            style: IconButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9)),
            icon: const Icon(Icons.emoji_emotions_outlined, color: Color(0xFF475569)),
          ),
          IconButton.filledTonal(
            onPressed: _promptAttachmentName,
            style: IconButton.styleFrom(backgroundColor: const Color(0xFFE8F5E9)),
            icon: const Icon(Icons.upload_file_rounded, color: NexaColors.primaryGreen),
          ),
          IconButton.filledTonal(
            onPressed: _toggleVoiceRecord,
            style: IconButton.styleFrom(
              backgroundColor: _recordingVoice ? const Color(0xFFFFE4E6) : const Color(0xFFF1F5F9),
            ),
            icon: Icon(
              _recordingVoice ? Icons.stop_circle_outlined : Icons.mic_none_rounded,
              color: _recordingVoice ? const Color(0xFFB91C1C) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _composer,
              focusNode: _composerFocus,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Écrire un message…',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                filled: true,
                fillColor: _kSurface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: NexaColors.primaryGreen.withValues(alpha: 0.5), width: 1.2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _sendMessage,
            style: FilledButton.styleFrom(
              backgroundColor: NexaColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Envoyer', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(width: 6),
                const Icon(Icons.send_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
        ),
      ],
    );
  }

  Widget _buildColumnClient({ScrollController? scroll}) {
    final c = _selected;
    if (c == null) return const SizedBox.shrink();

    final isAhmed = c.id == 'ahmed';
    final budget = isAhmed ? '15 000 DH' : '—';
    final secteur = isAhmed ? 'E-commerce' : '—';
    final deadline = isAhmed ? '3 semaines' : '—';
    final projets = isAhmed ? '12' : '5';
    final note = isAhmed ? '4,9' : '4,7';

    final body = SingleChildScrollView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showClientProfileSheet,
                    borderRadius: BorderRadius.circular(40),
                    child: _avatarCircle(c.initials, c.avatarColor, 72),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap: _showClientProfileSheet,
                        child: Text(
                          c.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: NexaColors.darkNavy),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.verified_rounded, color: NexaColors.primaryGreen, size: 22),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Casablanca, Maroc', style: GoogleFonts.inter(color: _kMuted, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _pill(Icons.star_rounded, NexaColors.starGold, note, 'Note'),
                    const SizedBox(width: 10),
                    _pill(Icons.work_outline_rounded, NexaColors.darkNavy, projets, 'Projets'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Informations projet', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
          const SizedBox(height: 10),
          _infoCard(children: [
            _infoRow('Budget', budget),
            _infoRow('Secteur', secteur),
            _infoRow('Deadline', deadline),
          ]),
          const SizedBox(height: 18),
          Text('Fichiers partagés', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
          const SizedBox(height: 10),
          _infoCard(
            children: [
              _fileRow(Icons.picture_as_pdf_rounded, const Color(0xFFB91C1C), 'cahier_des_charges.pdf'),
              const Divider(height: 20),
              _fileRow(Icons.layers_outlined, const Color(0xFF7C4DFF), 'maquette.fig'),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _showClientProfileSheet,
            style: OutlinedButton.styleFrom(
              foregroundColor: NexaColors.darkNavy,
              side: const BorderSide(color: _kBorder),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.person_search_rounded, size: 20),
            label: Text('Voir profil', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _showDevisDialog,
            style: FilledButton.styleFrom(
              backgroundColor: NexaColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.request_quote_outlined, size: 20),
            label: Text('Envoyer devis', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: _showMeetingPicker,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE8EAF6),
              foregroundColor: NexaColors.darkNavy,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.event_available_outlined, size: 20),
            label: Text('Planifier réunion', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (scroll != null) return body;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: _kBorder)),
        color: Colors.white,
      ),
      child: body,
    );
  }

  Widget _pill(IconData icon, Color iconColor, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: NexaColors.darkNavy)),
              Text(label, style: GoogleFonts.inter(fontSize: 10, color: _kMuted, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: NexaShadows.card,
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(k, style: GoogleFonts.inter(color: _kMuted, fontSize: 12.5, fontWeight: FontWeight.w600))),
          Text(v, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: NexaColors.darkNavy)),
        ],
      ),
    );
  }

  Widget _fileRow(IconData icon, Color c, String name) {
    return InkWell(
      onTap: () => _openSharedFile(name),
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Icon(icon, color: c, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13))),
          const Icon(Icons.download_outlined, size: 18, color: _kMuted),
        ],
      ),
    );
  }

  Widget _avatarCircle(String initials, Color bg, double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [BoxShadow(color: bg.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Text(
        initials,
        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.32),
      ),
    );
  }
}
