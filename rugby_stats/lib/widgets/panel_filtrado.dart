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
            value: selectedDivision,
            items: divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: onDivisionChanged,
            decoration: _inputDecoration(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDateField('DESDE', dateFromController)),
              const SizedBox(width: 16),
              Expanded(child: _buildDateField('HASTA', dateToController)),
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

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(hint: 'dd/mm/aaaa'),
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