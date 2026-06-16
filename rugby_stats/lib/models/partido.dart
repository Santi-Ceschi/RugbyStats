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

  // Campos adicionales para la base de datos
  final String? torneo;
  final String? division;
  final int? idUsuario;

  Partido({
    required this.id,
    required this.categoria,
    required this.oponente,
    required this.fecha,
    required this.scoreLocal,
    required this.scoreVisitante,
    required this.resultado,
    this.torneo,
    this.division,
    this.idUsuario,
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
      'id': id,
      'categoria': categoria.index,
      'oponente': oponente,
      'fecha': fecha.toIso8601String(),
      'scoreLocal': scoreLocal,
      'scoreVisitante': scoreVisitante,
      'resultado': resultado,
      'torneo': torneo,
      'division': division,
      'idUsuario': idUsuario,
    };
  }
}
