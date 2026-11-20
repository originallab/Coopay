import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';
import 'registro_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            children: [
              const Spacer(),
              _CoopayLogo(),
              const SizedBox(height: 18),
              Text('CooPay', style: AppTheme.display(size: 30)),
              const SizedBox(height: 10),
              Text(
                'Pagos ágiles, con el respaldo de tu caja de ahorro',
                textAlign: TextAlign.center,
                style: AppTheme.body(size: 13, color: AppColors.textDim),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegistroScreen()),
                  ),
                  child: const Text('Crear cuenta'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: Text('Ya tengo cuenta', style: AppTheme.body(weight: FontWeight.w700, color: AppColors.navy)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoopayLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      alignment: Alignment.center,
      child: Text('CP', style: AppTheme.display(size: 26, color: AppColors.cream)),
    );
  }
}
