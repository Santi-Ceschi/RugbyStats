import 'package:flutter/material.dart';
import 'models/partido.dart';
import 'widgets/partido_card.dart';
import 'widgets/panel_filtrado.dart'; // Asegúrate de que este sea el nombre correcto del archivo

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variables para el estado del filtro
  bool _isFilterExpanded = false;
  String? _selectedDivision;
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();

  final List<String> _divisions = ['Primera', 'Intermedia', 'Pre-Intermedia'];

  // Mock data for now
  final List<Partido> _partidos = [
    Partido(
      idPartido: 1,
      categoria: Categoria.preIntermedia,
      equipoVisitante: 'uni',
      equipoLocal: 'rival',
      estadoPartido: 'Finalizado',
      fecha: DateTime(2026, 6, 15).toIso8601String(),
      puntosLocal: 60,
      puntosVisitante: 5,
      resultado: 'Victoria',
      torneo: 'Torneo Local',
      division: 'Primera',
    ), // Asegúrate de incluir los campos que faltendivision: 'Primera'),
    Partido(
      idPartido: 2,
      categoria: Categoria.intermedia,
      equipoVisitante: 'uni',
      equipoLocal: 'rival',
      estadoPartido: 'Finalizado',
      fecha: DateTime(2026, 6, 15).toIso8601String(),
      puntosLocal: 20,
      puntosVisitante: 10,
      resultado: 'Victoria',
      torneo: 'Torneo Local',
      division: 'Primera',
    ),
    Partido(
      idPartido: 3,
      categoria: Categoria.primera,
      equipoVisitante: 'uni',
      equipoLocal: 'rival',
      estadoPartido: 'Finalizado',
      fecha: DateTime(2026, 6, 15).toIso8601String(),
      puntosLocal: 46,
      puntosVisitante: 30,
      resultado: 'Victoria',
      torneo: 'Torneo Local',
      division: 'Primera',
    ),
  ];

  @override
  void dispose() {
    _dateFromController.dispose();
    _dateToController.dispose();
    super.dispose();
  }

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
            Text(
              'RugbyStats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'Alma Juniors Rugby',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionButtons(),

            // PANEL DE FILTRADO (Ahora correctamente integrado en la columna)
            Visibility(
              visible: _isFilterExpanded,
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: FilterPanel(
                  dateFromController: _dateFromController,
                  dateToController: _dateToController,
                  selectedDivision: _selectedDivision,
                  divisions: _divisions,
                  onDivisionChanged: (val) =>
                      setState(() => _selectedDivision = val),
                  onApply: () {
                    /* Lógica de filtrado aquí */
                  },
                  onClear: () => setState(() {
                    _selectedDivision = null;
                    _dateFromController.clear();
                    _dateToController.clear();
                  }),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'ÚLTIMOS PARTIDOS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _partidos.isEmpty
                  ? const Center(
                      child: Text(
                        'Aún no hay partidos registrados',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'INICIO',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: 'EN VIVO'),
        ],
        selectedItemColor: Colors.black,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('+ INICIAR PARTIDO'),
          ),
        ),
        const SizedBox(height: 12),
        // Botón que alterna la visibilidad del panel
        // En tu método _buildActionButtons()
        OutlinedButton(
          onPressed: () =>
              setState(() => _isFilterExpanded = !_isFilterExpanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.filter_list),
              Text(
                _isFilterExpanded
                    ? ' CERRAR FILTROS '
                    : ' CONSULTAR MÁS PARTIDOS ',
              ),
              Icon(
                _isFilterExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.backup_outlined),
              Text(' REALIZAR BACKUP '),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ],
    );
  }
}
