class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    var error = 'ApiException: $message';
    if (statusCode != null) {
      error += ' (Status: $statusCode)';
    }
    if (details != null) {
      error += '\nDetaylar: $details';
    }
    return error;
  }

  // HTTP durum kodlarına göre özel mesajlar
  static String getMessageForStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Geçersiz istek';
      case 401:
        return 'Yetkisiz erişim';
      case 403:
        return 'Erişim reddedildi';
      case 404:
        return 'Kayıt bulunamadı';
      case 500:
        return 'Sunucu hatası';
      case 503:
        return 'Servis kullanılamıyor';
      default:
        return 'Bir hata oluştu';
    }
  }

  // Fabrika metodu - HTTP yanıtından ApiException oluşturur
  factory ApiException.fromResponse(int statusCode, String responseBody) {
    return ApiException(
      message: getMessageForStatusCode(statusCode),
      statusCode: statusCode,
      details: responseBody,
    );
  }

  // Özel hata tipleri için factory metodları
  factory ApiException.networkError() {
    return ApiException(
      message: 'İnternet bağlantısı hatası',
      details: 'Lütfen internet bağlantınızı kontrol edin',
    );
  }

  factory ApiException.serverError() {
    return ApiException(
      message: 'Sunucu hatası',
      statusCode: 500,
      details: 'Sunucu şu anda yanıt veremiyor',
    );
  }

  factory ApiException.invalidData() {
    return ApiException(
      message: 'Geçersiz veri',
      statusCode: 400,
      details: 'Gönderilen veri formatı geçersiz',
    );
  }

  factory ApiException.notFound(String resource) {
    return ApiException(
      message: '$resource bulunamadı',
      statusCode: 404,
      details: 'İstenen kayıt veritabanında mevcut değil',
    );
  }
}