class DateFormatter {
  /// Converts date from YYYY-MM-DD format to DD-MM-YYYY format
  static String convertToLocalFormat(String date) {
    try {
      if (date.isEmpty) return '';
      List<String> parts = date.split('-'); // ["YYYY", "MM", "DD"]
      if (parts.length != 3) return date;
      return "${parts[2]}-${parts[1]}-${parts[0]}"; // "DD-MM-YYYY"
    } catch (e) {
      return date;
    }
  }
  
  /// Converts date from DD-MM-YYYY format to YYYY-MM-DD format for API
  static String convertToApiFormat(String date) {
    try {
      if (date.isEmpty) return '';
      List<String> parts = date.split('-'); // ["DD", "MM", "YYYY"]
      if (parts.length != 3) return date;
      return "${parts[2]}-${parts[1]}-${parts[0]}"; // "YYYY-MM-DD"
    } catch (e) {
      return date;
    }
  }
} 