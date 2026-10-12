import 'package:flutter_test/flutter_test.dart';
import 'package:rugby_stats/services/calculadora_estadisticas.dart';

void main() {
  group('CalculadoraEstadisticas', () {
    final tiposAccion = {
      'Try': 1,
      'Patada': 2,
      'Scrum': 3,
      'Line': 4,
      'Maul': 5,
      'Salida': 6,
      'Penales Cometidos': 7,
      'Tarjeta': 8,
      'Tackle': 9,
      'Error No Forzado': 10,
    };

    test('calcula correctamente penales cometidos y su desglose por tipo', () {
      final acciones = [
        {'Id_Tipo_Accion': 7, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Scrum'},
        {'Id_Tipo_Accion': 7, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Ruck'},
        {'Id_Tipo_Accion': 7, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Ruck'},
        {'Id_Tipo_Accion': 7, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Offside'},
        {'Id_Tipo_Accion': 7, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Inconducta'},
        {'Id_Tipo_Accion': 7, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Otro'},
        // Acción de visitante no debe computarse para el local
        {'Id_Tipo_Accion': 7, 'Equipo_Accion': 'Visitante', 'Resultado_Accion': 'Ruck'},
      ];

      final stats = CalculadoraEstadisticas.calcular(
        acciones: acciones,
        tiposAccion: tiposAccion,
        equipo: 'Local',
      );

      expect(stats.penales.total, equals(6));
      expect(stats.penales.detalle['Scrum'], equals(1));
      expect(stats.penales.detalle['Ruck'], equals(2));
      expect(stats.penales.detalle['Offside'], equals(1));
      expect(stats.penales.detalle['Inconducta'], equals(1));
      expect(stats.penales.detalle['Otro'], equals(1));
    });

    test('calcula correctamente efectividad de patadas (conversiones + penales a palos)', () {
      final acciones = [
        {'Id_Tipo_Accion': 2, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Conversión'},
        {'Id_Tipo_Accion': 2, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Penal a los Palos'},
        {'Id_Tipo_Accion': 2, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Errada'},
        // Acción de visitante no debe computarse para el local
        {'Id_Tipo_Accion': 2, 'Equipo_Accion': 'Visitante', 'Resultado_Accion': 'Conversión'},
      ];

      final stats = CalculadoraEstadisticas.calcular(
        acciones: acciones,
        tiposAccion: tiposAccion,
        equipo: 'Local',
      );

      expect(stats.patadas.total, equals(3));
      expect(stats.patadas.convertidos, equals(2));
      expect(stats.patadas.conversiones, equals(1));
      expect(stats.patadas.penalesPalos, equals(1));
      expect(stats.patadas.erradas, equals(1));
      expect(stats.patadas.porcentaje, equals(67)); // 2 / 3 * 100 = 66.66 -> 67
    });

    test('calcula correctamente tarjetas amarillas y rojas', () {
      final acciones = [
        {'Id_Tipo_Accion': 8, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Amarilla'},
        {'Id_Tipo_Accion': 8, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Amarilla'},
        {'Id_Tipo_Accion': 8, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Roja'},
      ];

      final stats = CalculadoraEstadisticas.calcular(
        acciones: acciones,
        tiposAccion: tiposAccion,
        equipo: 'Local',
      );

      expect(stats.tarjetas.total, equals(3));
      expect(stats.tarjetas.amarillas, equals(2));
      expect(stats.tarjetas.rojas, equals(1));
    });

    test('retorna 0% y sin datos cuando no hay acciones registradas', () {
      final stats = CalculadoraEstadisticas.calcular(
        acciones: [],
        tiposAccion: tiposAccion,
        equipo: 'Local',
      );

      expect(stats.patadas.total, equals(0));
      expect(stats.patadas.convertidos, equals(0));
      expect(stats.patadas.porcentaje, equals(0));
      expect(stats.patadas.alerta, equals('Sin datos'));

      expect(stats.penales.total, equals(0));
      expect(stats.penales.detalle['Ruck'], equals(0));

      expect(stats.tarjetas.total, equals(0));
    });

    test('calcula formaciones fijas con obtención propia y pelotas robadas al rival', () {
      final acciones = [
        // Scrums propios de Alma (Local)
        {'Id_Tipo_Accion': 3, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Ganada'},
        {'Id_Tipo_Accion': 3, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Ganada'},
        {'Id_Tipo_Accion': 3, 'Equipo_Accion': 'Local', 'Resultado_Accion': 'Perdida'},
        // Scrums del Rival (Visitante)
        {'Id_Tipo_Accion': 3, 'Equipo_Accion': 'Visitante', 'Resultado_Accion': 'Ganada'}, // Robada por Alma
        {'Id_Tipo_Accion': 3, 'Equipo_Accion': 'Visitante', 'Resultado_Accion': 'Perdida'}, // Retenida por rival
      ];

      final statsAlma = CalculadoraEstadisticas.calcular(
        acciones: acciones,
        tiposAccion: tiposAccion,
        equipo: 'Local',
      );

      // Obtención propia de Alma: 2 ganados de 3 (67%)
      expect(statsAlma.scrum.total, equals(3));
      expect(statsAlma.scrum.ganados, equals(2));
      expect(statsAlma.scrum.porcentaje, equals(67));

      // Robadas al rival por Alma: 1 ganada/robada de 2 del rival (50%)
      expect(statsAlma.scrum.rivalTotal, equals(2));
      expect(statsAlma.scrum.rivalRobados, equals(1));
      expect(statsAlma.scrum.rivalPorcentaje, equals(50));
    });

    test('calcula correctamente estadísticas del equipo rival', () {
      final acciones = [
        {'Id_Tipo_Accion': 1, 'Equipo_Accion': 'Visitante', 'Resultado_Accion': 'Try'},
        {'Id_Tipo_Accion': 1, 'Equipo_Accion': 'Visitante', 'Resultado_Accion': 'Try'},
        {'Id_Tipo_Accion': 10, 'Equipo_Accion': 'Visitante', 'Resultado_Accion': 'Error'},
        {'Id_Tipo_Accion': 7, 'Equipo_Accion': 'Visitante', 'Resultado_Accion': 'Offside'},
        {'Id_Tipo_Accion': 8, 'Equipo_Accion': 'Visitante', 'Resultado_Accion': 'Amarilla'},
      ];

      final statsRival = CalculadoraEstadisticas.calcular(
        acciones: acciones,
        tiposAccion: tiposAccion,
        equipo: 'Visitante',
      );

      expect(statsRival.tries, equals(2));
      expect(statsRival.erroresNoForzados, equals(1));
      expect(statsRival.penales.total, equals(1));
      expect(statsRival.penales.detalle['Offside'], equals(1));
      expect(statsRival.tarjetas.amarillas, equals(1));
    });
  });
}
