import 'package:flutter/material.dart';
import '../models/partido.dart';
import '../services/database_helper.dart';
import '../utils/app_constants.dart';

class DialogNuevoPartido extends StatefulWidget {
  const DialogNuevoPartido({super.key});

  @override
  State<DialogNuevoPartido> createState() => _DialogNuevoPartidoState();
}

class _DialogNuevoPartidoState extends State<DialogNuevoPartido> {
  final _formKey = GlobalKey<FormState>();
  final _rivalController = TextEditingController();
  final _torneoController = TextEditingController();
  
  String _selectedDivision = 'Primera';
  bool _somosLocales = true;
  final List<String> _divisions = ['Primera', 'Intermedia', 'Pre-Intermedia'];

  DateTime _fechaPartido = DateTime.now();

  @override
  void dispose() {
    _rivalController.dispose();
    _torneoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaPartido,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _fechaPartido = picked;
      });
    }
  }

  Future<void> _comenzar() async {
    if (!_formKey.currentState!.validate()) return;

    // Lógica de Negocio: Localía
    String equipoLocal = _somosLocales ? AppConstants.clubLocalName : _rivalController.text.trim();
    String equipoVisitante = _somosLocales ? _rivalController.text.trim() : AppConstants.clubLocalName;
    
    // Mapeo de Categoría
    Categoria cat = Categoria.primera;
    if (_selectedDivision == 'Intermedia') cat = Categoria.intermedia;
    if (_selectedDivision == 'Pre-Intermedia') cat = Categoria.preIntermedia;

    // Crear el modelo
    final nuevoPartido = Partido(
      fecha: _fechaPartido.toIso8601String(),
      equipoLocal: equipoLocal,
      equipoVisitante: equipoVisitante,
      estadoPartido: 'En curso',
      torneo: _torneoController.text.trim(),
      puntosLocal: 0,
      puntosVisitante: 0,
      division: _selectedDivision,
      categoria: cat,
      resultado: 'Empate', // Inicial
    );

    // Insertar en BD y recuperar ID autogenerado
    final idGenerado = await DatabaseHelper.instance.insertPartido(nuevoPartido);
    
    // Destruir el Modal y pasar el ID a home_page
    if (mounted) {
      Navigator.pop(context, idGenerado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'NUEVO PARTIDO',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context, null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Localía Toggle (Nueva Regla de Negocio)
                const Text('¿JUGAMOS DE LOCAL?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _somosLocales ? Colors.black : Colors.white,
                          foregroundColor: _somosLocales ? Colors.white : Colors.black,
                        ),
                        onPressed: () => setState(() => _somosLocales = true),
                        child: const Text('Sí'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: !_somosLocales ? Colors.black : Colors.white,
                          foregroundColor: !_somosLocales ? Colors.white : Colors.black,
                        ),
                        onPressed: () => setState(() => _somosLocales = false),
                        child: const Text('No'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Campo Equipo Rival
                const Text('EQUIPO RIVAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _rivalController,
                  decoration: _inputDecoration(hint: 'Ingresa el nombre del equipo'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 20),

                // Campo Torneo
                const Text('TORNEO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _torneoController,
                  maxLength: 50,
                  decoration: _inputDecoration(hint: 'Ej: TRL, Dos Orillas, etc.'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 20),

                // Campo División
                const Text('DIVISIÓN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDivision,
                  items: _divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDivision = val);
                  },
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 20),

                // Campo Fecha
                const Text('FECHA DEL PARTIDO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _seleccionarFecha,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${_fechaPartido.day.toString().padLeft(2, '0')}/${_fechaPartido.month.toString().padLeft(2, '0')}/${_fechaPartido.year}"),
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Botones de Acción
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _comenzar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('COMENZAR', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, null),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('CANCELAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!)),
    );
  }
}
