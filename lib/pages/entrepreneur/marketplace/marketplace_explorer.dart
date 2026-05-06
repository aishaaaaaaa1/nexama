import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../../theme/app_theme.dart';
import '../../../config/api_config.dart';
import '../../../services/api_service.dart';
import './service_detail_page.dart';

class MarketplaceExplorer extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MarketplaceExplorer({super.key, this.userData});

  @override
  State<MarketplaceExplorer> createState() => _MarketplaceExplorerState();
}

class _MarketplaceExplorerState extends State<MarketplaceExplorer> {
  bool _isLoading = true;
  List<dynamic> _services = [];
  String _selectedCategory = 'Tout';
  final List<String> _categories = ['Tout', 'Design', 'Développement', 'Marketing', 'Comptabilité', 'Juridique'];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    try {
      String path = '/api/marketplace/services';
      if (_selectedCategory != 'Tout') path += '?categorie=$_selectedCategory';
      
      final response = await ApiService.get(ApiConfig.uri(path));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _services = json.decode(response.body);
          _isLoading = false;
        });
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
        _buildFilters(),
        const SizedBox(height: 24),
        _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty 
            ? _buildEmptyState()
            : _buildServiceGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Marketplace B2B', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
        const SizedBox(height: 4),
        Text('Trouvez les meilleurs prestataires pour votre projet.', style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return FilterChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (val) {
              setState(() => _selectedCategory = cat);
              _fetchServices();
            },
            selectedColor: NexaColors.primaryGreen.withOpacity(0.2),
            checkmarkColor: NexaColors.primaryGreen,
            labelStyle: TextStyle(
              color: isSelected ? NexaColors.primaryGreen : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ServiceDetailPage(service: service, userData: widget.userData))
          ),
          child: _buildServiceCard(service),
        );
      },
    );
  }

  Widget _buildServiceCard(dynamic service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/300x200'),
                fit: BoxFit.cover
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 10, backgroundImage: NetworkImage(service['prestataire']['avatar_url'] ?? '')),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        service['prestataire']['nom_complet'],
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  service['titre'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text('${service['prestataire']['prestataire_profile']['score_reputation']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('À partir de', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${service['prix_basique']} MAD',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: NexaColors.primaryGreen, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Aucun service trouvé dans cette catégorie.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
