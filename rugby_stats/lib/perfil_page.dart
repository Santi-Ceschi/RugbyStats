import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'models/usuario.dart';
import 'services/database_helper.dart';
import 'login_page.dart';

class PerfilPage extends StatefulWidget {
  final Usuario usuario;

  const PerfilPage({super.key, required this.usuario});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefonoController;
  final _passwordActualController = TextEditingController();
  final _nuevaPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isPasswordVisible = false;
  bool _isSaving = false;

  int _intentosFallidosPassword = 0;
  static const int _maxIntentosPassword = 6;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _emailController = TextEditingController(text: widget.usuario.email);
    _telefonoController = TextEditingController(text: widget.usuario.telefono);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordActualController.dispose();
    _nuevaPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    final nuevoNombre = _nombreController.text.trim();
    final nuevoEmail = _emailController.text.trim();
    final nuevoTelefono = _telefonoController.text.trim();
    final nuevaPassword = _nuevaPasswordController.text.trim();

    final bool cambioPassword = nuevaPassword.isNotEmpty;

    // Validación de Contraseña Actual con límite de 6 intentos
    if (cambioPassword) {
      final currentInput = _passwordActualController.text;
      final currentHash = sha256.convert(utf8.encode(currentInput)).toString();

      if (currentHash != widget.usuario.contrasena) {
        _intentosFallidosPassword++;
        final restantes = _maxIntentosPassword - _intentosFallidosPassword;

        if (_intentosFallidosPassword >= _maxIntentosPassword) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Superaste los 6 intentos permitidos. Se cerrará la sesión.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
          return;
        } else {
          if (mounted) {
            setState(() {}); // Actualiza aviso visual de intentos
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Contraseña actual incorrecta. Te quedan $restantes intentos.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
    }

    final String passFinal = cambioPassword ? nuevaPassword : widget.usuario.contrasena;

    final usuarioEditado = Usuario(
      id: widget.usuario.id,
      nombre: nuevoNombre,
      email: nuevoEmail,
      telefono: nuevoTelefono,
      contrasena: passFinal,
    );

    setState(() => _isSaving = true);

    try {
      await DatabaseHelper.instance.updateUsuario(
        usuarioEditado,
        actualizarPassword: cambioPassword,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, usuarioEditado); // Retorna el usuario actualizado a HomePage
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('UNIQUE')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ese correo ya está en uso por otra cuenta.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar perfil: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MI PERFIL',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.black87,
                      child: Text(
                        widget.usuario.nombre.isNotEmpty
                            ? widget.usuario.nombre[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.usuario.nombre,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.usuario.email,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tarjeta de Datos Personales
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DATOS PERSONALES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nombre
                    const Text('Nombre completo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    const Text('Correo electrónico', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                        if (!v.contains('@') || !v.contains('.')) return 'Correo inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Teléfono
                    const Text('Teléfono', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tarjeta de Cambio de Contraseña
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CAMBIAR CONTRASEÑA (OPCIONAL)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Deja estos campos en blanco si no deseas cambiar tu contraseña actual.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Contraseña Actual (Requerida para autorizar el cambio)
                    const Text('Contraseña actual', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordActualController,
                      obscureText: !_isCurrentPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.key_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_isCurrentPasswordVisible ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        hintText: 'Ingresa tu contraseña actual',
                      ),
                      validator: (v) {
                        if (_nuevaPasswordController.text.trim().isNotEmpty) {
                          if (v == null || v.isEmpty) {
                            return 'Ingresa tu contraseña actual para autorizar el cambio';
                          }
                        }
                        return null;
                      },
                    ),
                    if (_intentosFallidosPassword > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Intentos restantes: ${_maxIntentosPassword - _intentosFallidosPassword} de $_maxIntentosPassword',
                        style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Nueva Contraseña
                    const Text('Nueva contraseña', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nuevaPasswordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        hintText: 'Mínimo 6 caracteres',
                      ),
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirmar Contraseña
                    const Text('Confirmar nueva contraseña', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isPasswordVisible,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        hintText: 'Repite la nueva contraseña',
                      ),
                      validator: (v) {
                        if (_nuevaPasswordController.text.isNotEmpty && v != _nuevaPasswordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botón Guardar Cambios
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _guardarPerfil,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSaving ? 'GUARDANDO...' : 'GUARDAR CAMBIOS',
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
