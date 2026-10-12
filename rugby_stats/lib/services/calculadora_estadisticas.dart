class FormacionStat {
  // 1. Obtención propia de Alma Juniors
  final int total;
  final int ganados;
  final int porcentaje;
  final String alerta;

  // 2. Recuperación / Robadas en lanzamientos del Rival
  final int rivalTotal;
  final int rivalRobados;
  final int rivalPorcentaje;

  const FormacionStat({
    required this.total,
    required this.ganados,
    required this.porcentaje,
    required this.alerta,
    this.rivalTotal = 0,
    this.rivalRobados = 0,
    this.rivalPorcentaje = 0,
  });

  Map<String, dynamic> toMap() => {
    'total': total,
    'ganados': ganados,
    'porcentaje': porcentaje,
    'alerta': alerta,
    'rivalTotal': rivalTotal,
    'rivalRobados': rivalRobados,
    'rivalPorcentaje': rivalPorcentaje,
  };
}

class PatadaStat {
  final int total;
  final int convertidos;
  final int porcentaje;
  final String alerta;
  final int conversiones;
  final int penalesPalos;
  final int erradas;

  const PatadaStat({
    required this.total,
    required this.convertidos,
    required this.porcentaje,
    required this.alerta,
    required this.conversiones,
    required this.penalesPalos,
    required this.erradas,
  });

  Map<String, dynamic> toMap() => {
    'total': total,
    'ganados': convertidos, // Compatibilidad con widgets de barra de progreso
    'convertidos': convertidos,
    'porcentaje': porcentaje,
    'alerta': alerta,
    'conversiones': conversiones,
    'penalesPalos': penalesPalos,
    'erradas': erradas,
  };
}

class PenalesStat {
  final int total;
  final Map<String, int> detalle; // Inconducta, Offside, Ruck, Scrum, Otro

  const PenalesStat({
    required this.total,
    required this.detalle,
  });
}

class TarjetasStat {
  final int total;
  final int amarillas;
  final int rojas;

  const TarjetasStat({
    required this.total,
    required this.amarillas,
    required this.rojas,
  });
}

class EstadisticasPartido {
  final FormacionStat scrum;
  final FormacionStat line;
  final FormacionStat maul;
  final FormacionStat salida;
  final FormacionStat tackles;
  final PatadaStat patadas;
  final int tries;
  final int erroresNoForzados;
  final PenalesStat penales;
  final TarjetasStat tarjetas;

  const EstadisticasPartido({
    required this.scrum,
    required this.line,
    required this.maul,
    required this.salida,
    required this.tackles,
    required this.patadas,
    required this.tries,
    required this.erroresNoForzados,
    required this.penales,
    required this.tarjetas,
  });
}

class CalculadoraEstadisticas {
  static EstadisticasPartido calcular({
    required List<Map<String, dynamic>> acciones,
    required Map<String, int> tiposAccion,
    String equipo = 'Local',
  }) {
    return EstadisticasPartido(
      scrum: _calcularFormacion(acciones, tiposAccion, 'Scrum', equipo),
      line: _calcularFormacion(acciones, tiposAccion, 'Line', equipo),
      maul: _calcularFormacion(acciones, tiposAccion, 'Maul', equipo),
      salida: _calcularFormacion(acciones, tiposAccion, 'Salida', equipo),
      tackles: _calcularTackles(acciones, tiposAccion, equipo),
      patadas: _calcularPatadas(acciones, tiposAccion, equipo),
      tries: _contarAccion(acciones, tiposAccion, 'Try', equipo),
      erroresNoForzados: _contarAccion(acciones, tiposAccion, 'Error No Forzado', equipo),
      penales: _calcularPenales(acciones, tiposAccion, equipo),
      tarjetas: _calcularTarjetas(acciones, tiposAccion, equipo),
    );
  }

  static FormacionStat _calcularFormacion(
    List<Map<String, dynamic>> acciones,
    Map<String, int> tiposAccion,
    String nombre,
    String equipo,
  ) {
    int? idAccion = tiposAccion[nombre];
    if (idAccion == null) {
      return const FormacionStat(total: 0, ganados: 0, porcentaje: 0, alerta: 'Sin datos');
    }

    final filtradas = acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == equipo);
    int total = filtradas.length;
    int ganados = filtradas.where((a) => a['Resultado_Accion'] == 'Ganada').length;
    int porcentaje = total == 0 ? 0 : ((ganados / total) * 100).round();

