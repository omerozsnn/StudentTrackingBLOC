import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  // Geliştirme ortamı için IP adresi
  static const String _ipAddress = 'http://192.168.1.43:3000';
  static const String _localhost = 'http://localhost:3000';
  
  static String get baseUrl {
    // iOS simülatörde ve macOS desktop'ta localhost kullan
    if (kDebugMode && (Platform.isIOS || Platform.isMacOS)) {
      return _localhost;
    }
    // Diğer durumlarda (Android gerçek cihaz vs.) IP adresi kullan
    return _ipAddress;
  }
  
  // Alternatif olarak debug/release modlarına göre farklı URL'ler
  static String get apiBaseUrl {
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
    
    if (isDebug) {
      return baseUrl;
    } else {
      // Production ortamı (daha sonra gerçek server URL'si)
      return 'https://your-production-api.com';
    }
  }
} 