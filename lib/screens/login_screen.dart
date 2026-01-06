// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../repositories/auth_repository.dart';
import '../services/api_client.dart';
import 'home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  final AuthRepository authRepository;
  final ApiClient apiClient;

  const LoginScreen({
    super.key,
    required this.authRepository,
    required this.apiClient,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _isLoading = true);

    try {
      await widget.authRepository.login(
        _usernameCtrl.text.trim(),
        _passwordCtrl.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } catch (e) {
      print('LOGIN ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo iniciar sesión. Revisa usuario/contraseña.',
            style: GoogleFonts.inter(),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),

                  // ----- Branding -----
                  Column(
                    children: [
                      Text(
                        'FoodForNenes',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.pacifico(
                          fontSize: 40,
                          color: const Color(0xFF0B3A42), // azul verdoso oscuro
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF0B3A42).withOpacity(0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 42),

                  // ----- Card del formulario -----
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _Field(
                            controller: _usernameCtrl,
                            label: 'Usuario',
                            icon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Escribe tu usuario';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _Field(
                            controller: _passwordCtrl,
                            label: 'Contraseña',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _doLogin(),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Escribe tu contraseña';
                              }
                              return null;
                            },
                            suffix: IconButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF0B3A42).withOpacity(0.55),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ----- Botón estilo “flecha” -----
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: _isLoading ? null : _doLogin,
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF2FE7C3), // verde agua
                                      const Color(0xFF2BA7FF), // azul
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2BA7FF).withOpacity(0.25),
                                      blurRadius: 14,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(Icons.arrow_forward, color: Colors.white),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading ? null : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('De momento no está implementado 🙂', style: GoogleFonts.inter())),
                                );
                              },
                              child: Text(
                                '¿Olvidaste la contraseña?',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF0B3A42).withOpacity(0.75),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = const Color(0xFF0B3A42);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 14.5,
        color: baseColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: baseColor.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: baseColor.withOpacity(0.65)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: baseColor.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: baseColor.withOpacity(0.35)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

/// Fondo con ondas arriba/abajo en tonos frescos (verde-azul)
class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo base
        Container(color: const Color(0xFFF5FBFF)),

        // Onda superior
        Positioned(
          top: -80,
          left: -40,
          right: -40,
          child: Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(220),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2FE7C3),
                  Color(0xFF2BA7FF),
                ],
              ),
            ),
          ),
        ),

        // Onda inferior
        Positioned(
          bottom: -110,
          left: -60,
          right: -60,
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(260),
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  const Color(0xFF2BA7FF),
                  const Color(0xFF2FE7C3).withOpacity(0.95),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
