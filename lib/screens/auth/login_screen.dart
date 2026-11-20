import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/auth_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../inicio/inicio_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  bool _cargando = false;

  Future<void> _entrar() async {
    setState(() => _cargando = true);
    await context.read<AuthRepository>().iniciarSesion(email: _emailCtrl.text.trim());
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const InicioScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Iniciar sesión', style: AppTheme.display(size: 24)),
            const SizedBox(height: 6),
            Text(
              'Identidad única CooPay — el mismo acceso para socio, comercio y supervisor.',
              style: AppTheme.body(size: 12.5, color: AppColors.textDim),
            ),
            const SizedBox(height: 26),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Correo electrónico'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cargando ? null : _entrar,
                child: _cargando
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
