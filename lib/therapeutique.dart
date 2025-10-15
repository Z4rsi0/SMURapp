import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models/medicament_model.dart'; 

// Âge → Poids simplifié
final List<Map<String, dynamic>> agePoidsMap = [
  {'age': '-1 mois', 'poids': 2.0},
  {'age': '0 mois', 'poids': 3.0},
  {'age': '1 mois', 'poids': 4.0},
  {'age': '2 mois', 'poids': 5.0},
  {'age': '4 mois', 'poids': 6.0},
  {'age': '6 mois', 'poids': 7.0},
  {'age': '8 mois', 'poids': 8.0},
  {'age': '10 mois', 'poids': 9.0},
  {'age': '1 an', 'poids': 10.0},
  {'age': '1 an 6m', 'poids': 11.0},
  {'age': '2 ans', 'poids': 12.0},
  {'age': '3 ans', 'poids': 15.0},
  {'age': '4 ans', 'poids': 17.0},
  {'age': '5 ans', 'poids': 19.0},
  {'age': '6 ans', 'poids': 21.0},
  {'age': '7 ans', 'poids': 24.0},
  {'age': '8 ans', 'poids': 27.0},
  {'age': '9 ans', 'poids': 30.0},
  {'age': '10 ans', 'poids': 33.0},
  {'age': '11 ans', 'poids': 37.0},
  {'age': '12 ans', 'poids': 40.0},
];

// Chargement des médicaments depuis le JSON
Future<List<Medicament>> loadMedicaments() async {
  final data = await rootBundle.loadString('assets/medicaments.json');
  final List<dynamic> jsonList = json.decode(data);
  List<Medicament> meds = jsonList.map((json) => Medicament.fromJson(json)).toList();
  
  // Tri alphabétique
  meds.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
  
  return meds;
}

class TherapeutiqueScreen extends StatefulWidget {
  const TherapeutiqueScreen({super.key});

  @override
  State<TherapeutiqueScreen> createState() => _TherapeutiqueScreenState();
}

