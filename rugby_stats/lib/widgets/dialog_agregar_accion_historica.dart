import 'package:flutter/material.dart';
import '../models/partido.dart';
import '../models/accion.dart';
import '../services/database_helper.dart';
import '../utils/reglas_rugby.dart';

class DialogAgregarAccionHistorica extends StatefulWidget {
  final Partido partido;
  const DialogAgregarAccionHistorica({super.key, required this.partido});

  @override
  State<DialogAgregarAccionHistorica> createState() => _DialogAgregarAccionHistoricaState();
}

class _DialogAgregarAccionHistoricaState extends State<DialogAgregarAccionHistorica> {
  final _tiempoController = TextEditingController();
  
  String? _equipoSeleccionado;
  int? _idTipoAccionSeleccionada;
  String _nombreTipoAccion = '';
  
  List<Map<String, dynamic>> _tiposAccion = [];
  List<String> _opcionesResultado = [];
  String? _resultadoSeleccionado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarTiposAccion();
    
    final localValido = widget.partido.equipoLocal != null && widget.partido.equipoLocal!.isNotEmpty;
    final visitaValido = widget.partido.equipoVisitante != null && widget.partido.equipoVisitante!.isNotEmpty;
    
    if (localValido) {
      _equipoSeleccionado = widget.partido.equipoLocal;
    } else if (visitaValido) {
      _equipoSeleccionado = widget.partido.equipoVisitante;
    }
  }

  Future<void> _cargarTiposAccion() async {
    final tipos = await DatabaseHelper.instance.getTiposAccion();
    setState(() {
      _tiposAccion = tipos;
      if (tipos.isNotEmpty) {
        _idTipoAccionSeleccionada = tipos.first['Id_Tipo_Accion'];
        _nombreTipoAccion = tipos.first['Nombre'];
        _opcionesResultado = ReglasRugby.getSubOptions(_nombreTipoAccion);
        _resultadoSeleccionado = _opcionesResultado.isNotEmpty ? _opcionesResultado.first : null;
      }
    });
  }

  Future<void> _guardarAccion() async {
    if (_equipoSeleccionado == null || _idTipoAccionSeleccionada == null) return;

    setState(() => _isLoading = true);

    try {
      final nuevaAccion = Accion(
        resultadoAccion: _resultadoSeleccionado ?? '',
        idTipoAccion: _idTipoAccionSeleccionada!,
        tiempoAccion: _tiempoController.text.trim().isEmpty ? '00:00' : _tiempoController.text.trim(),
        ordenAccion: 0, // El database_helper lo sobreescribe con max+1
        equipoAccion: _equipoSeleccionado!,
        idPartido: widget.partido.idPartido!, 
      );

      final puntos = ReglasRugby.calcularPuntos(_nombreTipoAccion, resultado: _resultadoSeleccionado);

      await DatabaseHelper.instance.agregarAccionHistorica(
        widget.partido.idPartido!, 
        nuevaAccion, 
        puntos
      );

      if (mounted) {
        Navigator.pop(context, true); 
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tiempoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<String>> equipoItems = [];
    if (widget.partido.equipoLocal != null && widget.partido.equipoLocal!.isNotEmpty) {
      equipoItems.add(DropdownMenuItem(value: widget.partido.equipoLocal, child: Text(widget.partido.equipoLocal!)));
    }
    if (widget.partido.equipoVisitante != null && widget.partido.equipoVisitante!.isNotEmpty) {
      equipoItems.add(DropdownMenuItem(value: widget.partido.equipoVisitante, child: Text(widget.partido.equipoVisitante!)));
    }

    return AlertDialog(
      title: const Text('Agregar Acción Histórica'),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Equipo Responsable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            if (equipoItems.isEmpty) 
              const Text('Error: No hay equipos registrados en este partido', style: TextStyle(color: Colors.black))
            else
              DropdownButton<String>(
                isExpanded: true,
                value: _equipoSeleccionado,
                items: equipoItems,
                onChanged: (val) => setState(() => _equipoSeleccionado = val),
              ),
              
            const SizedBox(height: 16),
            
            const Text('Tipo de Acción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            if (_tiposAccion.isEmpty) const CircularProgressIndicator()
            else DropdownButton<int>(
              isExpanded: true,
              value: _idTipoAccionSeleccionada,
              items: _tiposAccion.map((ta) {
                return DropdownMenuItem<int>(
                  value: ta['Id_Tipo_Accion'],
                  child: Text(ta['Nombre']),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _idTipoAccionSeleccionada = val;
                    _nombreTipoAccion = _tiposAccion.firstWhere((e) => e['Id_Tipo_Accion'] == val)['Nombre'];
                    _opcionesResultado = ReglasRugby.getSubOptions(_nombreTipoAccion);
                    _resultadoSeleccionado = _opcionesResultado.isNotEmpty ? _opcionesResultado.first : null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            if (_opcionesResultado.isNotEmpty) ...[
              const Text('Resultado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              DropdownButton<String>(
                isExpanded: true,
                value: _resultadoSeleccionado,
                items: _opcionesResultado.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
                onChanged: (val) => setState(() => _resultadoSeleccionado = val),
              ),
              const SizedBox(height: 16),
            ],

            const Text('Minuto (Opcional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            TextField(
              controller: _tiempoController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(hintText: 'Ej: 14:30'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: (_isLoading || equipoItems.isEmpty) ? null : _guardarAccion,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
          child: _isLoading 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('GUARDAR'),
        ),
      ],
    );
  }
}
