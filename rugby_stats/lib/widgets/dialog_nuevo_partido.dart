import 'package:flutter/material.dart';
import '../models/partido.dart';
import '../services/database_helper.dart';

class DialogNuevoPartido extends StatefulWidget {
  const DialogNuevoPartido({super.key});

  @override
  State<DialogNuevoPartido> createState() => _DialogNuevoPartidoState();
}

class _DialogNuevoPartidoState extends State<DialogNuevoPartido> {
  final _formKey = GlobalKey<FormState>();
  final _rivalController = TextEditingController();
  final _fechaController = TextEditingController();
  
  String _selectedDivision = 'Primera';
  bool _somosLocales = true;
  final List<String> _divisions = ['Primera', 'Intermedia', 'Pre-Intermedia'];

  @override
  void initState() {
    super.initState();
    // Precargar la fecha de hoy
    final hoy = DateTime.now();
    _fechaController.text = "${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}";
  }

  @override
  void dispose() {
    _rivalController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    DateTime initial = DateTime.now();
    if (_fechaController.text.isNotEmpty) {
      try {
        final p = _fechaController.text.split('/');
        if (p.length == 3) {
          initial = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
        }
      } catch (_) {}
    }

    if (initial.isBefore(DateTime(2000))) initial = DateTime(2000);
    if (initial.isAfter(DateTime(2100))) initial = DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
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

    if (picked != null) {
      final String day = picked.day.toString().padLeft(2, '0');
      final String month = picked.month.toString().padLeft(2, '0');
      final String year = picked.year.toString();
      _fechaController.text = "$day/$month/$year";
    }
  }

  Future<void> _comenzar() async {
    if (!_formKey.currentState!.validate()) return;

    // Convertir dd/mm/aaaa a yyyy-mm-dd
    String fechaIso = DateTime.now().toIso8601String();
    try {
      final p = _fechaController.text.split('/');
      if (p.length == 3) {
        fechaIso = "${p[2]}-${p[1]}-${p[0]}";
      }
    } catch (_) {}

    // Lógica de Negocio: Localía
    String equipoLocal = _somosLocales ? "Mi Club" : _rivalController.text.trim();
    String equipoVisitante = _somosLocales ? _rivalController.text.trim() : "Mi Club";
    
    // Mapeo de Categoría
    Categoria cat = Categoria.primera;
    if (_selectedDivision == 'Intermedia') cat = Categoria.intermedia;
    if (_selectedDivision == 'Pre-Intermedia') cat = Categoria.preIntermedia;

    // Crear el modelo
    final nuevoPartido = Partido(
      fecha: fechaIso,
      equipoLocal: equipoLocal,
      equipoVisitante: equipoVisitante,
      estadoPartido: 'En curso',
      torneo: 'Torneo Regular', // Por defecto
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
                TextFormField(
                  controller: _fechaController,
                  readOnly: true,
                  decoration: _inputDecoration().copyWith(
                    suffixIcon: const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  ),
                  onTap: _seleccionarFecha,
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
