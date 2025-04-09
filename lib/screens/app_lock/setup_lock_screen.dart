import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/security_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../daily_logs/daily_logs_screen.dart';

class SetupLockScreen extends StatefulWidget {
  const SetupLockScreen({super.key});

  @override
  State<SetupLockScreen> createState() => _SetupLockScreenState();
}

class _SetupLockScreenState extends State<SetupLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _useBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final securityService =
        Provider.of<SecurityService>(context, listen: false);
    final biometricsAvailable = await securityService.isBiometricAvailable();
    setState(() {
      _useBiometrics = biometricsAvailable;
    });
  }

  Future<void> _setupLock() async {
    if (_pinController.text.isEmpty || _confirmPinController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter and confirm your PIN';
      });
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      setState(() {
        _errorMessage = 'PINs do not match';
      });
      return;
    }

    if (_pinController.text.length < 4) {
      setState(() {
        _errorMessage = 'PIN must be at least 4 digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final securityService =
          Provider.of<SecurityService>(context, listen: false);
      await securityService.setPin(_pinController.text);

      if (_useBiometrics) {
        final authenticated =
            await securityService.authenticateWithBiometrics();
        if (!authenticated) {
          setState(() {
            _errorMessage =
                'Biometric setup failed. You can enable it later in settings.';
          });
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DailyLogsScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to set up PIN. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                'Set Up PIN',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 8),
              const Text(
                'Create a PIN to secure your app',
                style: AppTextStyles.body2,
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
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPinController,
                style: AppTextStyles.body1,
                decoration: const InputDecoration(
                  hintText: 'Confirm PIN',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                onSubmitted: (_) => _setupLock(),
              ),
              if (_useBiometrics) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.fingerprint, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Biometric authentication is available on your device',
                        style: AppTextStyles.body2
                            .copyWith(color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              ],
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: AppTextStyles.body2.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _setupLock,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Set PIN'),
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
    _confirmPinController.dispose();
    super.dispose();
  }
}
