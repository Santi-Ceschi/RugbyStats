import 'package:flutter/material.dart';
import '../models/partido.dart';
import 'package:intl/intl.dart';

class PartidoCard extends StatelessWidget {
  final Partido partido;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onPlay;
  final VoidCallback? onTap;
  final VoidCallback? onEditMetadatos;

  const PartidoCard({
    super.key,
    required this.partido,
    required this.onEdit,
    required this.onDelete,
    this.onPlay,
    this.onTap,
    this.onEditMetadatos,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
      child: Row(
        children: [
          // Franja de color
          Container(
            width: 4,
            height: 50,
            color: partido.color,
          ),
          const SizedBox(width: 16),
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(partido.categoriaLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                Text('vs ${partido.equipoVisitante}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(DateFormat('d MMM yyyy').format(DateTime.parse(partido.fecha)),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          // Marcador
          Column(
            children: [
              Text('${partido.puntosLocal} - ${partido.puntosVisitante}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(partido.resultado, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 16),
          // Acciones
          if (partido.estadoPartido == 'En curso' && onPlay != null)
            IconButton(
              icon: const Icon(Icons.play_circle_fill, color: Colors.green, size: 28),
              onPressed: onPlay,
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Opciones de edición',
            onSelected: (value) {
              if (value == 'metadatos') {
                if (onEditMetadatos != null) {
                  onEditMetadatos!();
                } else {
                  onEdit();
                }
              } else if (value == 'estadisticas') {
                onEdit();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'metadatos',
                child: Row(
                  children: [
                    Icon(Icons.edit_note, size: 18),
                    SizedBox(width: 8),
                    Text('Editar datos del partido', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              if (partido.estadoPartido == 'Finalizado')
                const PopupMenuItem(
                  value: 'estadisticas',
                  child: Row(
                    children: [
                      Icon(Icons.sports_score, size: 18),
                      SizedBox(width: 8),
                      Text('Editar acciones / estadísticas', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
            ],
          ),
          IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: onDelete),
        ],
      ),
    ));
  }
}
