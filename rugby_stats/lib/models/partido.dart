class Partido {
  final int? id;
  final String fecha;
  final String equipoVisitante;
  final String equipoLocal;
  final String estado;
  final String torneo;
  final int puntos;
  final String division;
  final int idUsuario; // FK

  Partido({
    this.id,
    required this.fecha,
    required this.equipoVisitante,
    required this.equipoLocal,
    required this.estado,
    required this.torneo,
    required this.puntos,
    required this.division,
    required this.idUsuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'Fecha': fecha,
      'Equipo_Visitante': equipoVisitante,
      'Equipo_local': equipoLocal,
      'Estado_partido': estado,
      'Torneo': torneo,
      'Puntos': puntos,
      'Division': division,
      'Id_Usuario': idUsuario,
    };
  }
}