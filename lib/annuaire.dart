import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'models/annuaire_model.dart'; // À décommenter quand vous créerez le fichier

// TEMPORAIRE : Copiez les classes du fichier annuaire_model.dart ici
// ou créez le fichier models/annuaire_model.dart et décommentez l'import ci-dessus

// Chargement de l'annuaire depuis le JSON
Future<Annuaire> loadAnnuaire() async {
  final data = await rootBundle.loadString('assets/annuaire.json');
  final Map<String, dynamic> jsonData = json.decode(data);
  return Annuaire.fromJson(jsonData);
}

class AnnuaireScreen extends StatefulWidget {
  const AnnuaireScreen({super.key});

  @override
  State<AnnuaireScreen> createState() => _AnnuaireScreenState();
}

class _AnnuaireScreenState extends State<AnnuaireScreen> {
  bool isInterne = true;
  Annuaire? annuaire;
  bool isLoading = true;
  final searchController = TextEditingController();
  List<Service> filteredServices = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await loadAnnuaire();
      setState(() {
        annuaire = data;
        _updateFilteredServices();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  void _updateFilteredServices() {
    if (annuaire == null) return;
    
    List<Service> services = isInterne ? annuaire!.interne : annuaire!.externe;
    
    if (searchController.text.isEmpty) {
      filteredServices = services;
    } else {
      final query = searchController.text.toLowerCase();
      filteredServices = services.where((s) =>
        s.nom.toLowerCase().contains(query) ||
        (s.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
  }

  void _filterServices(String query) {
    setState(() {
      _updateFilteredServices();
    });
  }

  void _toggleMode(bool interne) {
    setState(() {
      isInterne = interne;
      _updateFilteredServices();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Annuaire"),
        backgroundColor: Colors.green.shade100,
      ),
      body: Column(
        children: [
          // Bandeau de sélection Interne/Externe
          _buildModeSelector(),
          
          // Barre de recherche
          _buildSearchBar(),
          
          // Liste des services
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildServicesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      color: Colors.green.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              'Interne',
              isInterne,
              Icons.business,
              () => _toggleMode(true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildModeButton(
              'Externe',
              !isInterne,
              Icons.public,
              () => _toggleMode(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    String label,
    bool isActive,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.green.shade600 : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: "Rechercher un service",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _filterServices('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: _filterServices,
      ),
    );
  }

  Widget _buildServicesList() {
    if (filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun service trouvé',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        final service = filteredServices[index];
        return ServiceCard(service: service);
      },
    );
  }
}

class ServiceCard extends StatefulWidget {
  final Service service;

  const ServiceCard({super.key, required this.service});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(
                Icons.phone_in_talk,
                color: Colors.green.shade700,
              ),
            ),
            title: Text(
              widget.service.nom,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: widget.service.description != null
                ? Text(
                    widget.service.description!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  )
                : null,
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.green.shade700,
            ),
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
          
          // Contacts (affichés quand étendu)
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                children: widget.service.contacts.map((contact) {
                  return ContactTile(
                    contact: contact,
                    key: ValueKey(contact.numero),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final Contact contact;

  const ContactTile({super.key, required this.contact});

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'mobile':
        return Icons.smartphone;
      case 'fax':
        return Icons.fax;
      case 'bip':
        return Icons.vibration;
      case 'fixe':
      default:
        return Icons.phone;
    }
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'mobile':
        return Colors.blue;
      case 'fax':
        return Colors.orange;
      case 'bip':
        return Colors.purple;
      case 'fixe':
      default:
        return Colors.green;
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    // Nettoyer le numéro (enlever espaces et autres caractères)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );
    
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible de passer l\'appel'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(contact.type);
    
    return InkWell(
      onTap: () => _makePhoneCall(context, contact.numero),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForType(contact.type),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (contact.label != null)
                    Text(
                      contact.label!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  Text(
                    contact.numero,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}