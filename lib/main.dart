import 'package:flutter/material.dart';
import 'therapeutique.dart';
import 'protocoles.dart';
import 'securite_smur.dart';
import 'annuaire.dart';
import 'scores.dart';

void main() {
  runApp(const MedApp());
}

class MedApp extends StatelessWidget {
  const MedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Médicale SMUR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meloin Protocoles")),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _buildNavButton(context, "Protocoles", Icons.description, const ProtocolesScreen()),
                _buildNavButton(context, "Thérapeutique", Icons.medical_information, const TherapeutiqueScreen()),
                _buildNavButton(context, "Sécurité SMUR", Icons.security, const SecuriteSmurScreen()),
                _buildNavButton(context, "Annuaire", Icons.phone, const AnnuaireScreen()),
                _buildNavButton(context, "Scores", Icons.calculate, const ScoresScreen())
              ],
            )
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Créé Par Alexandre AMIOT - En cours de production',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          )
        ]
      )
      
    );
  }

  Widget _buildNavButton(BuildContext context, String title, IconData icon,
      Widget destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue.shade800),
            const SizedBox(height: 10),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
