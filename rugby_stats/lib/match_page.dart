import 'package:flutter/material.dart';

class MatchPage extends StatelessWidget {
  final int partidoId;

  const MatchPage({super.key, required this.partidoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partido en Curso'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_rugby, size: 64, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'Cancha / Cronómetro',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Partido ID: $partidoId',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Vuelve al Home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('VOLVER AL INICIO'),
            ),
          ],
        ),
      ),
    );
  }
}
