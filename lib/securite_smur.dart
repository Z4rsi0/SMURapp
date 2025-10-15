import 'package:flutter/material.dart';

class SecuriteSmurScreen extends StatelessWidget {
  const SecuriteSmurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sécurité SMUR"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(child: Text("À venir")),
    );
  }
}
