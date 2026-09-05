import 'package:flutter/material.dart';

class FilterPanel extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final String? selectedDivision;
  final List<String> divisions;
  final ValueChanged<String?> onDivisionChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const FilterPanel({
    super.key,
    required this.selectedDateRange,
    required this.selectedDivision,
    required this.divisions,
    required this.onDivisionChanged,
    required this.onDateRangeChanged,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DIVISIÓN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedDivision,
            items: divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: onDivisionChanged,
            decoration: _inputDecoration(),
          ),
          const SizedBox(height: 16),
          const Text('RANGO DE FECHAS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.date_range, size: 18),
              label: Text(
                selectedDateRange == null 
                  ? 'Seleccionar rango de fechas' 
                  : '${selectedDateRange!.start.day.toString().padLeft(2, '0')}/${selectedDateRange!.start.month.toString().padLeft(2, '0')}/${selectedDateRange!.start.year} al ${selectedDateRange!.end.day.toString().padLeft(2, '0')}/${selectedDateRange!.end.month.toString().padLeft(2, '0')}/${selectedDateRange!.end.year}',
                style: TextStyle(color: selectedDateRange == null ? Colors.grey : Colors.black),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                alignment: Alignment.centerLeft,
                side: BorderSide(color: Colors.grey[300]!),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDateRange: selectedDateRange,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.black,
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  onDateRangeChanged(picked);
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: onApply, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), child: const Text('APLICAR'))),
              const SizedBox(width: 16),
              Expanded(child: OutlinedButton(onPressed: onClear, child: const Text('LIMPIAR'))),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!)),
    );
  }
}