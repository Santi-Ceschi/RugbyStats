import 'package:flutter/material.dart';
import 'models/partido.dart';
import 'widgets/partido_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mock data for now
  final List<Partido> _partidos = [
    Partido(id: '1', categoria: Categoria.preIntermedia, oponente: 'uni', fecha: DateTime(2026, 6, 15), puntos_local: 60, puntos_visitante: 5, resultado: 'Victoria'),
    Partido(id: '2', categoria: Categoria.intermedia, oponente: 'uni', fecha: DateTime(2026, 6, 15), puntos_local: 20, puntos_visitante: 10, resultado: 'Victoria'),
    Partido(id: '3', categoria: Categoria.primera, oponente: 'uni', fecha: DateTime(2026, 6, 15), puntos_local: 46, puntos_visitante: 30, resultado: 'Victoria'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RugbyStats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            Text('Alma Juniors Rugby', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionButtons(),
            const SizedBox(height: 24),
            const Text('ÚLTIMOS PARTIDOS', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: _partidos.isEmpty
                  ? const Center(child: Text('Aún no hay partidos registrados', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _partidos.length,
                      itemBuilder: (context, index) => PartidoCard(
                        partido: _partidos[index],
                        onEdit: () {},
                        onDelete: () {
                          setState(() => _partidos.removeAt(index));
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'INICIO'),
          BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: 'EN VIVO'),
        ],
        selectedItemColor: Colors.black,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(width: double.infinity, height: 45, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), child: const Text('+ INICIAR PARTIDO'))),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: () {}, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.filter_list), Text(' CONSULTAR MÁS PARTIDOS '), Icon(Icons.arrow_drop_down)])),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: () {}, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.backup_outlined), Text(' REALIZAR BACKUP '), Icon(Icons.arrow_drop_down)])),
      ],
    );
  }
}
