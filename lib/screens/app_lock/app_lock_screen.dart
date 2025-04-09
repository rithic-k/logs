import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/security_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../daily_logs/daily_logs_screen.dart';
import 'setup_lock_screen.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    final securityService =
        Provider.of<SecurityService>(context, listen: false);
    final hasPin = await securityService.hasPin();

    if (!hasPin) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SetupLockScreen()),
        );
      }
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final securityService =
          Provider.of<SecurityService>(context, listen: false);

      // Try biometric authentication first
      if (await securityService.isBiometricAvailable()) {
        final authenticated =
            await securityService.authenticateWithBiometrics();
        if (authenticated) {
          _onAuthenticationSuccess();
          return;
        }
      }

      // Fall back to PIN verification
      if (_pinController.text.isNotEmpty) {
        final verified = await securityService.verifyPin(_pinController.text);
        if (verified) {
          _onAuthenticationSuccess();
        } else {
          setState(() {
            _errorMessage = 'Invalid PIN. Please try again.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication failed. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onAuthenticationSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DailyLogsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Back',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _pinController,
                style: AppTextStyles.body1,
                decoration: const InputDecoration(
                  hintText: 'Enter PIN',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                onSubmitted: (_) => _authenticate(),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: AppTextStyles.body2.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _authenticate,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Unlock'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
