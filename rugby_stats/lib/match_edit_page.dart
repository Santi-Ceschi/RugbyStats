import 'package:flutter/material.dart';
import 'models/partido.dart';
import 'services/database_helper.dart';
import 'widgets/dialog_agregar_accion_historica.dart';

class MatchEditPage extends StatefulWidget {
  final Partido partido;
  const MatchEditPage({super.key, required this.partido});

  @override
  State<MatchEditPage> createState() => _MatchEditPageState();
}

class _MatchEditPageState extends State<MatchEditPage> {
  late Partido _partido;
  List<Map<String, dynamic>> _acciones = [];
  Map<int, String> _tiposMap = {};

  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _partido = widget.partido;
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final tipos = await DatabaseHelper.instance.getTiposAccion();
    final acciones = await DatabaseHelper.instance.getAccionesByPartido(_partido.idPartido!);
    
    final pFresco = await DatabaseHelper.instance.getPartidoById(_partido.idPartido!);
    
    if (mounted) {
      setState(() {
        _tiposMap = { for (var t in tipos) t['Id_Tipo_Accion'] : t['Nombre'] };
        _acciones = acciones.reversed.toList(); // Mostrar recientes primero
        if (pFresco != null) _partido = pFresco;
        _isLoadingData = false;
      });
    }
  }

  Future<void> _eliminarAccion(int idAccion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Acción'),
        content: const Text('¿Estás seguro de que deseas eliminar esta estadística? Se recalcularán los puntos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await DatabaseHelper.instance.eliminarAccionHistorica(idAccion);
        await _cargarDatos(); 
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Acción eliminada correctamente'))
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.black,
            )
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Editor de Partido', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: Text(_partido.equipoLocal, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                Text('${_partido.puntosLocal} - ${_partido.puntosVisitante}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Expanded(child: Text(_partido.equipoVisitante, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 1),
          
          Expanded(
            child: _acciones.isEmpty 
              ? const Center(child: Text('No hay acciones registradas en este partido.'))
              : ListView.builder(
                  itemCount: _acciones.length,
                  itemBuilder: (context, index) {
                    final acc = _acciones[index];
                    final tipoNombre = _tiposMap[acc['Id_Tipo_Accion']] ?? 'Acción';
                    
                    final tiempoStr = (acc['Tiempo_Accion'] ?? '00:00').toString();
                    final minutoLabel = tiempoStr.contains(':') ? tiempoStr.split(':')[0] : '00';
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.black12,
                          child: Text(minutoLabel, style: const TextStyle(fontSize: 12, color: Colors.black)),
                        ),
                        title: Text('$tipoNombre (${acc['Equipo_Accion']})'),
                        subtitle: Text(acc['Resultado_Accion'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.black),
                          onPressed: () => _eliminarAccion(acc['IdAccion']),
                        ),
                      ),
                    );
                  },
                ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('NUEVA ACCIÓN'),
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => DialogAgregarAccionHistorica(partido: _partido),
          );
          if (result == true) _cargarDatos();
        },
      ),
    );
  }
}
