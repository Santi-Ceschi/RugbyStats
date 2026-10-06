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

  factory Accion.fromMap(Map<String, dynamic> map) {
    return Accion(
      id: map['IdAccion'],
      resultadoAccion: map['Resultado_Accion'] ?? '',
      idTipoAccion: map['Id_Tipo_Accion'],
      tiempoAccion: map['Tiempo_Accion'] ?? '',
      ordenAccion: map['Orden_Accion'] ?? 0,
      equipoAccion: map['Equipo_Accion'] ?? '',
      idPartido: map['Id_Partido'],
    );
  }

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