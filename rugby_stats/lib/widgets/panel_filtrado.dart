import 'package:flutter/material.dart';

class FilterPanel extends StatelessWidget {
  final TextEditingController dateFromController;
  final TextEditingController dateToController;
  final String? selectedDivision;
  final List<String> divisions;
  final ValueChanged<String?> onDivisionChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const FilterPanel({
    super.key,
    required this.dateFromController,
    required this.dateToController,
    required this.selectedDivision,
    required this.divisions,
    required this.onDivisionChanged,
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
          Row(
            children: [
              Expanded(child: _buildDateField(context, 'DESDE', dateFromController)),
              const SizedBox(width: 16),
              Expanded(child: _buildDateField(context, 'HASTA', dateToController)),
            ],
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

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: _inputDecoration(hint: 'dd/mm/aaaa').copyWith(
            suffixIcon: const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
          ),
          onTap: () async {
            DateTime initial = DateTime.now();
            if (controller.text.isNotEmpty) {
              try {
                final parts = controller.text.split('/');
                if (parts.length == 3) {
                  initial = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                }
              } catch (_) {}
            }
            
            if (initial.isBefore(DateTime(2000))) initial = DateTime(2000);
            if (initial.isAfter(DateTime(2100))) initial = DateTime(2100);

            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
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

            if (pickedDate != null) {
              final String day = pickedDate.day.toString().padLeft(2, '0');
              final String month = pickedDate.month.toString().padLeft(2, '0');
              final String year = pickedDate.year.toString();
              controller.text = "$day/$month/$year";
            }
          },
        ),
      ],
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