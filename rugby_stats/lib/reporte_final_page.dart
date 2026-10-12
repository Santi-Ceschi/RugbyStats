import 'package:flutter/material.dart';
import 'models/partido.dart';
import 'services/pdf_generator.dart';
import 'services/calculadora_estadisticas.dart';

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

  // Estadísticas centralizadas
  late EstadisticasPartido _stats;
  late EstadisticasPartido _statsRival;

  @override
  void initState() {
    super.initState();
    _procesarDatos();
  }

  void _procesarDatos() {
    // 1. Condición Final basada en puntos
    // Alma Juniors siempre es 'Local' estructuralmente
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

    // 2. Cálculo centralizado
    _stats = CalculadoraEstadisticas.calcular(
      acciones: widget.acciones,
      tiposAccion: widget.tiposAccion,
      equipo: 'Local',
    );
    _statsRival = CalculadoraEstadisticas.calcular(
      acciones: widget.acciones,
      tiposAccion: widget.tiposAccion,
      equipo: 'Visitante',
    );
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
            const Text('RENDIMIENTO DE ALMA JUNIORS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 16),

            // Formaciones
            const Text('EFECTIVIDAD EN FORMACIONES FIJAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            _buildFormacionCard('Scrum', _stats.scrum),
            _buildFormacionCard('Line', _stats.line),
            _buildFormacionCard('Maul', _stats.maul),
            _buildFormacionCard('Salida', _stats.salida),
            
            const SizedBox(height: 16),
            const Text('DEFENSA Y PATEO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            _buildStatCard('Tackles Efectivos', _stats.tackles.toMap()),
            _buildStatCard('Efectividad en Patadas', _stats.patadas.toMap()),
            if (_stats.patadas.total > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  'Conversiones: ${_stats.patadas.conversiones} | Penales a los palos: ${_stats.patadas.penalesPalos} | Erradas: ${_stats.patadas.erradas}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 16),
            const Text('PUNTOS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            _buildSimpleCard('Tries Anotados', _stats.tries),

            const SizedBox(height: 16),
            const Text('DISCIPLINA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            _buildSimpleCard('Errores No Forzados', _stats.erroresNoForzados),
            _buildPenalesCard(_stats.penales),
            _buildTarjetasCard(_stats.tarjetas),

            // SECCIÓN RIVAL
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Text('RENDIMIENTO DEL RIVAL (${widget.partido.equipoVisitante.toUpperCase()})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 16),

            const Text('DEFENSA Y PATEO DEL RIVAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            _buildStatCard('Tackles Efectivos', _statsRival.tackles.toMap()),
            _buildStatCard('Efectividad en Patadas', _statsRival.patadas.toMap()),
            if (_statsRival.patadas.total > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  'Conversiones: ${_statsRival.patadas.conversiones} | Penales a los palos: ${_statsRival.patadas.penalesPalos} | Erradas: ${_statsRival.patadas.erradas}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 16),
            const Text('PUNTOS DEL RIVAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            _buildSimpleCard('Tries Anotados', _statsRival.tries),

            const SizedBox(height: 16),
            const Text('DISCIPLINA DEL RIVAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            _buildSimpleCard('Errores No Forzados', _statsRival.erroresNoForzados),
            _buildPenalesCard(_statsRival.penales),
            _buildTarjetasCard(_statsRival.tarjetas),

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generando PDF...')));
                
                String nombreOponente = widget.partido.equipoVisitante;
                String txtCondicion = widget.partido.somosLocal ? 'Local' : 'Visitante';

                try {
                  await PdfGenerator.generateAndSharePdf(
                    fecha: _fechaActual,
                    hora: '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    division: widget.partido.division,
                    oponente: '$nombreOponente ($txtCondicion)',
                    duracion: widget.duracionTotal,
                    resultado: _condicionFinal,
                    puntosLocal: widget.partido.puntosLocal,
                    puntosVisitante: widget.partido.puntosVisitante,
                    estadisticas: _stats,
                    estadisticasRival: _statsRival,
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
              stat['alerta'] ?? '', 
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

  Widget _buildPenalesCard(PenalesStat penales) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Penales Cometidos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('${penales.total}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          if (penales.total > 0) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: penales.detalle.entries.map((e) {
                return Text(
                  '${e.key}: ${e.value}',
                  style: TextStyle(
                    fontSize: 11,
                    color: e.value > 0 ? Colors.black87 : Colors.grey,
                    fontWeight: e.value > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTarjetasCard(TarjetasStat tarjetas) {
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
          const Text('Tarjetas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Row(
            children: [
              Text('🟨 ${tarjetas.amarillas}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 12),
              Text('🟥 ${tarjetas.rojas}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormacionCard(String label, FormacionStat stat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sports_rugby, size: 16, color: Colors.blueGrey[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              if (stat.alerta.isNotEmpty && stat.alerta != 'Sin datos')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: stat.porcentaje >= 80
                        ? Colors.green[50]
                        : (stat.porcentaje >= 50 ? Colors.orange[50] : Colors.red[50]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    stat.alerta,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: stat.porcentaje >= 80
                          ? Colors.green[800]
                          : (stat.porcentaje >= 50 ? Colors.orange[800] : Colors.red[800]),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Fila 1: Obtención propia
          Row(
            children: [
              const SizedBox(width: 24),
              const Expanded(
                child: Text('Obtención propia', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ),
              Text('${stat.ganados}/${stat.total}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(width: 8),
              Text(
                '${stat.porcentaje}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: _getMetricColor(stat.porcentaje),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Fila 2: Robadas al rival
          Row(
            children: [
              const SizedBox(width: 24),
              const Expanded(
                child: Text('Robadas al rival', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ),
              Text('${stat.rivalRobados}/${stat.rivalTotal}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(width: 8),
              Text(
                '${stat.rivalPorcentaje}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: _getMetricColor(stat.rivalPorcentaje),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMetricColor(int porcentaje) {
    if (porcentaje >= 80) return Colors.green[700]!;
    if (porcentaje >= 50) return Colors.orange[700]!;
    return Colors.red[700]!;
  }
}
