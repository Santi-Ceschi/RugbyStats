import 'package:flutter/material.dart';
import 'models/partido.dart';
import 'services/pdf_generator.dart';

class ReporteFinalPage extends StatefulWidget {
  final Partido partido;
  final List<Map<String, dynamic>> acciones;
  final Map<String, int> tiposAccion;
  final String duracionTotal;

  const ReporteFinalPage({
    super.key,
    required this.partido,
    required this.acciones,
    required this.tiposAccion,
    required this.duracionTotal,
  });

  @override
  State<ReporteFinalPage> createState() => _ReporteFinalPageState();
}

class _ReporteFinalPageState extends State<ReporteFinalPage> {
  // Metadatos
  late String _condicionFinal;
  late String _fechaActual;

  // Formaciones
  late Map<String, dynamic> _scrum;
  late Map<String, dynamic> _line;
  late Map<String, dynamic> _maul;
  late Map<String, dynamic> _salida;
  
  // Defensa
  late Map<String, dynamic> _tackles;
  
  // Puntos
  late int _tries;
  
  // Disciplina
  late int _errores;
  late int _tarjetas;
  late int _penales;

  @override
  void initState() {
    super.initState();
    _procesarDatos();
  }

  void _procesarDatos() {
    // 1. Condición Final
    if (widget.partido.puntosLocal > widget.partido.puntosVisitante) {
      _condicionFinal = 'VICTORIA';
    } else if (widget.partido.puntosLocal < widget.partido.puntosVisitante) {
      _condicionFinal = 'DERROTA';
    } else {
      _condicionFinal = 'EMPATE';
    }

    // Fecha
    final now = DateTime.now();
    _fechaActual = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    // 2. Helpers de cálculo
    _scrum = _calcularFormacion('Scrum');
    _line = _calcularFormacion('Line');
    _maul = _calcularFormacion('Maul');
    _salida = _calcularFormacion('Salida');
    
    _tackles = _calcularTackles();
    
    _tries = _contarAccion('Try');
    _errores = _contarAccion('Error No Forzado');
    _tarjetas = _contarAccion('Tarjeta');
    _penales = _contarAccion('Penales Cometidos');
  }

  Map<String, dynamic> _calcularFormacion(String nombre) {
    int? idAccion = widget.tiposAccion[nombre];
    if (idAccion == null) return {'total': 0, 'ganados': 0, 'porcentaje': 0, 'alerta': 'Sin datos'};

    final filtradas = widget.acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == 'Local');
    int total = filtradas.length;
    int ganados = filtradas.where((a) => a['Resultado_Accion'] == 'Ganada').length;
    
    int porcentaje = total == 0 ? 0 : ((ganados / total) * 100).round();
    return {
      'total': total, 
      'ganados': ganados, 
      'porcentaje': porcentaje,
      'alerta': _obtenerAlertaTextual(porcentaje, total)
    };
  }

  Map<String, dynamic> _calcularTackles() {
    int? idAccion = widget.tiposAccion['Tackle'];
    if (idAccion == null) return {'total': 0, 'ganados': 0, 'porcentaje': 0, 'alerta': 'Sin datos'};

    final filtradas = widget.acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == 'Local');
    int total = filtradas.length;
    int ganados = filtradas.where((a) => a['Resultado_Accion'] == 'Positivo').length;
    
    int porcentaje = total == 0 ? 0 : ((ganados / total) * 100).round();
    return {
      'total': total, 
      'ganados': ganados, 
      'porcentaje': porcentaje,
      'alerta': _obtenerAlertaTextual(porcentaje, total)
    };
  }

  int _contarAccion(String nombre) {
    int? idAccion = widget.tiposAccion[nombre];
    if (idAccion == null) return 0;
    return widget.acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == 'Local').length;
  }

  String _obtenerAlertaTextual(int porcentaje, int total) {
    if (total == 0) return 'Sin datos';
    if (porcentaje < 50) return 'Necesita mejorar';
    if (porcentaje <= 80) return 'Estable';
    return 'Excelente';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('REPORTE FINAL', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            Text(_fechaActual, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Metadatos Superiores
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    '${widget.partido.division.toUpperCase()} • $_condicionFinal',
                    style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.partido.equipoLocal} vs ${widget.partido.equipoVisitante}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${widget.partido.puntosLocal}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('-', style: TextStyle(fontSize: 24, color: Colors.grey)),
                      ),
                      Text('${widget.partido.puntosVisitante}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Duración: ${widget.duracionTotal}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('ANÁLISIS DE RENDIMIENTO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 16),

            // Formaciones
            const Text('EFECTIVIDAD EN FORMACIONES FIJAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            _buildStatCard('Scrum', _scrum),
            _buildStatCard('Line', _line),
            _buildStatCard('Maul', _maul),
            _buildStatCard('Salida', _salida),
            
            const SizedBox(height: 16),
            const Text('DEFENSA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            _buildStatCard('Tackles Efectivos', _tackles),

            const SizedBox(height: 16),
            const Text('PUNTOS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            _buildSimpleCard('Tries Convertidos', _tries),

            const SizedBox(height: 16),
            const Text('DISCIPLINA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            _buildSimpleCard('Errores No Forzados', _errores),
            _buildSimpleCard('Tarjetas', _tarjetas),
            _buildSimpleCard('Penales Cometidos', _penales),

            const SizedBox(height: 32),
            // Botones inferiores
            ElevatedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generando PDF...')));
                try {
                  await PdfGenerator.generateAndSharePdf(
                    fecha: _fechaActual,
                    hora: '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    division: widget.partido.division,
                    oponente: widget.partido.equipoVisitante,
                    duracion: widget.duracionTotal,
                    resultado: _condicionFinal,
                    puntosLocal: widget.partido.puntosLocal,
                    puntosVisitante: widget.partido.puntosVisitante,
                    scrum: _scrum,
                    line: _line,
                    maul: _maul,
                    salida: _salida,
                    tackles: _tackles,
                    tries: _tries,
                    errores: _errores,
                    tarjetasAmarillas: _tarjetas, // simplificado por ahora
                    tarjetasRojas: 0,
                    penales: _penales,
                  );
                } catch (e) {
                  debugPrint('Error generando PDF: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al generar PDF'), backgroundColor: Colors.red));
                  }
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('DESCARGAR PDF', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: const Text('CERRAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, Map<String, dynamic> stat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.show_chart, size: 16, color: Colors.red[300]),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Text('${stat['ganados']}/${stat['total']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 8),
          Text('${stat['porcentaje']}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 16),
          SizedBox(
            width: 90,
            child: Text(
              stat['alerta'], 
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              textAlign: TextAlign.right,
            )
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCard(String label, int total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text('$total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
