import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrando usuario...'),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Nuevo Registro',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ALMA JUNIORS RUGBY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                _buildField('NOMBRE', 'Tu nombre completo', Icons.person_outline, _nameController),
                _buildField('EMAIL', 'tu@email.com', Icons.email_outlined, _emailController, keyboardType: TextInputType.emailAddress),
                _buildField('TELÉFONO', '+54 11 1234-5678', Icons.phone_outlined, _phoneController, keyboardType: TextInputType.phone),
                _buildPasswordField('CONTRASEÑA', 'Mínimo 6 caracteres', _passwordController),
                _buildPasswordField('CONFIRMAR CONTRASEÑA', 'Repetí tu contraseña', _confirmPasswordController, isConfirm: true),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('REGISTRARSE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('← VOLVER AL LOGIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, IconData icon, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint, icon),
          validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint, TextEditingController controller, {bool isConfirm = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !_isPasswordVisible,
          decoration: _inputDecoration(hint, Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) return 'Campo requerido';
            if (isConfirm && value != _passwordController.text) return 'Las contraseñas no coinciden';
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.black, size: 22),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
    );
  }
}