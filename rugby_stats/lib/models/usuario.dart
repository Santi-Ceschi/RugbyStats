class Usuario {
  final int? id;
  final String nombre;
  final String email;
  final String telefono;
  final String contrasena;

  Usuario({
    this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.contrasena,
  });

  Map<String, dynamic> toMap() {
    return {
      'Nombre_Usuario': nombre,
      'Email': email,
      'Telefono': telefono,
      'Contrasena': contrasena,
    };
  }
}