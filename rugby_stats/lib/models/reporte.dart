class Reporte {
  final int? id;
  final String contenido;
  final String fechaGeneracion;
  final String nombre;
  final String tipoReporte;
  final int idPartido; // FK

  Reporte({
    this.id,
    required this.contenido,
    required this.fechaGeneracion,
    required this.nombre,
    required this.tipoReporte,
    required this.idPartido,
  });

  Map<String, dynamic> toMap() {
    return {
      'Contenido_Reporte': contenido,
      'Fecha_Generacion': fechaGeneracion,
      'Nombre': nombre,
      'Tipo_Reporte': tipoReporte,
      'Id_Partido': idPartido,
    };
  }
}