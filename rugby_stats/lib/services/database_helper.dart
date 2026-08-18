import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/usuario.dart'; // Importa tu modelo para poder usarlo aquí
import '../models/partido.dart';
import '../models/accion.dart'; 
import '../models/tipo_accion.dart';
import '../models/reporte.dart'; 
import 'dart:convert'; // Necesario para utf8
import 'package:crypto/crypto.dart'; 

class DatabaseHelper {
  // Patrón Singleton: Asegura que solo exista una instancia de la base de datos en toda la app
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Función para obtener la base de datos (la abre si no está abierta)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('RugbyStats.db');
    return _database!;
  }

  // Configura la ruta y abre el archivo .db
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path);
  }

  // La función real que hará el INSERT
    Future<int> insertUsuario(Usuario usuario) async {
    final db = await instance.database;
    // 1. Convertimos la contraseña a bytes
    final bytes = utf8.encode(usuario.contrasena); 
    // 2. Generamos el hash SHA-256
    final digest = sha256.convert(bytes);
    // 3. Creamos el mapa con la contraseña original
    Map<String, dynamic> usuarioMap = usuario.toMap(); 
    // 4. SOBREESCRIBIMOS el valor de la contraseña con el hash
    usuarioMap['Contrasena'] = digest.toString(); 
    // 5. INSERTAMOS usando usuarioMap (que ya tiene el hash)
    return await db.insert('Usuario', usuarioMap);
  }

    // Método para insertar un partido
  Future<int> insertPartido(Partido partido) async {
    final db = await instance.database;
    return await db.insert('PARTIDO', partido.toMap());
  }

  Future<bool> emailExists(String email) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'Usuario',
      where: 'Email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty;
  }

  // Método para insertar una acción
  Future<int> insertAccion(Accion accion) async {
    final db = await instance.database;
    return await db.insert('Accion', accion.toMap());
  }

    // Métodos para Tipo_Accion
  Future<int> insertTipoAccion(TipoAccion tipoAccion) async {
    final db = await instance.database;
    return await db.insert('Tipo_Accion', tipoAccion.toMap());
  }

  // Métodos para REPORTE
  Future<int> insertReporte(Reporte reporte) async {
    final db = await instance.database;
    return await db.insert('REPORTE', reporte.toMap());
  }

    // Método para el login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final db = await instance.database;
    // 1. Buscamos el usuario por email
    final List<Map<String, dynamic>> results = await db.query(
      'Usuario',
      where: 'Email = ?',
      whereArgs: [email],
    );
    if (results.isEmpty) {
      return {'success': false, 'message': 'El Gmail no está registrado'};
    }
    // 2. Hash de la contraseña ingresada para comparar
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    final hashedInput = digest.toString();
    // 3. Comparar hashes
    if (results.first['Contrasena'] == hashedInput) {
      // Retornamos éxito y el usuario
      final usuario = Usuario(
        id: results.first['IdUsuario'],
        nombre: results.first['Nombre_Usuario'],
        email: results.first['Email'],
        telefono: results.first['Telefono'],
        contrasena: results.first['Contrasena'],
      );
      return {'success': true, 'user': usuario};
    } else {
      return {'success': false, 'message': 'Contraseña incorrecta'};
    } 
  }

  // --- GESTIÓN DE PARTIDOS ---
  // CU 12: Eliminación con validación de estado
  Future<Map<String, dynamic>> deletePartido(int idPartido) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'PARTIDO', where: 'Id_Partido = ?', whereArgs: [idPartido],
    );
    
    if (results.isEmpty) return {'success': false, 'message': 'Partido no encontrado'};
    
    if (results.first['Estado_partido'] != 'Finalizado') {
      return {'success': false, 'message': 'El partido debe estar Finalizado para eliminarlo'};
    }
    
    await db.delete('PARTIDO', where: 'Id_Partido = ?', whereArgs: [idPartido]);
    return {'success': true, 'message': 'Partido eliminado'};
  }

  // --- GESTIÓN DE ESTADÍSTICAS (CU 29 y Lógica de Pila) ---

  // Obtener acciones para listar en pantalla
  Future<List<Map<String, dynamic>>> getAccionesByPartido(int idPartido) async {
    final db = await instance.database;
    return await db.query('Accion', where: 'Id_Partido = ?', whereArgs: [idPartido], orderBy: 'Orden_Accion ASC');
  }

  // CU 29: Actualizar una acción específica
  Future<int> updateAccion(Accion accion) async {
    final db = await instance.database;
    return await db.update('Accion', accion.toMap(), where: 'IdAccion = ?', whereArgs: [accion.id]);
  }

  // Lógica de "Pila": Deshacer última acción
  Future<void> undoUltimaAccion(int idPartido) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'Accion',
      where: 'Id_Partido = ?',
      whereArgs: [idPartido],
      orderBy: 'Orden_Accion DESC',
      limit: 1,
    );

    if (results.isNotEmpty) {
      int idAccionAEliminar = results.first['IdAccion'];
      await db.delete('Accion', where: 'IdAccion = ?', whereArgs: [idAccionAEliminar]);
    }
  }
}

