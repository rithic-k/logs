import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  SecurityService._internal();

  static Future<SecurityService> initialize() async {
    return _instance;
  }

  Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false; // Biometrics not supported on web
    return await _localAuth.canCheckBiometrics;
  }

  Future<bool> authenticateWithBiometrics() async {
    if (kIsWeb) return false; // Biometrics not supported on web
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> setPin(String pin) async {
    await _storage.write(key: 'pin', value: pin);
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await _storage.read(key: 'pin');
    return storedPin == pin;
  }

  Future<bool> hasPin() async {
    final pin = await _storage.read(key: 'pin');
    return pin != null;
  }
}
