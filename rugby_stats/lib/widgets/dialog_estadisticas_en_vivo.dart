import 'package:flutter/material.dart';

class DialogEstadisticasEnVivo extends StatelessWidget {
  final List<Map<String, dynamic>> acciones;
  final Map<String, int> tiposAccion;
  final String nombreEquipoLocal;

  const DialogEstadisticasEnVivo({
    super.key,
    required this.acciones,
    required this.tiposAccion,
    required this.nombreEquipoLocal,
  });

  @override
  Widget build(BuildContext context) {
    // Helper para obtener datos de una formación fija (Scrum, Line, Maul, Salida)
    Map<String, dynamic> _getFormacion(String nombreAccion) {
      int? idAccion = tiposAccion[nombreAccion];
      if (idAccion == null) return {'total': 0, 'ganados': 0, 'porcentaje': 0};

      final accionesLocal = acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == 'Local');
      final total = accionesLocal.length;
      final ganados = accionesLocal.where((a) => a['Resultado_Accion'] == 'Ganada').length;
      
      final porcentaje = total == 0 ? 0 : ((ganados / total) * 100).round();
      return {'total': total, 'ganados': ganados, 'porcentaje': porcentaje};
    }

    // Helper para Tackles Efectivos
    Map<String, dynamic> _getTackles() {
      int? idAccion = tiposAccion['Tackle'];
      if (idAccion == null) return {'total': 0, 'positivos': 0, 'porcentaje': 0};

      final accionesLocal = acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == 'Local');
      final total = accionesLocal.length;
      final positivos = accionesLocal.where((a) => a['Resultado_Accion'] == 'Positivo').length;
      
      final porcentaje = total == 0 ? 0 : ((positivos / total) * 100).round();
      return {'total': total, 'positivos': positivos, 'porcentaje': porcentaje};
    }

    // Helper para Patadas y Penales a los palos convertidos
    Map<String, dynamic> _getConversiones() {
      int? idAccion = tiposAccion['Patada'];
      if (idAccion == null) return {'total': 0, 'convertidos': 0, 'porcentaje': 0};

      final accionesLocal = acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == 'Local');
      final total = accionesLocal.length; // Suma Conversión + Penal a los Palos + Errada
      final convertidos = accionesLocal.where((a) => 
        a['Resultado_Accion'] == 'Conversión' || a['Resultado_Accion'] == 'Penal a los Palos'
      ).length;
      
      final porcentaje = total == 0 ? 0 : ((convertidos / total) * 100).round();
      return {'total': total, 'convertidos': convertidos, 'porcentaje': porcentaje};
    }

    // Helper para conteos simples (Tries, Errores no forzados)
    int _getCount(String nombreAccion) {
      int? idAccion = tiposAccion[nombreAccion];
      if (idAccion == null) return 0;
      return acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == 'Local').length;
    }

    final sScrum = _getFormacion('Scrum');
    final sLine = _getFormacion('Line');
    final sMaul = _getFormacion('Maul');
    final sSalida = _getFormacion('Salida');
    
    final sTackles = _getTackles();
    final sConversiones = _getConversiones();
    
    final tTries = _getCount('Try');
    final tErrores = _getCount('Error No Forzado');

    Widget _buildStatRow(String label, Map<String, dynamic> stat, String valKey) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text(
              '${stat[valKey]}/${stat['total']}   ${stat['porcentaje']}%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      );
    }

    Widget _buildSimpleRow(String label, int count) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      );
    }

    Widget _buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'ESTADÍSTICAS DE ${nombreEquipoLocal.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(height: 32),
            
            // Contenido escroleable
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('EFECTIVIDAD'),
                    _buildStatRow('Scrum', sScrum, 'ganados'),
                    const Divider(height: 1),
                    _buildStatRow('Line', sLine, 'ganados'),
                    const Divider(height: 1),
                    _buildStatRow('Maul', sMaul, 'ganados'),
                    const Divider(height: 1),
                    _buildStatRow('Salida', sSalida, 'ganados'),
                    const Divider(height: 1),

                    _buildSectionTitle('DEFENSA Y PATEO'),
                    _buildStatRow('Tackles Efectivos', sTackles, 'positivos'),
                    const Divider(height: 1),
                    _buildStatRow('Conversiones (Patadas + Penales)', sConversiones, 'convertidos'),
                    const Divider(height: 1),

                    _buildSectionTitle('PUNTOS'),
                    _buildSimpleRow('Tries', tTries),
                    const Divider(height: 1),

                    _buildSectionTitle('DISCIPLINA'),
                    _buildSimpleRow('Errores No Forzados', tErrores),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            // Botón inferior
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('CERRAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            )
          ],
        ),
      ),
    );
  }
}
