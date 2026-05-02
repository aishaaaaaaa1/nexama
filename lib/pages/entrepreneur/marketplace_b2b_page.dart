import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../investisseur/messages_page.dart'; // Pour réutiliser la logique de messagerie si besoin

class MarketplaceB2BPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MarketplaceB2BPage({super.key, this.userData});

  @override
  State<MarketplaceB2BPage> createState() => _MarketplaceB2BPageState();
}

class _MarketplaceB2BPageState extends State<MarketplaceB2BPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _services = [];
  List<dynamic> _myOrders = [];
  
  String _selectedCategory = 'Tous';
  String? _filterVille;
  double? _filterPrixMax;
  bool _filterDispo = false;
  double? _filterRatingMin;

  final List<String> _categories = ['Tous', 'Design', 'Développement', 'Marketing', 'Légal', 'Comptabilité'];
  final List<String> _villes = ['Toutes', 'Casablanca', 'Rabat', 'Marrakech', 'Agadir', 'Tanger'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchServices();
    _loadMockOrders();
  }

  void _loadMockOrders() {
    _myOrders = [
      {'id': 'cmd_001', 'titre': 'Création Site Vitrine', 'prestataire': 'Agence Digital Pro', 'montant': 5000, 'statut': 'escrow', 'date': '12 Mai 2024'},
      {'id': 'cmd_002', 'titre': 'Audit SEO', 'prestataire': 'SEO Master', 'montant': 1500, 'statut': 'livree', 'date': '05 Mai 2024'},
    ];
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    try {
      String url = '/api/entrepreneur/marketplace/services?';
      if (_selectedCategory != 'Tous') url += 'categorie=$_selectedCategory&';
      if (_filterVille != null && _filterVille != 'Toutes') url += 'ville=$_filterVille&';
      if (_filterPrixMax != null) url += 'prix_max=${_filterPrixMax!.toInt()}&';
      if (_filterDispo) url += 'dispo=true&';
      if (_filterRatingMin != null) url += 'rating_min=$_filterRatingMin&';

      final response = await ApiService.get(ApiConfig.uri(url));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _services = json.decode(response.body);
          _isLoading = false;
        });
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
        _buildHeader(),
        const SizedBox(height: 24),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: NexaColors.primaryGreen,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: NexaColors.primaryGreen,
          tabs: [
            const Tab(text: 'Découvrir les services'),
            Tab(text: 'Mes commandes (${_myOrders.length})'),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDiscoveryTab(),
              _buildOrdersTab(),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marketplace B2B', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            const Text('Accélérez votre croissance avec des prestataires qualifiés.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ],
        ),
        Row(
          children: [
            Container(
              width: 300,
              height: 45,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const TextField(
                decoration: InputDecoration(hintText: 'Rechercher un service...', prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)), border: InputBorder.none, contentPadding: EdgeInsets.only(top: 10)),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _showFiltersDialog,
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Filtres'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.darkNavy, foregroundColor: Colors.white, minimumSize: const Size(100, 45)),
            )
          ],
        )
      ],
    );
  }

  Widget _buildDiscoveryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((c) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(c),
                selected: _selectedCategory == c,
                onSelected: (val) { if(val) { setState(() => _selectedCategory = c); _fetchServices(); } },
                selectedColor: NexaColors.primaryGreen.withOpacity(0.2),
                labelStyle: TextStyle(color: _selectedCategory == c ? NexaColors.primaryGreen : Colors.grey[700], fontWeight: _selectedCategory == c ? FontWeight.bold : FontWeight.normal),
              ),
            )).toList(),
          ),
        ),
        if (_filterVille != null || _filterPrixMax != null || _filterDispo || _filterRatingMin != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Wrap(spacing: 8, children: [
              if (_filterVille != null && _filterVille != 'Toutes') _filterChip('Ville: $_filterVille', () { _filterVille = null; _fetchServices(); }),
              if (_filterPrixMax != null) _filterChip('Max: ${_filterPrixMax!.toInt()} MAD', () { _filterPrixMax = null; _fetchServices(); }),
              if (_filterDispo) _filterChip('Dispo immédiate', () { _filterDispo = false; _fetchServices(); }),
              if (_filterRatingMin != null) _filterChip('Note > $_filterRatingMin', () { _filterRatingMin = null; _fetchServices(); }),
              TextButton(onPressed: () { setState(() { _filterVille = null; _filterPrixMax = null; _filterDispo = false; _filterRatingMin = null; }); _fetchServices(); }, child: const Text('Réinitialiser', style: TextStyle(color: Colors.red, fontSize: 12))),
            ]),
          ),
        const SizedBox(height: 24),
        if (_isLoading) const Center(child: CircularProgressIndicator())
        else if (_services.isEmpty) const Center(child: Text("Aucun service trouvé."))
        else Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 0.82),
            itemCount: _services.length,
            itemBuilder: (context, index) => _buildServiceCard(_services[index]),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) => Chip(label: Text(label, style: const TextStyle(fontSize: 11)), deleteIcon: const Icon(Icons.close, size: 14), onDeleted: onRemove, backgroundColor: NexaColors.primaryGreen.withOpacity(0.1), side: BorderSide.none);

  Widget _buildServiceCard(dynamic service) {
    return GestureDetector(
      onTap: () => _showServiceDetails(service),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: const BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
              child: Center(child: Icon(Icons.image_outlined, size: 40, color: Colors.grey[400])),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: NexaColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(service['categorie']?.toString() ?? 'Catégorie', style: const TextStyle(color: NexaColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold))),
                      Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), const SizedBox(width: 4), Text('${service['note']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text(' (${service['avis_count']})', style: const TextStyle(color: Colors.grey, fontSize: 10))]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(service['titre']?.toString() ?? 'Titre non disponible', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(radius: 10, backgroundColor: Colors.blue.withOpacity(0.1), child: Text((service['nom_prestataire']?.toString().isNotEmpty == true) ? service['nom_prestataire'][0] : 'P', style: const TextStyle(fontSize: 10, color: Colors.blue))),
                      const SizedBox(width: 8),
                      Expanded(child: Text(service['nom_prestataire']?.toString() ?? 'Prestataire', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('À partir de', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      Text('${service['prix']} MAD', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: NexaColors.darkNavy)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (_myOrders.isEmpty) return const Center(child: Text("Vous n'avez passé aucune commande."));
    return ListView.builder(
      itemCount: _myOrders.length,
      itemBuilder: (ctx, i) {
        final order = _myOrders[i];
        bool isEscrow = order['statut'] == 'escrow';
        bool isLivree = order['statut'] == 'livree';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(order['titre']?.toString() ?? 'Commande sans titre', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: isEscrow ? Colors.orange.withOpacity(0.1) : (isLivree ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1)), borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            children: [
                              Icon(isEscrow ? Icons.lock_outline : (isLivree ? Icons.local_shipping : Icons.check_circle), size: 12, color: isEscrow ? Colors.orange : (isLivree ? Colors.blue : Colors.green)),
                              const SizedBox(width: 4),
                              Text(isEscrow ? 'Fonds en Séquestre' : (isLivree ? 'Livrée' : 'Terminée'), style: TextStyle(color: isEscrow ? Colors.orange : (isLivree ? Colors.blue : Colors.green), fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Prestataire: ${order['prestataire']} • Commandé le ${order['date']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${order['montant']} MAD', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (isEscrow || isLivree) 
                    ElevatedButton(
                      onPressed: () => _validateDelivery(order),
                      style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
                      child: const Text('Valider la livraison'),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _showLeaveReviewDialog(order), 
                      icon: const Icon(Icons.star_border, size: 16), 
                      label: const Text('Laisser un avis')
                    )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _showLeaveReviewDialog(dynamic order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Évaluer ${order['prestataire']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Comment s\'est passée votre prestation ?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => IconButton(icon: const Icon(Icons.star_border, color: Colors.amber, size: 32), onPressed: () {})),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(hintText: 'Partagez votre expérience...', border: OutlineInputBorder()),
              maxLines: 3,
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Merci pour votre avis !'), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Soumettre'),
          )
        ],
      ),
    );
  }

  void _showFiltersDialog() {
    String? tempVille = _filterVille;
    double? tempPrix = _filterPrixMax;
    bool tempDispo = _filterDispo;
    double? tempRating = _filterRatingMin;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (context, setDialogState) {
      return AlertDialog(
        title: Text('Filtres Multicritères', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            value: tempVille ?? 'Toutes', decoration: const InputDecoration(labelText: 'Ville', border: OutlineInputBorder()),
            items: _villes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => tempVille = v,
          ),
          const SizedBox(height: 16),
          Text('Prix Maximum: ${tempPrix != null ? '${tempPrix!.toInt()} MAD' : 'Non défini'}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(value: tempPrix ?? 10000, min: 100, max: 20000, divisions: 100, activeColor: NexaColors.primaryGreen, onChanged: (v) => setDialogState(() => tempPrix = v)),
          const SizedBox(height: 16),
          SwitchListTile(title: const Text('Disponibilité immédiate'), value: tempDispo, activeColor: NexaColors.primaryGreen, onChanged: (v) => setDialogState(() => tempDispo = v)),
          const SizedBox(height: 16),
          DropdownButtonFormField<double>(
            value: tempRating, decoration: const InputDecoration(labelText: 'Note minimum', border: OutlineInputBorder()),
            items: [null, 4.0, 4.5, 4.8].map((r) => DropdownMenuItem(value: r, child: Text(r == null ? 'Peu importe' : 'Au moins $r étoiles'))).toList(), onChanged: (v) => tempRating = v,
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(onPressed: () {
            setState(() { _filterVille = tempVille; _filterPrixMax = tempPrix; _filterDispo = tempDispo; _filterRatingMin = tempRating; });
            Navigator.pop(ctx);
            _fetchServices();
          }, style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white), child: const Text('Appliquer')),
        ],
      );
    }));
  }

  void _showServiceDetails(dynamic service) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: 200, color: const Color(0xFFF1F5F9), child: Center(child: Icon(Icons.image, size: 60, color: Colors.grey[400]))),
              Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: NexaColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(service['categorie']?.toString() ?? 'Catégorie', style: const TextStyle(color: NexaColors.primaryGreen, fontWeight: FontWeight.bold))),
                  Row(children: [const Icon(Icons.star, color: Colors.amber), const SizedBox(width: 4), Text('${service['note']} (${service['avis_count']} avis)', style: const TextStyle(fontWeight: FontWeight.bold))]),
                ]),
                const SizedBox(height: 16),
                Text(service['titre']?.toString() ?? 'Titre non disponible', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const SizedBox(height: 24),
                // Profil Prestataire
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)), child: Row(children: [
                  CircleAvatar(radius: 24, backgroundColor: Colors.blue.withOpacity(0.1), child: Text((service['nom_prestataire']?.toString().isNotEmpty == true) ? service['nom_prestataire'][0] : 'P', style: const TextStyle(fontSize: 20, color: Colors.blue))),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(service['nom_prestataire']?.toString() ?? 'Prestataire', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(service['ville']?.toString() ?? 'Ville inconnue', style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(width: 12), const Icon(Icons.verified, size: 14, color: Colors.blue), const SizedBox(width: 4), const Text('Vérifié', style: TextStyle(color: Colors.blue, fontSize: 12))])
                  ])),
                  IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ouverture messagerie directe...'))), icon: const Icon(Icons.chat_bubble_outline, color: NexaColors.primaryGreen))
                ])),
                const SizedBox(height: 24),
                Text('Description', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text(service['description']?.toString() ?? 'Aucune description fournie.', style: const TextStyle(color: Color(0xFF64748B), height: 1.5)),
                const SizedBox(height: 24),
                Text('Portfolio & Certifications', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Projet 1')))),
                  const SizedBox(width: 12),
                  Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Projet 2')))),
                  const SizedBox(width: 12),
                  Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Certification DGI')))),
                ])
              ]))
            ]),
          ),
          // Footer
          Positioned(bottom: 0, left: 0, right: 0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), decoration: BoxDecoration(color: Colors.white, border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Prix total', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('${service['prix']} MAD', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            ]),
            ElevatedButton(
              onPressed: () { Navigator.pop(ctx); _showCheckoutDialog(service); },
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: const Text('Commander & Payer en ligne'),
            )
          ])))
        ],
      ),
    ));
  }

  void _showCheckoutDialog(dynamic service) {
    bool loading = false;
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => StatefulBuilder(builder: (context, setDialogState) {
      return AlertDialog(
        title: Row(children: [const Icon(Icons.lock, color: Colors.green), const SizedBox(width: 8), Text('Paiement Sécurisé', style: GoogleFonts.inter(fontWeight: FontWeight.bold))]),
        content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.withOpacity(0.3))), child: const Row(children: [Icon(Icons.info_outline, color: Colors.orange, size: 20), SizedBox(width: 12), Expanded(child: Text("Vos fonds seront conservés sous séquestre (Escrow) et ne seront transférés au prestataire qu'après validation de la livraison.", style: TextStyle(color: Colors.orange, fontSize: 12)))])),
          const SizedBox(height: 20),
          Text('Service : ${service['titre']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Montant à payer : ${service['prix']} MAD', style: const TextStyle(fontSize: 16, color: NexaColors.primaryGreen, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Simulation CMI / PayZone', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const TextField(decoration: InputDecoration(labelText: 'Numéro de carte', border: OutlineInputBorder(), prefixIcon: Icon(Icons.credit_card))),
          if (loading) const Padding(padding: EdgeInsets.only(top: 20), child: Center(child: CircularProgressIndicator())),
        ])),
        actions: [
          if (!loading) TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          if (!loading) ElevatedButton(
            onPressed: () async {
              setDialogState(() => loading = true);
              try {
                final response = await ApiService.post(ApiConfig.uri('/api/entrepreneur/marketplace/commandes'), headers: {'Content-Type': 'application/json'}, body: json.encode({'entrepreneur_id': widget.userData?['id'], 'service_id': service['id'], 'montant': service['prix'], 'methode_paiement': 'cmi'}));
                if (response.statusCode == 201) {
                  final newCmd = json.decode(response.body);
                  if (mounted) {
                    setState(() { _myOrders.insert(0, {'id': newCmd['id'], 'titre': service['titre'], 'prestataire': service['nom_prestataire'], 'montant': service['prix'], 'statut': newCmd['statut'], 'date': "À l'instant"}); _tabController.animateTo(1); });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paiement réussi. Fonds bloqués.'), backgroundColor: Colors.green));
                  }
                }
              } catch (e) {
                setDialogState(() => loading = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Payer et Bloquer les fonds'),
          )
        ],
      );
    }));
  }

  void _validateDelivery(dynamic order) async {
    try {
      final response = await ApiService.post(ApiConfig.uri('/api/entrepreneur/marketplace/commandes/${order['id']}/valider'), headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        setState(() => order['statut'] = 'terminee');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Livraison validée ! Les fonds ont été débloqués vers le prestataire.'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la validation'), backgroundColor: Colors.red));
    }
  }
}
