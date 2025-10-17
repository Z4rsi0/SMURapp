import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models/pediatrie_model.dart';

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

Future<ParametresPediatriques> loadParametresPediatriques() async {
  final data = await rootBundle.loadString('assets/pediatrie.json');
  final jsonData = json.decode(data);
  return ParametresPediatriques.fromJson(jsonData);
}

class PediatrieScreen extends StatefulWidget {
  const PediatrieScreen({super.key});

  @override
  State<PediatrieScreen> createState() => _PediatrieScreenState();
}

class _PediatrieScreenState extends State<PediatrieScreen> {
  double weight = 10.0;
  int ageIndex = 8; // 1 an par défaut
  ParametresPediatriques? parametres;
  bool isLoading = true;
  final weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    weightController.text = weight.toStringAsFixed(1);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await loadParametresPediatriques();
      setState(() {
        parametres = data;
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

  void _updateWeight(String value) {
    final newWeight = double.tryParse(value);
    if (newWeight != null && newWeight > 0 && newWeight <= 100) {
      setState(() {
        weight = newWeight;
      });
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
        title: const Text("Paramètres Pédiatriques"),
        backgroundColor: Colors.purple.shade100,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildWeightPanel(),
                _buildAgeSlider(),
                Expanded(child: _buildParametresCards()),
              ],
            ),
    );
  }

  Widget _buildWeightPanel() {
    return Container(
      color: Colors.purple.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.monitor_weight, size: 24, color: Colors.purple),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.shade200, width: 2),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.purple.shade50,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Âge: ${agePoidsMap[ageIndex]['age']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                'Poids standard: ${agePoidsMap[ageIndex]['poids']} kg',
                style: TextStyle(color: Colors.purple.shade700, fontSize: 14),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
            ),
            child: Slider(
              value: ageIndex.toDouble(),
              min: 0,
              max: (agePoidsMap.length - 1).toDouble(),
              divisions: agePoidsMap.length - 1,
              activeColor: Colors.purple.shade600,
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

  Widget _buildParametresCards() {
    if (parametres == null) {
      return const Center(child: Text('Erreur de chargement des données'));
    }

    final tranche = parametres!.getTranchePourAge(ageIndex);
    if (tranche == null) {
      return const Center(child: Text('Aucune donnée pour cet âge'));
    }

    final valeurs = tranche.calculer(weight);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            icon: Icons.favorite,
            title: "Fréquence Cardiaque",
            value: "${valeurs.fcMin} - ${valeurs.fcMax} bpm",
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.monitor_heart,
            title: "PA Systolique",
            value: "> ${valeurs.pasMin} mmHg",
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.trending_up,
            title: "PA Moyenne",
            value: "> ${valeurs.pamMin} mmHg",
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.air,
            title: "Fréquence Respiratoire",
            value: "${valeurs.frMin} - ${valeurs.frMax} /min",
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.water_drop,
            title: "Volume Courant",
            value: "${valeurs.volumeCourant} mL (6 mL/kg)",
            color: Colors.cyan,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.cable,
            title: "Sonde d'Intubation",
            value: "Taille ${valeurs.tailleSonde}",
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.bolt,
            title: "Choc ACR (1er - 3ème)",
            value: "${valeurs.chocAcr1a3} J (4 J/kg)",
            color: Colors.amber,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.flash_on,
            title: "Choc ACR (≥ 4ème)",
            value: "${valeurs.chocAcr4Plus} J (8 J/kg)",
            color: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}