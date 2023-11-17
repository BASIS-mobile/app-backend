// ignore_for_file: constant_identifier_names

class Errors {
  // Network Errors
  static const int NETWORK_CONNECTION_ERROR = 1001;
  static const int SERVER_TIMEOUT = 1002;
  static const int SERVER_MANUAL_WARNING = 1010;

  // Data Retrieval Errors
  static const int FAILED_TO_LOAD_COURSES = 2001;
  static const int COURSE_DATA_UNAVAILABLE = 2002;

  // Data Parsing Errors
  static const int DATA_PROCESSING_ERROR = 3001;
  static const int INVALID_DATA_FORMAT = 3002;

  // User Authentication Errors
  static const int AUTHENTICATION_FAILED = 4001;
  static const int SESSION_EXPIRED = 4002;

  // Permission Errors
  static const int NO_PERMISSION = 5001;
  static const int ACCESS_DENIED = 5002;

  // App Internal Errors
  static const int UNEXPECTED_ERROR = 6001;
  static const int INITIALIZATION_FAILED = 6002;

  // UI Rendering Errors
  static const int UI_LOAD_FAILED = 7001;
  static const int MISSING_UI_ELEMENTS = 7002;

  // Database Errors
  static const int DB_RETRIEVAL_FAILED = 8001;
  static const int DB_CONNECTION_LOST = 8002;

  // API Errors
  static const int API_REQUEST_FAILED = 9001;
  static const int INVALID_API_RESPONSE = 9002;

  // Unknown Errors
  static const int UNKNOWN_ERROR = 9999;

  // Error Messages
  static const Map<int, String> errorMessages = {
    NETWORK_CONNECTION_ERROR:
        "Verbindung zum Server konnte nicht hergestellt werden. \nBitte überprüfen Sie Ihre Internetverbindung.",
    SERVER_TIMEOUT:
        "Server-Zeitüberschreitung. \nBitte versuchen Sie es später erneut.",
    FAILED_TO_LOAD_COURSES:
        "Veranstaltungen konnten nicht geladen werden. Bitte versuchen Sie es später erneut.",
    COURSE_DATA_UNAVAILABLE: "Kursdaten sind derzeit nicht verfügbar.",
    DATA_PROCESSING_ERROR:
        "Fehler bei der Verarbeitung der Kursdaten. \nBitte versuchen Sie es erneut.",
    INVALID_DATA_FORMAT:
        "Ungültiges Kursdatenformat. \nKontaktieren Sie den Support für Hilfe.",
    AUTHENTICATION_FAILED:
        "Benutzerauthentifizierung fehlgeschlagen. \nBitte melden Sie sich erneut an.",
    SESSION_EXPIRED:
        "Benutzersitzung abgelaufen. \nBitte melden Sie sich erneut an.",
    NO_PERMISSION:
        "Sie haben keine Berechtigung, diesen Inhalt anzusehen. \nBitte kontaktieren Sie den Administrator.",
    ACCESS_DENIED:
        "Zugriff verweigert. Stellen Sie sicher, dass Sie für den Kurs eingeschrieben sind, um Details anzeigen zu können.",
    UNEXPECTED_ERROR:
        "Ein unerwarteter Fehler ist aufgetreten. \nBitte starten Sie die App neu.",
    INITIALIZATION_FAILED:
        "Initialisierung der App fehlgeschlagen. \nBitte installieren Sie neu.",
    UI_LOAD_FAILED:
        "Benutzeroberfläche konnte nicht geladen werden. \nBitte starten Sie die App neu.",
    MISSING_UI_ELEMENTS:
        "UI-Elemente fehlen. Stellen Sie sicher, dass die App auf die neueste Version aktualisiert ist.",
    DB_RETRIEVAL_FAILED:
        "Daten konnten nicht aus der Datenbank abgerufen werden. \nBitte versuchen Sie es später erneut.",
    DB_CONNECTION_LOST:
        "Datenbankverbindung verloren. \nBitte starten Sie die App neu.",
    API_REQUEST_FAILED:
        "API-Anfrage fehlgeschlagen. \nBitte versuchen Sie es später erneut.",
    INVALID_API_RESPONSE:
        "Ungültige API-Antwort. \nBitte kontaktieren Sie den Support.",
    UNKNOWN_ERROR:
        "Ein unbekannter Fehler ist aufgetreten. \nBitte kontaktieren Sie den Support.",
    SERVER_MANUAL_WARNING:
        "Es werden derzeit Wartungsarbeiten am Server durchgeführt."
  };

  static const String SUPPORT_CONTACT = "basis-app@uni-bonn.de";

  // Function to get error message based on error code
  static String getErrorMessage(int errorCode) {
    return errorMessages[errorCode] ??
        "Ein unbekannter Fehler ist aufgetreten.";
  }
}
