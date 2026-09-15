import 'dart:async';
import 'package:flutter/material.dart';
import 'models/partido.dart';
import 'models/accion.dart';
import 'services/database_helper.dart';

class MatchPage extends StatefulWidget {
  final int partidoId;

  const MatchPage({super.key, required this.partidoId});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  Partido? _partido;
  List<Map<String, dynamic>> _acciones = [];
  Map<String, int> _tiposAccion = {};
  
  Timer? _timer;
  bool _isPaused = true;
  DateTime? _horaPausa;

  final List<String> _botonesIzquierda = [
    'Try', 'Scrum', 'Line', 'Patada', 'Penales Cometidos',
    'Tackle', 'Maul', 'Salida', 'Error No Forzado', 'Tarjeta'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_isPaused) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = await DatabaseHelper.instance.database;
    final pData = await db.query('PARTIDO', where: 'Id_Partido = ?', whereArgs: [widget.partidoId]);
    
    if (pData.isNotEmpty) {
      _partido = Partido.fromMap(pData.first);
    }
    
    _acciones = await DatabaseHelper.instance.getAccionesByPartido(widget.partidoId);
    
    final tipos = await db.query('Tipo_Accion');
    _tiposAccion = { for (var e in tipos) e['Nombre'] as String : e['Id_Tipo_Accion'] as int };
    
