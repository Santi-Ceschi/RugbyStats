import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'models/partido.dart';
import 'widgets/partido_card.dart';
import 'widgets/panel_filtrado.dart';
import 'services/database_helper.dart';
import 'widgets/dialog_nuevo_partido.dart';
import 'match_page.dart';
import 'utils/app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedDivision;
  DateTimeRange? _filtroRangoFechas;

  final List<String> _divisions = ['Primera', 'Intermedia', 'Pre-Intermedia'];

  List<Partido> _partidos = [];

  @override
  void initState() {
    super.initState();
    _cargarPartidos();
  }

  Future<void> _cargarPartidos() async {
    final partidosDB = await DatabaseHelper.instance.getPartidos(
      division: _selectedDivision,
      fechaDesde: _filtroRangoFechas != null ? _filtroRangoFechas!.start.toIso8601String().substring(0, 10) : null,
      fechaHasta: _filtroRangoFechas != null ? _filtroRangoFechas!.end.toIso8601String().substring(0, 10) : null,
    );

    setState(() {
      _partidos = partidosDB;
    });
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
    try {
      PlatformFile? result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.path != null) {
        File file = File(result.path!);
        String jsonString = await file.readAsString();
        
        await DatabaseHelper.instance.importDatabaseFromJson(jsonString);
        _cargarPartidos();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup importado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar backup: $e')),
        );
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
              AppConstants.clubLocalName,
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
                        'Aún no hay partidos registrados o coincidiendo con el filtro.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _partidos.length,
                      itemBuilder: (context, index) => PartidoCard(
                        partido: _partidos[index],
                        onEdit: () {},
                        onDelete: () async {
                          if (_partidos[index].idPartido != null) {
                            final res = await DatabaseHelper.instance.deletePartido(_partidos[index].idPartido!);
                            if (res['success']) {
                               _cargarPartidos();
                               if (context.mounted) {
                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
                               }
                            }
                          }
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
            onPressed: () async {
              final nuevoPartidoId = await showDialog<int>(
                context: context,
                barrierDismissible: false,
                builder: (context) => const DialogNuevoPartido(),
              );

              if (nuevoPartidoId != null) {
                if (mounted) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchPage(partidoId: nuevoPartidoId),
                    ),
                  );
                }
                
                _cargarPartidos(); 
              }
            },
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
                selectedDateRange: _filtroRangoFechas,
                selectedDivision: _selectedDivision,
                divisions: _divisions,
                onDivisionChanged: (val) =>
                    setState(() => _selectedDivision = val),
                onDateRangeChanged: (val) =>
                    setState(() => _filtroRangoFechas = val),
                onApply: () {
                  _cargarPartidos();
                },
                onClear: () => setState(() {
                  _selectedDivision = null;
                  _filtroRangoFechas = null;
                  _cargarPartidos();
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