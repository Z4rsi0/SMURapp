import 'package:flutter/material.dart';

class ProtocolesScreen extends StatelessWidget {
  const ProtocolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Protocoles"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(child: Text("À venir")),
    );
  }
}
