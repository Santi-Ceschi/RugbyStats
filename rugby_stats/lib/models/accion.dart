class Accion {
  final int? id;
  final String resultadoAccion;
  final int idTipoAccion; // FK
  final String tiempoAccion;
  final int ordenAccion;
  final String equipoAccion;
  final int idPartido; // FK

  Accion({
    this.id,
    required this.resultadoAccion,
    required this.idTipoAccion,
    required this.tiempoAccion,
    required this.ordenAccion,
    required this.equipoAccion,
    required this.idPartido,
  });

  Map<String, dynamic> toMap() {
    return {
      'Resultado_Accion': resultadoAccion,
      'Id_Tipo_Accion': idTipoAccion,
      'Tiempo_Accion': tiempoAccion,
      'Orden_Accion': ordenAccion,
      'Equipo_Accion': equipoAccion,
      'Id_Partido': idPartido,
    };
  }
}