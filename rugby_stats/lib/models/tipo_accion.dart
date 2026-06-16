class TipoAccion {
  final int? id;
  final String nombre;

  TipoAccion({this.id, required this.nombre});

  Map<String, dynamic> toMap() {
    return {
      'Nombre': nombre,
    };
  }
}