import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/usuario.dart';
import '../models/partido.dart';
import '../models/accion.dart';
import '../models/tipo_accion.dart';
import '../models/reporte.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const String _createDbQuery = '''
    CREATE TABLE Tipo_Accion (
      Id_Tipo_Accion INTEGER PRIMARY KEY AUTOINCREMENT,
      Nombre TEXT NOT NULL UNIQUE
    );
    CREATE TABLE Usuario (
      IdUsuario INTEGER PRIMARY KEY AUTOINCREMENT,
      Nombre_Usuario TEXT NOT NULL,
      Contrasena TEXT,
      Email TEXT UNIQUE,
      Telefono TEXT
    );
    CREATE TABLE PARTIDO (
      Id_Partido INTEGER PRIMARY KEY AUTOINCREMENT,
      Fecha TEXT,
      Equipo_Visitante TEXT,
      Equipo_local TEXT,
      Estado_partido TEXT,
      Torneo TEXT,
      Puntos_local INTEGER DEFAULT 0,
      Puntos_visitante INTEGER DEFAULT 0,
      Division TEXT,
      Id_Usuario INTEGER REFERENCES Usuario(IdUsuario) ON DELETE SET NULL
    );
    CREATE TABLE Accion (
      IdAccion INTEGER PRIMARY KEY AUTOINCREMENT,
      Resultado_Accion TEXT,
      Id_Tipo_Accion INTEGER REFERENCES Tipo_Accion(Id_Tipo_Accion) ON DELETE SET NULL,
      Tiempo_Accion TEXT,
      Orden_Accion INTEGER,
      Equipo_Accion TEXT,
      Id_Partido INTEGER REFERENCES PARTIDO(Id_Partido) ON DELETE CASCADE
    );
    CREATE TABLE REPORTE (
      ID_Reporte INTEGER PRIMARY KEY AUTOINCREMENT,
      Contenido_Reporte TEXT,
      Fecha_Generacion TEXT,
      Nombre TEXT,
      Tipo_Reporte TEXT,
      Id_Partido INTEGER REFERENCES PARTIDO(Id_Partido) ON DELETE CASCADE
    );
    CREATE INDEX idx_accion_partido ON Accion(Id_Partido);
    CREATE INDEX idx_reporte_partido ON REPORTE(Id_Partido);
    CREATE INDEX idx_partido_usuario ON PARTIDO(Id_Usuario);
  ''';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('RugbyStats.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    print('--- RUTA DE LA BD: $path ---');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        List<String> queries = _createDbQuery.split(';');
        for (String query in queries) {
          if (query.trim().isNotEmpty) {
            await db.execute(query);
          }
        }
      },
    );
  }

  Future<int> insertUsuario(Usuario usuario) async {
    final db = await instance.database;
    final bytes = utf8.encode(usuario.contrasena); 
    final digest = sha256.convert(bytes);
    Map<String, dynamic> usuarioMap = usuario.toMap(); 
    usuarioMap['Contrasena'] = digest.toString(); 
    return await db.insert('Usuario', usuarioMap);
  }

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

  Future<int> insertAccion(Accion accion) async {
    final db = await instance.database;
    return await db.insert('Accion', accion.toMap());
  }

  Future<int> insertTipoAccion(TipoAccion tipoAccion) async {
    final db = await instance.database;
    return await db.insert('Tipo_Accion', tipoAccion.toMap());
  }

  Future<int> insertReporte(Reporte reporte) async {
    final db = await instance.database;
    return await db.insert('REPORTE', reporte.toMap());
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'Usuario',
      where: 'Email = ?',
      whereArgs: [email],
    );
    if (results.isEmpty) {
      return {'success': false, 'message': 'El Email no está registrado'};
    }
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    final hashedInput = digest.toString();
    if (results.first['Contrasena'] == hashedInput) {
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

  Future<List<Partido>> getPartidos({String? division, String? fechaDesde, String? fechaHasta}) async {
    final db = await instance.database;
    String whereString = "";
    List<dynamic> whereArgs = [];

    if (division != null && division.isNotEmpty) {
      whereString += "Division COLLATE NOCASE = ? ";
      whereArgs.add(division);
    }
    
    if (fechaDesde != null && fechaDesde.isNotEmpty) {
      if (whereString.isNotEmpty) whereString += " AND ";
      whereString += "Fecha >= ? ";
      whereArgs.add(fechaDesde);
    }
    if (fechaHasta != null && fechaHasta.isNotEmpty) {
      if (whereString.isNotEmpty) whereString += " AND ";
      whereString += "Fecha <= ? ";
      whereArgs.add("${fechaHasta}T23:59:59.999");
    }

    final List<Map<String, dynamic>> results = await db.query(
      'PARTIDO',
      where: whereString.isNotEmpty ? whereString : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'Fecha DESC'
    );
    return results.map((map) => Partido.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getAccionesByPartido(int idPartido) async {
    final db = await instance.database;
    return await db.query('Accion', where: 'Id_Partido = ?', whereArgs: [idPartido], orderBy: 'Orden_Accion ASC');
  }
  //filtrar partidos
  Future<List<Map<String, dynamic>>> getPartidosFiltrados(
      String? division, String? fechaDesde, String? fechaHasta) async {
    final db = await instance.database;

    // Construcción dinámica de la query
    String query = 'SELECT * FROM PARTIDO WHERE 1=1';
    List<dynamic> args = [];

    if (division != null && division.isNotEmpty) {
      query += ' AND Division = ?';
      args.add(division);
    }
    if (fechaDesde != null && fechaDesde.isNotEmpty) {
      query += ' AND Fecha >= ?';
      args.add(fechaDesde);
    }
    if (fechaHasta != null && fechaHasta.isNotEmpty) {
      query += ' AND Fecha <= ?';
      args.add(fechaHasta);
    }

    return await db.rawQuery(query, args);
  }
  

  Future<int> updateAccion(Accion accion) async {
    final db = await instance.database;
    return await db.update('Accion', accion.toMap(), where: 'IdAccion = ?', whereArgs: [accion.id]);
  }

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

  // --- EXPORTAR A JSON ---
  Future<String> exportDatabaseToJson() async {
    final db = await instance.database;
    
    final usuarios = await db.query('Usuario');
    final partidos = await db.query('PARTIDO');
    final acciones = await db.query('Accion');
    final tiposAccion = await db.query('Tipo_Accion');
    final reportes = await db.query('REPORTE');

    final data = {
      'Usuario': usuarios,
      'PARTIDO': partidos,
      'Accion': acciones,
      'Tipo_Accion': tiposAccion,
      'REPORTE': reportes,
      'export_date': DateTime.now().toIso8601String(),
    };

    return jsonEncode(data);
  }

  // --- IMPORTAR DESDE JSON (Reemplazo total) ---
  Future<void> importDatabaseFromJson(String jsonString) async {
    final db = await instance.database;
    final Map<String, dynamic> data = jsonDecode(jsonString);

    await db.transaction((txn) async {
      // 1. Limpiamos las tablas actuales
      await txn.delete('Accion');
      await txn.delete('REPORTE');
      await txn.delete('PARTIDO');
      await txn.delete('Usuario');
      await txn.delete('Tipo_Accion');

      // 2. Insertamos los nuevos datos
      for (var item in (data['Tipo_Accion'] as List)) {
        await txn.insert('Tipo_Accion', item as Map<String, dynamic>);
      }
      for (var item in (data['Usuario'] as List)) {
        await txn.insert('Usuario', item as Map<String, dynamic>);
      }
      for (var item in (data['PARTIDO'] as List)) {
        await txn.insert('PARTIDO', item as Map<String, dynamic>);
      }
      for (var item in (data['Accion'] as List)) {
        await txn.insert('Accion', item as Map<String, dynamic>);
      }
      for (var item in (data['REPORTE'] as List)) {
        await txn.insert('REPORTE', item as Map<String, dynamic>);
      }
    });
  }
}