import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'models/partido.dart';
import 'widgets/partido_card.dart';
import 'widgets/panel_filtrado.dart';
import 'services/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    ),
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

  // --- LÓGICA DE BACKUP ---
  Future<void> _exportarDatos() async {
    final jsonString = await DatabaseHelper.instance.exportDatabaseToJson();
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/backup_rugby.json');
    await file.writeAsString(jsonString);
    
    // Corregido: uso de Share.shareXFiles
    await Share.shareXFiles([XFile(file.path)], text: 'Backup de RugbyStats');
  }

  Future<void> _importarDatos() async {
    // Corregido: FilePickerResult es la clase correcta
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String jsonString = await file.readAsString();
      await DatabaseHelper.instance.importDatabaseFromJson(jsonString);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup importado exitosamente')));
      }
    }
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
        ExpansionTile(
          title: const Text('Consultar más partidos'),
          leading: const Icon(Icons.filter_list),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilterPanel(
                dateFromController: _dateFromController,
                dateToController: _dateToController,
                selectedDivision: _selectedDivision,
                divisions: _divisions,
                onDivisionChanged: (val) =>
                    setState(() => _selectedDivision = val),
                onApply: () {},
                onClear: () => setState(() {
                  _selectedDivision = null;
                  _dateFromController.clear();
                  _dateToController.clear();
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          title: const Row(
            children: [
              Icon(Icons.backup_outlined),
              SizedBox(width: 8),
              Text('REALIZAR BACKUP'),
            ],
          ),
          children: [
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Exportar Datos'),
              onTap: _exportarDatos,
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Importar Datos'),
              onTap: _importarDatos,
            ),
          ],
        ),
      ],
    );
  }
}