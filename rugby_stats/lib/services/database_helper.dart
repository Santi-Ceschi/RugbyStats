import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/usuario.dart'; // Importa tu modelo para poder usarlo aquí
import '../models/partido.dart';
import '../models/accion.dart'; 
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
      final bytes = utf8.encode(usuario.contrasena); // 1. Convertimos la contraseña a bytes
      final digest = sha256.convert(bytes);// 2. Generamos el hash SHA-256
      Map<String, dynamic> usuarioMap = usuario.toMap();// 3. Creamos un nuevo mapa con la contraseña encriptada (hash)
      usuarioMap['Contrasena'] = digest.toString(); 
    // Aquí es donde usamos el toMap() que creamos antes
    return await db.insert('Usuario', usuario.toMap());
  }

      // Método para insertar un partido
  Future<int> insertPartido(Partido partido) async {
    final db = await instance.database;
    return await db.insert('PARTIDO', partido.toMap());
  }

    Future<int> insertAccion(Accion accion) async {
    final db = await instance.database;
    return await db.insert('Accion', accion.toMap());
  }
}