    // Obtener también lanzamientos del oponente para medir robos/pescas defensivas
    final otroEquipo = equipo == 'Local' ? 'Visitante' : 'Local';
    final rivales = acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == otroEquipo);
    int rivalTotal = rivales.length;
    int rivalRobados = rivales.where((a) => a['Resultado_Accion'] == 'Ganada').length;
    int rivalPorcentaje = rivalTotal == 0 ? 0 : ((rivalRobados / rivalTotal) * 100).round();

    return FormacionStat(
      total: total,
      ganados: ganados,
      porcentaje: porcentaje,
      alerta: _obtenerAlertaTextual(porcentaje, total),
      rivalTotal: rivalTotal,
      rivalRobados: rivalRobados,
      rivalPorcentaje: rivalPorcentaje,
    );
  }

  static FormacionStat _calcularTackles(
    List<Map<String, dynamic>> acciones,
    Map<String, int> tiposAccion,
    String equipo,
  ) {
    int? idAccion = tiposAccion['Tackle'];
    if (idAccion == null) {
      return const FormacionStat(total: 0, ganados: 0, porcentaje: 0, alerta: 'Sin datos');
    }

    final filtradas = acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == equipo);
    int total = filtradas.length;
    int ganados = filtradas.where((a) => a['Resultado_Accion'] == 'Positivo').length;
    int porcentaje = total == 0 ? 0 : ((ganados / total) * 100).round();

    return FormacionStat(
      total: total,
      ganados: ganados,
      porcentaje: porcentaje,
      alerta: _obtenerAlertaTextual(porcentaje, total),
    );
  }

  static PatadaStat _calcularPatadas(
    List<Map<String, dynamic>> acciones,
    Map<String, int> tiposAccion,
    String equipo,
  ) {
    int? idAccion = tiposAccion['Patada'];
    if (idAccion == null) {
      return const PatadaStat(
        total: 0,
        convertidos: 0,
        porcentaje: 0,
        alerta: 'Sin datos',
        conversiones: 0,
        penalesPalos: 0,
        erradas: 0,
      );
    }

    final filtradas = acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == equipo);
    int total = filtradas.length;
    int conversiones = filtradas.where((a) => a['Resultado_Accion'] == 'Conversión' || a['Resultado_Accion'] == 'Conversion').length;
    int penalesPalos = filtradas.where((a) => a['Resultado_Accion'] == 'Penal a los Palos').length;
    int erradas = filtradas.where((a) => a['Resultado_Accion'] == 'Errada').length;

    int convertidos = conversiones + penalesPalos;
    int porcentaje = total == 0 ? 0 : ((convertidos / total) * 100).round();

    return PatadaStat(
      total: total,
      convertidos: convertidos,
      porcentaje: porcentaje,
      alerta: _obtenerAlertaTextual(porcentaje, total),
      conversiones: conversiones,
      penalesPalos: penalesPalos,
      erradas: erradas,
    );
  }

  static PenalesStat _calcularPenales(
    List<Map<String, dynamic>> acciones,
    Map<String, int> tiposAccion,
    String equipo,
  ) {
    int? idAccion = tiposAccion['Penales Cometidos'];
    Map<String, int> detalle = {
      'Inconducta': 0,
      'Offside': 0,
      'Ruck': 0,
      'Scrum': 0,
      'Otro': 0,
    };

    if (idAccion == null) {
      return PenalesStat(total: 0, detalle: detalle);
    }

    final filtradas = acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == equipo);
    int total = filtradas.length;

    for (var a in filtradas) {
      String resultado = (a['Resultado_Accion'] ?? '').toString().trim();
      if (detalle.containsKey(resultado)) {
        detalle[resultado] = detalle[resultado]! + 1;
      } else {
        detalle['Otro'] = detalle['Otro']! + 1;
      }
    }

    return PenalesStat(total: total, detalle: detalle);
  }

  static TarjetasStat _calcularTarjetas(
    List<Map<String, dynamic>> acciones,
    Map<String, int> tiposAccion,
    String equipo,
  ) {
    int? idAccion = tiposAccion['Tarjeta'];
    if (idAccion == null) {
      return const TarjetasStat(total: 0, amarillas: 0, rojas: 0);
    }

    final filtradas = acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == equipo);
    int amarillas = filtradas.where((a) => a['Resultado_Accion'] == 'Amarilla').length;
    int rojas = filtradas.where((a) => a['Resultado_Accion'] == 'Roja').length;

    return TarjetasStat(
      total: filtradas.length,
      amarillas: amarillas,
      rojas: rojas,
    );
  }

  static int _contarAccion(
    List<Map<String, dynamic>> acciones,
    Map<String, int> tiposAccion,
    String nombre,
    String equipo,
  ) {
    int? idAccion = tiposAccion[nombre];
    if (idAccion == null) return 0;
    return acciones.where((a) => a['Id_Tipo_Accion'] == idAccion && a['Equipo_Accion'] == equipo).length;
  }

  static String _obtenerAlertaTextual(int porcentaje, int total) {
    if (total == 0) return 'Sin datos';
    if (porcentaje < 50) return 'Necesita mejorar';
    if (porcentaje <= 80) return 'Estable';
    return 'Excelente';
  }
}