    if (mounted) setState(() {});
  }

  String _getTiempoDisplay() {
    if (_partido == null || _partido!.horaInicio == null) return "00:00";
    
    DateTime inicio = DateTime.parse(_partido!.horaInicio!);
    DateTime referencia = _isPaused && _horaPausa != null ? _horaPausa! : DateTime.now();
    
    Duration transcurrido = referencia.difference(inicio);
    Duration finalDuration = transcurrido + Duration(minutes: _partido!.minutosAjuste);
    if (finalDuration.isNegative) finalDuration = Duration.zero;
    
    return "${finalDuration.inMinutes.toString().padLeft(2, '0')}:${(finalDuration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  Future<void> _toggleTimer() async {
    if (_partido == null) return;
    
    if (_partido!.horaInicio == null) {
      await DatabaseHelper.instance.updateRelojPartido(widget.partidoId, DateTime.now().toIso8601String(), 0);
      _isPaused = false;
    } else {
      if (_isPaused) {
        if (_horaPausa != null) {
          Duration pausa = DateTime.now().difference(_horaPausa!);
          DateTime nuevoInicio = DateTime.parse(_partido!.horaInicio!).add(pausa);
          await DatabaseHelper.instance.updateRelojPartido(widget.partidoId, nuevoInicio.toIso8601String(), _partido!.minutosAjuste);
        }
        _isPaused = false;
        _horaPausa = null;
      } else {
        _horaPausa = DateTime.now();
        _isPaused = true;
      }
    }
    await _loadData();
  }

  Future<void> _ajustarMinutos(int delta) async {
    if (_partido == null) return;
    await DatabaseHelper.instance.updateRelojPartido(
      widget.partidoId, 
      _partido!.horaInicio ?? DateTime.now().toIso8601String(), 
      _partido!.minutosAjuste + delta
    );
    await _loadData();
  }

  void _onActionTap(String actionName, String equipo) {
    if (_partido == null || _partido!.horaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inicia el cronómetro primero')));
      return;
    }

    if (actionName == 'Patada') {
      _showSubOptions(actionName, equipo, ['Conversión', 'Penal a los Palos', 'Errada']);
    } else if (['Scrum', 'Line', 'Maul', 'Salida'].contains(actionName)) {
      _showSubOptions(actionName, equipo, ['Ganada', 'Perdida']);
    } else if (actionName == 'Tackle') {
      _showSubOptions(actionName, equipo, ['Positivo', 'Negativo']);
    } else if (actionName == 'Penales Cometidos') {
      _showSubOptions(actionName, equipo, ['Scrum', 'Ruck', 'Inconducta', 'Offside', 'Otro']);
    } else if (actionName == 'Tarjeta') {
      _showSubOptions(actionName, equipo, ['Amarilla', 'Roja']);
    } else {
      _registrarAccion(actionName, equipo, null);
    }
  }

  void _showSubOptions(String actionName, String equipo, List<String> opciones) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$actionName - $equipo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: opciones.map((op) => ListTile(
            title: Text(op),
            onTap: () {
              Navigator.pop(ctx);
              _registrarAccion(actionName, equipo, op);
            },
          )).toList(),
        ),
      )
    );
  }

  Future<void> _registrarAccion(String actionName, String equipo, String? resultado) async {
    int idTipo = _tiposAccion[actionName] ?? 0;
    if (idTipo == 0) return;
    
    Accion nueva = Accion(
      resultadoAccion: resultado ?? '',
      idTipoAccion: idTipo,
      tiempoAccion: _getTiempoDisplay(),
      ordenAccion: _acciones.length + 1,
      equipoAccion: equipo,
      idPartido: widget.partidoId,
    );
    
    await DatabaseHelper.instance.insertAccion(nueva);
    
    int pts = 0;
    if (actionName == 'Try') pts = 5;
    if (actionName == 'Patada' && resultado == 'Conversión') pts = 2;
    if (actionName == 'Patada' && resultado == 'Penal a los Palos') pts = 3;
    
    if (pts > 0) {
      int pLocal = equipo == 'Local' ? pts : 0;
      int pVis = equipo == 'Visitante' ? pts : 0;
      await DatabaseHelper.instance.updatePuntajePartido(widget.partidoId, pLocal, pVis);
    }
    
    await _loadData();
  }

  Future<void> _deshacer() async {
    await DatabaseHelper.instance.undoUltimaAccion(widget.partidoId);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_partido == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200], 
              foregroundColor: Colors.black, 
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12)
            ),
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 20),
            label: Text(_partido!.horaInicio == null ? 'INICIAR' : (_isPaused ? 'CONTINUAR' : 'PAUSAR'), style: const TextStyle(fontSize: 12)),
            onPressed: _toggleTimer,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20), 
            onPressed: () => _ajustarMinutos(-1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text(
            _getTiempoDisplay(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20), 
            onPressed: () => _ajustarMinutos(1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. MARCADOR
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LOCAL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text(_partido!.equipoLocal, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    Text('${_partido!.puntosLocal}', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('-', style: TextStyle(fontSize: 48, color: Colors.grey)),
                    ),
                    Text('${_partido!.puntosVisitante}', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('VISITANTE', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text(_partido!.equipoVisitante, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // 2. BOTONES GENERALES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Finalizar Partido'),
                        content: const Text('¿Estás seguro que deseas terminar el partido? No podrás registrar más acciones.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
                          TextButton(
                            onPressed: () async {
                              await DatabaseHelper.instance.finalizarPartido(widget.partidoId);
                              if (mounted) {
                                Navigator.pop(ctx);
                                Navigator.pop(context); // Volver al home
                              }
                            }, 
                            child: const Text('FINALIZAR', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      )
                    );
                  },
                  child: const Text('FINALIZAR PARTIDO'),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.undo),
                  label: const Text('VOLVER ACCIÓN'),
                  onPressed: _acciones.isEmpty ? null : () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Deshacer Acción'),
                        content: const Text('¿Eliminar la última acción registrada?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _deshacer();
                            }, 
                            child: const Text('DESHACER'),
                          ),
                        ],
                      )
                    );
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('ESTADÍSTICAS'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente')));
                  },
                )
              ],
            ),
          ),
          const Divider(),
          // 3. TABLERO PRINCIPAL
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna Local
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: _botonesIzquierda.length,
                    itemBuilder: (ctx, i) {
                      String btn = _botonesIzquierda[i];
                      return ListTile(
                        leading: Text('${i + 1}'.padLeft(2, '0'), style: const TextStyle(color: Colors.grey)),
                        title: Text(btn, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                        onTap: () => _onActionTap(btn, 'Local'),
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 1),
                // Columna Visitante
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: _botonesIzquierda.length,
                    itemBuilder: (ctx, i) {
                      String btn = _botonesIzquierda[i];
                      return ListTile(
                        leading: Text('${i + 1}'.padLeft(2, '0'), style: const TextStyle(color: Colors.grey)),
                        title: Text(btn, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                        onTap: () => _onActionTap(btn, 'Visitante'),
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 1),
                // Columna Historial
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('ÚLTIMAS ACCIONES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      Expanded(
                        child: _acciones.isEmpty 
                          ? const Center(child: Text('Sin acciones aún', style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              itemCount: _acciones.length,
                              itemBuilder: (ctx, i) {
                                // Mostrar las más recientes arriba
                                final acc = _acciones[_acciones.length - 1 - i];
                                String tipoNombre = _tiposAccion.keys.firstWhere(
                                  (k) => _tiposAccion[k] == acc['Id_Tipo_Accion'], 
                                  orElse: () => '?'
                                );
                                String eq = acc['Equipo_Accion'] == 'Local' ? '(L)' : '(V)';
                                return ListTile(
                                  dense: true,
                                  title: Text('$tipoNombre $eq', style: const TextStyle(fontSize: 12)),
                                  subtitle: Text('${acc['Tiempo_Accion']} ${acc['Resultado_Accion']}', style: const TextStyle(fontSize: 10)),
                                );
                              },
                            ),
                      )
                    ],
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
