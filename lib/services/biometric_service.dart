import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// What face / fingerprint options this phone currently offers.
class BiometricCapability {
  const BiometricCapability({
    required this.hasFace,
    required this.hasFingerprint,
    required this.hasWeak,
    required this.hasStrong,
    required this.deviceSupported,
    required this.canCheck,
  });

  final bool hasFace;
  final bool hasFingerprint;
  final bool hasWeak;
  final bool hasStrong;
  final bool deviceSupported;
  final bool canCheck;

  /// Android face unlock is often Class 2 (weak) — still usable.
  bool get isAvailable =>
      hasFace || hasFingerprint || hasWeak || hasStrong || (deviceSupported && canCheck);

  bool get hasBothFaceAndFingerprint => hasFace && hasFingerprint;

  String get faceLabel =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'Face ID' : 'Face unlock';

  String get label {
    if (hasBothFaceAndFingerprint) return 'Face & Fingerprint';
    if (hasFace && (hasFingerprint || hasStrong || hasWeak)) {
      return '$faceLabel & Fingerprint';
    }
    if (hasFace) return faceLabel;
    if (hasFingerprint) return 'Fingerprint';
    // Android often only reports weak/strong, not "face".
    if (hasWeak || hasStrong || (deviceSupported && canCheck)) {
      return 'Face unlock & Fingerprint';
    }
    if (deviceSupported) return 'Biometrics';
    return 'Biometrics';
  }

  String get detail {
    final parts = <String>[];
    if (hasFace) parts.add(faceLabel);
    if (hasFingerprint) parts.add('Fingerprint');
    if (parts.isEmpty && (hasWeak || hasStrong)) {
      return 'Face unlock or fingerprint enrolled on this phone';
    }
    if (parts.isEmpty && isAvailable) {
      return 'This phone supports biometric unlock';
    }
    if (parts.isEmpty) return 'No biometrics enrolled';
    if (parts.length == 1) return '${parts.first} ready on this phone';
    return '${parts.join(' · ')} — use either to unlock';
  }
}

/// Device biometric / Face ID helpers for unlock.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<BiometricCapability> get capability async {
    var hasFace = false;
    var hasFingerprint = false;
    var hasWeak = false;
    var hasStrong = false;
    var deviceSupported = false;
    var canCheck = false;

    try {
      deviceSupported = await _auth.isDeviceSupported();
    } catch (_) {}

    try {
      canCheck = await _auth.canCheckBiometrics;
    } catch (_) {}

    try {
      final types = await _auth.getAvailableBiometrics();
      for (final type in types) {
        switch (type) {
          case BiometricType.face:
            hasFace = true;
            break;
          case BiometricType.fingerprint:
            hasFingerprint = true;
            break;
          case BiometricType.iris:
            hasWeak = true;
            break;
          case BiometricType.strong:
            hasStrong = true;
            break;
          case BiometricType.weak:
            // Many Android phones report face unlock as weak.
            hasWeak = true;
            break;
        }
      }
    } catch (_) {}

    return BiometricCapability(
      hasFace: hasFace,
      hasFingerprint: hasFingerprint,
      hasWeak: hasWeak,
      hasStrong: hasStrong,
      deviceSupported: deviceSupported,
      canCheck: canCheck,
    );
  }

  Future<bool> get isAvailable async => (await capability).isAvailable;

  Future<String> get biometricLabel async => (await capability).label;

  Future<IconDataHint> get iconHint async {
    final cap = await capability;
    if (cap.hasBothFaceAndFingerprint ||
        (cap.hasFace && (cap.hasFingerprint || cap.hasStrong)) ||
        (cap.hasWeak && cap.hasStrong) ||
        (cap.hasWeak && !cap.hasFingerprint && !cap.hasFace)) {
      // weak-only Android ≈ face unlock available alongside possible fingerprint
      if (cap.hasWeak && !cap.hasFace && !cap.hasFingerprint) {
        return IconDataHint.both;
      }
      if (cap.hasFace || cap.hasWeak) {
        return (cap.hasFingerprint || cap.hasStrong)
            ? IconDataHint.both
            : IconDataHint.face;
      }
    }
    if (cap.hasFace || (cap.hasWeak && !cap.hasFingerprint)) {
      return IconDataHint.face;
    }
    return IconDataHint.fingerprint;
  }

  /// Prompts Face ID / face unlock / fingerprint via the system sheet.
  ///
  /// Important: Android face unlock is often Class 2 (weak). Using
  /// `biometricOnly: true` blocks it on many phones, so we allow weak
  /// biometrics. `sensitiveTransaction: false` avoids an extra confirm
  /// step that breaks some OEM face flows.
  Future<bool> authenticate({
    String reason = 'Unlock Kwanpa Susu',
  }) async {
    try {
      final cap = await capability;
      if (!cap.isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        sensitiveTransaction: false,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      if (e.code == LocalAuthExceptionCode.userCanceled ||
          e.code == LocalAuthExceptionCode.systemCanceled) {
        return false;
      }
      // Last resort retry.
      try {
        return await _auth.authenticate(
          localizedReason: reason,
          biometricOnly: false,
          sensitiveTransaction: false,
        );
      } catch (_) {
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}

enum IconDataHint { face, fingerprint, both }
