<<<<<<< HEAD
import 'package:flutter/material.dart';

enum Categoria { preIntermedia, intermedia, primera }

class Partido {
  final String id;
  final Categoria categoria;
  final String oponente;
  final DateTime fecha;
  final int scoreLocal;
  final int scoreVisitante;
  final String resultado; // e.g., "Victoria"

  Partido({
    required this.id,
    required this.categoria,
    required this.oponente,
    required this.fecha,
    required this.scoreLocal,
    required this.scoreVisitante,
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
}
=======
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
>>>>>>> main
