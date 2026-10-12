import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'calculadora_estadisticas.dart';

class PdfGenerator {
  static Future<void> generateAndSharePdf({
    required String fecha,
    required String hora,
    required String division,
    required String oponente,
    required String duracion,
    required String resultado,
    required int puntosLocal,
    required int puntosVisitante,
    required EstadisticasPartido estadisticas,
    required EstadisticasPartido estadisticasRival,
  }) async {
    final pdf = pw.Document();

    // Cálculos extras
    int totalPuntos = estadisticas.tries * 5; // 5 pts por try
    int totalPuntosRival = estadisticasRival.tries * 5;
    
    double minDouble = 0.0;
    try {
      final parts = duracion.split('m');
      if (parts.isNotEmpty) {
        minDouble = double.parse(parts[0]);
      }
    } catch (e) {
      // ignore
    }
    String ptsPorMinuto = minDouble > 0 ? (totalPuntos / minDouble).toStringAsFixed(1) : "0.0";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Encabezado
            pw.Center(
              child: pw.Text('REPORTE FINAL DEL PARTIDO', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text('RugbyStats - Alma Juniors Rugby', style: const pw.TextStyle(fontSize: 12)),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.SizedBox(height: 8),

            // Información del Partido
            pw.Text('Información del Partido', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            _buildTextLine('Fecha:', fecha),
            _buildTextLine('División:', division),
            _buildTextLine('Oponente:', oponente),
            _buildTextLine('Duración:', duracion),
            _buildTextLine('Resultado:', resultado),
            
            pw.SizedBox(height: 12),
            // Tanteador Central
            pw.Center(
              child: pw.Text('$puntosLocal - $puntosVisitante', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 12),

            // RENDIMIENTO DE ALMA JUNIORS
            pw.Text('RENDIMIENTO DE ALMA JUNIORS', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
            pw.SizedBox(height: 8),

            pw.Text('EFECTIVIDAD EN FORMACIONES FIJAS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            _buildFormacionPdfStat('Scrum', estadisticas.scrum),
            _buildFormacionPdfStat('Line', estadisticas.line),
            _buildFormacionPdfStat('Maul', estadisticas.maul),
            _buildFormacionPdfStat('Salida', estadisticas.salida),
            pw.SizedBox(height: 8),

            pw.Text('DEFENSA Y PATEO', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            _buildProgressBarStat('Tackles efectivos', estadisticas.tackles.toMap()),
            _buildProgressBarStat('Efectividad en patadas', estadisticas.patadas.toMap()),
            if (estadisticas.patadas.total > 0)
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
                child: pw.Text(
                  'Conversiones: ${estadisticas.patadas.conversiones} | Penales a los palos: ${estadisticas.patadas.penalesPalos} | Erradas: ${estadisticas.patadas.erradas}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ),
            pw.SizedBox(height: 8),

            pw.Text('PUNTOS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
              child: pw.Text('Tries: ${estadisticas.tries} ($totalPuntos puntos)', style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
              child: pw.Text('Puntos por minuto: $ptsPorMinuto', style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.SizedBox(height: 8),

            pw.Text('DISCIPLINA', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            _buildSimpleLine('Errores no forzados:', estadisticas.erroresNoForzados.toString()),
            _buildSimpleLine('Penales cometidos:', estadisticas.penales.total.toString()),
            _buildIndentedLine('- Inconducta: ${estadisticas.penales.detalle['Inconducta'] ?? 0}'),
            _buildIndentedLine('- Offside: ${estadisticas.penales.detalle['Offside'] ?? 0}'),
            _buildIndentedLine('- Ruck: ${estadisticas.penales.detalle['Ruck'] ?? 0}'),
            _buildIndentedLine('- Scrum: ${estadisticas.penales.detalle['Scrum'] ?? 0}'),
            _buildIndentedLine('- Otro: ${estadisticas.penales.detalle['Otro'] ?? 0}'),
            _buildSimpleLine('Tarjetas amarillas:', estadisticas.tarjetas.amarillas.toString()),
            _buildSimpleLine('Tarjetas rojas:', estadisticas.tarjetas.rojas.toString()),
            pw.SizedBox(height: 14),

            // SECCIÓN RIVAL
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text('RENDIMIENTO DEL RIVAL', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
            pw.SizedBox(height: 8),

            pw.Text('DEFENSA Y PATEO DEL RIVAL', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            _buildProgressBarStat('Tackles efectivos', estadisticasRival.tackles.toMap()),
            _buildProgressBarStat('Efectividad en patadas', estadisticasRival.patadas.toMap()),
            if (estadisticasRival.patadas.total > 0)
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
                child: pw.Text(
                  'Conversiones: ${estadisticasRival.patadas.conversiones} | Penales a los palos: ${estadisticasRival.patadas.penalesPalos} | Erradas: ${estadisticasRival.patadas.erradas}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ),
            pw.SizedBox(height: 8),

            pw.Text('PUNTOS DEL RIVAL', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
              child: pw.Text('Tries: ${estadisticasRival.tries} ($totalPuntosRival puntos)', style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.SizedBox(height: 8),

            pw.Text('DISCIPLINA DEL RIVAL', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            _buildSimpleLine('Errores no forzados:', estadisticasRival.erroresNoForzados.toString()),
            _buildSimpleLine('Penales cometidos:', estadisticasRival.penales.total.toString()),
            _buildIndentedLine('- Inconducta: ${estadisticasRival.penales.detalle['Inconducta'] ?? 0}'),
            _buildIndentedLine('- Offside: ${estadisticasRival.penales.detalle['Offside'] ?? 0}'),
            _buildIndentedLine('- Ruck: ${estadisticasRival.penales.detalle['Ruck'] ?? 0}'),
            _buildIndentedLine('- Scrum: ${estadisticasRival.penales.detalle['Scrum'] ?? 0}'),
            _buildIndentedLine('- Otro: ${estadisticasRival.penales.detalle['Otro'] ?? 0}'),
            _buildSimpleLine('Tarjetas amarillas:', estadisticasRival.tarjetas.amarillas.toString()),
            _buildSimpleLine('Tarjetas rojas:', estadisticasRival.tarjetas.rojas.toString()),

            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Text('Generado el $fecha a las $hora', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ),
          ];
        },
      ),
    );

    // Guardar archivo
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    // Limpiar nombre del equipo
    final safeOponente = oponente.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final file = File('${dir.path}/Reporte_AlmaJuniors_$safeOponente.pdf');
    await file.writeAsBytes(bytes);

    // Compartir usando Share.shareXFiles
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Reporte Final - Alma Juniors vs $oponente',
    );
  }

  static PdfColor _getColorEfectividad(int porcentaje) {
    if (porcentaje >= 80) return PdfColors.green;
    if (porcentaje >= 50) return PdfColors.orange;
    return PdfColors.red;
  }

  static pw.Widget _buildProgressBarStat(String label, Map<String, dynamic> stat) {
    int porcentaje = stat['porcentaje'] ?? 0;
    int ganados = stat['ganados'] ?? 0;
    int total = stat['total'] ?? 0;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 10, bottom: 6),
      child: pw.Row(
        children: [
          pw.Container(
            width: 120, // Ancho fijo seguro
            child: pw.Text('$label ($ganados/$total)', style: const pw.TextStyle(fontSize: 10)),
          ),
          pw.SizedBox(width: 10),
          pw.Container(
            width: 100, 
            height: 6,
            color: PdfColors.grey300,
            alignment: pw.Alignment.centerLeft,
            child: pw.Container(
              width: porcentaje.toDouble(), 
              height: 6,
              color: _getColorEfectividad(porcentaje),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text('$porcentaje%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildFormacionPdfStat(String label, FormacionStat stat) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 10, bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.SizedBox(height: 2),
          _buildSubBar('Obtención propia', stat.ganados, stat.total, stat.porcentaje),
          _buildSubBar('Robadas al rival', stat.rivalRobados, stat.rivalTotal, stat.rivalPorcentaje),
        ],
      ),
    );
  }

  static pw.Widget _buildSubBar(String label, int ganados, int total, int porcentaje) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
      child: pw.Row(
        children: [
          pw.Container(
            width: 130,
            child: pw.Text('$label ($ganados/$total)', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ),
          pw.SizedBox(width: 8),
          pw.Container(
            width: 80,
            height: 5,
            color: PdfColors.grey300,
            alignment: pw.Alignment.centerLeft,
            child: pw.Container(
              width: (porcentaje * 0.8), // 80px max
              height: 5,
              color: _getColorEfectividad(porcentaje),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Text('$porcentaje%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _buildTextLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(width: 4),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  static pw.Widget _buildSimpleLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
      child: pw.Row(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(width: 4),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  static pw.Widget _buildIndentedLine(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 20, bottom: 2),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
    );
  }
}
