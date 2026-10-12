import 'package:flutter/material.dart';
import '../services/calculadora_estadisticas.dart';

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
    final stats = CalculadoraEstadisticas.calcular(
      acciones: acciones,
      tiposAccion: tiposAccion,
      equipo: 'Local',
    );

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
                    _buildSectionTitle('EFECTIVIDAD EN FORMACIONES'),
                    _buildStatRow('Scrum', stats.scrum.toMap(), 'ganados'),
                    const Divider(height: 1),
                    _buildStatRow('Line', stats.line.toMap(), 'ganados'),
                    const Divider(height: 1),
                    _buildStatRow('Maul', stats.maul.toMap(), 'ganados'),
                    const Divider(height: 1),
                    _buildStatRow('Salida', stats.salida.toMap(), 'ganados'),
                    const Divider(height: 1),

                    _buildSectionTitle('DEFENSA Y PATEO'),
                    _buildStatRow('Tackles Efectivos', stats.tackles.toMap(), 'ganados'),
                    const Divider(height: 1),
                    _buildStatRow('Efectividad en Patadas', stats.patadas.toMap(), 'convertidos'),
                    if (stats.patadas.total > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Conversiones: ${stats.patadas.conversiones} | Penales: ${stats.patadas.penalesPalos} | Erradas: ${stats.patadas.erradas}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                    const Divider(height: 1),

                    _buildSectionTitle('PUNTOS'),
                    _buildSimpleRow('Tries Anotados', stats.tries),
                    const Divider(height: 1),

                    _buildSectionTitle('DISCIPLINA'),
                    _buildSimpleRow('Errores No Forzados', stats.erroresNoForzados),
                    const Divider(height: 1),
                    _buildSimpleRow('Penales Cometidos', stats.penales.total),
                    if (stats.penales.total > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: stats.penales.detalle.entries.map((e) {
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
                      ),
                    const Divider(height: 1),
                    _buildSimpleRow('Tarjetas (🟨 ${stats.tarjetas.amarillas} / 🟥 ${stats.tarjetas.rojas})', stats.tarjetas.total),
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
