import 'package:flutter/material.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'services/database_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Llamada al método login de DatabaseHelper
      final result = await DatabaseHelper.instance.login(email, password);

      if (result['success'] == true) {
        // Login exitoso, navegamos a la pantalla principal
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        // Login fallido, mostramos mensaje de error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        
                        // LOGOTIPO
                        Image.asset(
                          'assets/images/logo.JPG',
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        const Text(
                          'RugbyStats',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'ALMA JUNIORS RUGBY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            letterSpacing: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 36),
                        
                        // CAMPO: EMAIL
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EMAIL',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Ingresa tu email',
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.black87),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? 'Ingresa tu email' : null,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // CAMPO: CONTRASEÑA
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CONTRASEÑA',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                hintText: 'Ingresa tu contraseña',
                                prefixIcon: const Icon(Icons.lock_outline, color: Colors.black87),
                                suffixIcon: IconButton(
                                  icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? 'Ingresa tu contraseña' : null,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // BOTÓN DE INICIO DE SESIÓN
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                            child: const Text('INICIAR SESIÓN'),
                          ),
                        ),
                        
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                          child: const Text('¿No tenés cuenta? Registrate aquí'),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}