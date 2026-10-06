import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
    required Map<String, dynamic> scrum,
    required Map<String, dynamic> line,
    required Map<String, dynamic> maul,
    required Map<String, dynamic> salida,
    required Map<String, dynamic> tackles,
    required int tries,
    required int errores,
    required int tarjetasAmarillas,
    required int tarjetasRojas,
    required int penales,
  }) async {
    final pdf = pw.Document();

    // Cálculos extras
    int totalPuntos = tries * 5; // Asumiendo 5 pts por try para este reporte
    
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
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado
              pw.Center(
                child: pw.Text('REPORTE FINAL DEL PARTIDO', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text('RugbyStats - Alma Juniors Rugby', style: const pw.TextStyle(fontSize: 14)),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Información del Partido
              pw.Text('Información del Partido', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _buildTextLine('Fecha:', fecha),
              _buildTextLine('División:', division),
              _buildTextLine('Oponente:', oponente),
              _buildTextLine('Duración:', duracion),
              _buildTextLine('Resultado:', resultado),
              
              pw.SizedBox(height: 20),
              // Tanteador Central
              pw.Center(
                child: pw.Text('$puntosLocal - $puntosVisitante', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),

              // Análisis de Rendimiento
              pw.Text('Análisis de Rendimiento', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              pw.Text('EFECTIVIDAD EN FORMACIONES FIJAS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              _buildProgressBarStat('Scrum', scrum),
              _buildProgressBarStat('Line', line),
              _buildProgressBarStat('Maul', maul),
              _buildProgressBarStat('Salida', salida),
              pw.SizedBox(height: 10),

              pw.Text('DEFENSA Y PATEO', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              _buildProgressBarStat('Tackles efectivos', tackles),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
                child: pw.Text('Conversiones: 0% (0/0) - Sin datos', style: const pw.TextStyle(fontSize: 11)),
              ),
              pw.SizedBox(height: 10),

              pw.Text('PUNTOS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
                child: pw.Text('Tries: $tries ($totalPuntos puntos)', style: const pw.TextStyle(fontSize: 11)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
                child: pw.Text('Puntos por minuto: $ptsPorMinuto', style: const pw.TextStyle(fontSize: 11)),
              ),
              pw.SizedBox(height: 10),

              pw.Text('DISCIPLINA', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              _buildSimpleLine('Errores no forzados:', errores.toString()),
              _buildSimpleLine('Penales cometidos:', penales.toString()),
              _buildIndentedLine('- Inconducta: 0'),
              _buildIndentedLine('- Offside: 0'),
              _buildIndentedLine('- Ruck: 0'),
              _buildIndentedLine('- Scrum: 0'),
              _buildIndentedLine('- Otro: $penales'),
              _buildSimpleLine('Tarjetas amarillas:', tarjetasAmarillas.toString()),
              _buildSimpleLine('Tarjetas rojas:', tarjetasRojas.toString()),
              pw.SizedBox(height: 20),

              pw.Spacer(),
              pw.Center(
                child: pw.Text('Generado el $fecha a las $hora', style: const pw.TextStyle(fontSize: 9)),
              )
            ],
          );
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
