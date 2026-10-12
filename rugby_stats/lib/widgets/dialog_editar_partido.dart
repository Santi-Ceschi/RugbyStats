import 'package:flutter/material.dart';
import '../models/partido.dart';
import '../services/database_helper.dart';

class DialogEditarPartido extends StatefulWidget {
  final Partido partido;

  const DialogEditarPartido({super.key, required this.partido});

  @override
  State<DialogEditarPartido> createState() => _DialogEditarPartidoState();
}

class _DialogEditarPartidoState extends State<DialogEditarPartido> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _rivalController;
  late final TextEditingController _torneoPersonalizadoController;

  late String _selectedDivision;
  late bool _somosLocales;
  final List<String> _divisions = ['Primera', 'Intermedia', 'Pre-Intermedia'];

  bool _isLoadingTorneos = true;
  List<String> _listaDinamicaDeTorneos = [];
  String? _selectedTorneo;

  @override
  void initState() {
    super.initState();
    _rivalController = TextEditingController(text: widget.partido.equipoVisitante);
    _selectedDivision = _divisions.contains(widget.partido.division)
        ? widget.partido.division
        : 'Primera';
    _somosLocales = widget.partido.somosLocal;

    _torneoPersonalizadoController = TextEditingController();
    _cargarTorneos();
  }

  Future<void> _cargarTorneos() async {
    final torneosBD = await DatabaseHelper.instance.getTorneosUnicos();
    if (mounted) {
      setState(() {
        _listaDinamicaDeTorneos = [...torneosBD, 'Otro'];
        if (torneosBD.contains(widget.partido.torneo)) {
          _selectedTorneo = widget.partido.torneo;
        } else if (widget.partido.torneo.isNotEmpty) {
          _selectedTorneo = 'Otro';
          _torneoPersonalizadoController.text = widget.partido.torneo;
        } else {
          _selectedTorneo = torneosBD.isNotEmpty ? torneosBD.first : 'Otro';
        }
        _isLoadingTorneos = false;
      });
    }
  }

  @override
  void dispose() {
    _rivalController.dispose();
    _torneoPersonalizadoController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final String torneoAGuardar = _selectedTorneo == 'Otro'
        ? _torneoPersonalizadoController.text.trim().replaceAll(RegExp(r'\s+'), ' ')
        : (_selectedTorneo ?? widget.partido.torneo);

    await DatabaseHelper.instance.updatePartidoMetadatos(
      idPartido: widget.partido.idPartido!,
      equipoVisitante: _rivalController.text.trim(),
      division: _selectedDivision,
      torneo: torneoAGuardar,
      somosLocal: _somosLocales,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos del partido actualizados'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
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
                      'EDITAR PARTIDO',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context, false),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Localía Toggle
                const Text('¿JUGAMOS DE LOCAL?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _somosLocales ? Colors.black : Colors.white,
                          side: BorderSide(color: _somosLocales ? Colors.black : Colors.grey[300]!),
                        ),
                        onPressed: () => setState(() => _somosLocales = true),
                        child: Text(
                          'SÍ (LOCAL)',
                          style: TextStyle(
                            color: _somosLocales ? Colors.white : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: !_somosLocales ? Colors.black : Colors.white,
                          side: BorderSide(color: !_somosLocales ? Colors.black : Colors.grey[300]!),
                        ),
                        onPressed: () => setState(() => _somosLocales = false),
                        child: Text(
                          'NO (VISITANTE)',
                          style: TextStyle(
                            color: !_somosLocales ? Colors.white : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Campo Rival
                const Text('EQUIPO RIVAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _rivalController,
                  decoration: const InputDecoration(
                    hintText: 'Nombre del rival',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el rival' : null,
                ),
                const SizedBox(height: 16),

                // División
                const Text('DIVISIÓN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedDivision,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: _divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDivision = val);
                  },
                ),
                const SizedBox(height: 16),

                // Torneo
                const Text('TORNEO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                if (_isLoadingTorneos)
                  const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                else ...[
                  DropdownButtonFormField<String>(
                    value: _selectedTorneo,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: _listaDinamicaDeTorneos.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTorneo = val);
                    },
                  ),
                  if (_selectedTorneo == 'Otro') ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _torneoPersonalizadoController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe el nombre del torneo...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (v) {
                        if (_selectedTorneo == 'Otro' && (v == null || v.trim().isEmpty)) {
                          return 'Ingresa el nombre del torneo';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
                const SizedBox(height: 24),

                // Botón Guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: _guardarCambios,
                    child: const Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
