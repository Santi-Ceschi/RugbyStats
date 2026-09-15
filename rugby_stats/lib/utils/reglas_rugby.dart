class ReglasRugby {
  static List<String> getSubOptions(String actionName) {
    if (actionName == 'Patada') return ['Conversión', 'Penal a los Palos', 'Errada'];
    if (['Scrum', 'Line', 'Maul', 'Salida'].contains(actionName)) return ['Ganada', 'Perdida'];
    if (actionName == 'Tackle') return ['Positivo', 'Negativo'];
    if (actionName == 'Penales Cometidos') return ['Scrum', 'Ruck', 'Inconducta', 'Offside', 'Otro'];
    if (actionName == 'Tarjeta') return ['Amarilla', 'Roja'];
    return []; 
  }

  static int calcularPuntos(String nombreAccion, {String? resultado}) {
    final nom = nombreAccion.trim().toLowerCase();
    final res = resultado?.trim().toLowerCase() ?? '';
    
    if (nom == 'try') return 5;
    if (nom == 'drop') return 3;
    
    if (nom == 'patada') {
      if (res == 'conversión' || res == 'conversion') return 2;
      if (res == 'penal a los palos') return 3;
    }
    
    return 0;
  }
}
