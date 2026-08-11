import 'package:flutter/material.dart';

enum Categoria { preIntermedia, intermedia, primera }

class Partido {
  final int? idPartido; // Cambiado a int? para reflejar autoincrement
  final String fecha; // Guardado como ISO8601 String
  final String equipoVisitante;
  final String equipoLocal;
  final String estadoPartido;
  final String torneo;
  final int puntosLocal;
  final int puntosVisitante;
  final String division;
  final int? idUsuario;

  // Campos de UI (NO se guardan en la tabla PARTIDO)
  final Categoria categoria;
  final String resultado; 

  Partido({
    this.idPartido,
    required this.fecha,
    required this.equipoVisitante,
    required this.equipoLocal,
    required this.estadoPartido,
    required this.torneo,
    required this.puntosLocal,
    required this.puntosVisitante,
    required this.division,
    this.idUsuario,
    required this.categoria,
    required this.resultado,
  });

  Color get color {
    switch (categoria) {
      case Categoria.preIntermedia:
        return Colors.blue;
      case Categoria.intermedia:
        return Colors.green;
      case Categoria.primera:
        return Colors.red;
    }
  }

  String get categoriaLabel {
    switch (categoria) {
      case Categoria.preIntermedia:
        return 'PRE-INTERMEDIA';
      case Categoria.intermedia:
        return 'INTERMEDIA';
      case Categoria.primera:
        return 'PRIMERA';
    }
  }

    Map<String, dynamic> toMap() {
    return {
      'Id_Partido': idPartido,
      'Fecha': fecha,
      'Equipo_Visitante': equipoVisitante,
      'Equipo_local': equipoLocal,
      'Estado_partido': estadoPartido,
      'Torneo': torneo,
      'Puntos_local': puntosLocal,
      'Puntos_visitante': puntosVisitante,
      'Division': division,
      'Id_Usuario': idUsuario,
    };
  }
}