class _TherapeutiqueScreenState extends State<TherapeutiqueScreen> {
  bool isPediatric = false;
  double weight = 70.0;
  int ageIndex = 8; // 1 an par défaut
  List<Medicament> medicaments = [];
  List<Medicament> filteredMedicaments = [];
  final searchController = TextEditingController();
  final weightController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    weightController.text = weight.toStringAsFixed(1);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await loadMedicaments();
      setState(() {
        medicaments = data;
        filteredMedicaments = medicaments;
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

  void _filterMedicaments(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMedicaments = medicaments;
      } else {
        filteredMedicaments = medicaments
            .where((m) => m.nom.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleMode(bool pediatric) {
    setState(() {
      isPediatric = pediatric;
      if (!pediatric) {
        weight = 70.0;
        weightController.text = weight.toStringAsFixed(1);
      } else {
        weight = agePoidsMap[ageIndex]['poids'];
        weightController.text = weight.toStringAsFixed(1);
      }
    });
  }

  void _updateWeight(String value) {
    final newWeight = double.tryParse(value);
    if (newWeight != null && newWeight > 0 && newWeight <= 300) {
      setState(() {
        weight = newWeight;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thérapeutique"),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Column(
        children: [
          // Bandeau de configuration
          _buildConfigPanel(),
          
          // Slider d'âge (pédiatrie uniquement) - Version compacte
          if (isPediatric) _buildAgeSlider(),
          
          // Barre de recherche
          _buildSearchBar(),
          
          // Liste des médicaments
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMedicamentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigPanel() {
    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mode Adulte/Pédiatrique
          Row(
            children: [
              _buildModeButton('Adulte', !isPediatric, () => _toggleMode(false)),
              const SizedBox(width: 8),
              _buildModeButton('Pédiatrique', isPediatric, () => _toggleMode(true)),
            ],
          ),
          
          // Affichage et édition du poids
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.monitor_weight, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: _updateWeight,
                  ),
                ),
                const Text(
                  ' kg',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.blue.shade600 : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAgeSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.blue.shade50,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Âge: ${agePoidsMap[ageIndex]['age']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Poids: ${agePoidsMap[ageIndex]['poids']} kg',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
            ),
            child: Slider(
              value: ageIndex.toDouble(),
              min: 0,
              max: (agePoidsMap.length - 1).toDouble(),
              divisions: agePoidsMap.length - 1,
              activeColor: Colors.blue.shade600,
              onChanged: (val) {
                setState(() {
                  ageIndex = val.round();
                  weight = agePoidsMap[ageIndex]['poids'];
                  weightController.text = weight.toStringAsFixed(1);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: "Rechercher un médicament",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _filterMedicaments('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: _filterMedicaments,
      ),
    );
  }

  Widget _buildMedicamentsList() {
    if (filteredMedicaments.isEmpty) {
      return const Center(
        child: Text('Aucun médicament trouvé'),
      );
    }

    return ListView.builder(
      itemCount: filteredMedicaments.length,
      itemBuilder: (context, index) {
        final med = filteredMedicaments[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.medication, color: Colors.blue.shade700),
            ),
            title: Text(
              med.nomComplet,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              med.galenique,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MedicamentDetailScreen(
                  medicament: med,
                  isPediatric: isPediatric,
                  weight: weight,
                  ageIndex: ageIndex,
                  onModeChanged: (newMode, newWeight, newAgeIndex) {
                    setState(() {
                      isPediatric = newMode;
                      weight = newWeight;
                      ageIndex = newAgeIndex;
                      weightController.text = weight.toStringAsFixed(1);
                    });
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MedicamentDetailScreen extends StatefulWidget {
  final Medicament medicament;
  final bool isPediatric;
  final double weight;
  final int ageIndex;
  final Function(bool, double, int) onModeChanged;

  const MedicamentDetailScreen({
    super.key,
    required this.medicament,
    required this.isPediatric,
    required this.weight,
    required this.ageIndex,
    required this.onModeChanged,
  });

  @override
  State<MedicamentDetailScreen> createState() => _MedicamentDetailScreenState();
}

class _MedicamentDetailScreenState extends State<MedicamentDetailScreen> {
  late bool isPediatric;
  late double weight;
  late int ageIndex;
  late TextEditingController weightController;

  @override
  void initState() {
    super.initState();
    isPediatric = widget.isPediatric;
    weight = widget.weight;
    ageIndex = widget.ageIndex;
    weightController = TextEditingController(text: weight.toStringAsFixed(1));
  }

  void _toggleMode(bool pediatric) {
    setState(() {
      isPediatric = pediatric;
      if (!pediatric) {
        weight = 70.0;
      } else {
        weight = agePoidsMap[ageIndex]['poids'];
      }
      weightController.text = weight.toStringAsFixed(1);
    });
    widget.onModeChanged(isPediatric, weight, ageIndex);
  }

  void _updateWeight(String value) {
    final newWeight = double.tryParse(value);
    if (newWeight != null && newWeight > 0 && newWeight <= 300) {
      setState(() {
        weight = newWeight;
      });
      widget.onModeChanged(isPediatric, weight, ageIndex);
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicament.nomComplet),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Column(
        children: [
          // Bandeau de configuration (persistant)
          _buildConfigPanel(),
          if (isPediatric) _buildAgeSlider(),
          
          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Galénique
                    _buildSection(
                      icon: Icons.medical_services,
                      title: "Galénique",
                      content: widget.medicament.galenique,
                      color: Colors.blue,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Indications et posologies
                    ...widget.medicament.indications.map((indication) =>
                        _buildIndicationSection(context, indication)),
                    
                    const SizedBox(height: 16),
                    
                    // Contre-indications
                    _buildSection(
                      icon: Icons.warning,
                      title: "Contre-indications",
                      content: widget.medicament.contreIndications,
                      color: Colors.red,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Surdosage
                    _buildSection(
                      icon: Icons.info,
                      title: "Surdosage",
                      content: widget.medicament.surdosage,
                      color: Colors.orange,
                    ),
                    
                    if (widget.medicament.aSavoir != null) ...[
                      const SizedBox(height: 16),
                      _buildSection(
                        icon: Icons.lightbulb,
                        title: "À savoir",
                        content: widget.medicament.aSavoir!,
                        color: Colors.green,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigPanel() {
    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildModeButton('Adulte', !isPediatric, () => _toggleMode(false)),
              const SizedBox(width: 8),
              _buildModeButton('Pédiatrique', isPediatric, () => _toggleMode(true)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.monitor_weight, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: _updateWeight,
                  ),
                ),
                const Text(
                  ' kg',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.blue.shade600 : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAgeSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.blue.shade50,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Âge: ${agePoidsMap[ageIndex]['age']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Poids: ${agePoidsMap[ageIndex]['poids']} kg',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
            ),
            child: Slider(
              value: ageIndex.toDouble(),
              min: 0,
              max: (agePoidsMap.length - 1).toDouble(),
              divisions: agePoidsMap.length - 1,
              activeColor: Colors.blue.shade600,
              onChanged: (val) {
                setState(() {
                  ageIndex = val.round();
                  weight = agePoidsMap[ageIndex]['poids'];
                  weightController.text = weight.toStringAsFixed(1);
                });
                widget.onModeChanged(isPediatric, weight, ageIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildIndicationSection(BuildContext context, Indication indication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_hospital, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  indication.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ...indication.posologies.map((posologie) =>
              _buildPosologieCard(posologie)),
        ],
      ),
    );
  }

  Widget _buildPosologieCard(Posologie posologie) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  posologie.voie,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          if (isPediatric && posologie.pediatrie != null)
            _buildPosologiePediatrique(posologie.pediatrie!)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adulte:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(posologie.adultes!),
              ],
            ),
          
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.science, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    posologie.preparation,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosologiePediatrique(List<PosologiePediatrique> pediatrie) {
    // Trouver la posologie applicable
    PosologiePediatrique? posologieApplicable;
    
    for (var p in pediatrie) {
      if (p.appliqueAAge(ageIndex) && p.appliqueAPoids(weight)) {
        posologieApplicable = p;
        break;
      }
    }
    
    posologieApplicable ??= pediatrie.first;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.child_care, size: 16, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Pédiatrie:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(posologieApplicable.calculerDose(weight)),
        ],
      ),
    );
  }
}