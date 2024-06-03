
class StatusCodes {
  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int conflict = 409;
  static const int internalServerError = 500;
  static const int notImplemented = 501;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;

  static String getMessage(int statusCode) {
    switch (statusCode) {
      case ok:
        return 'OK';
      case created:
        return 'Created';
      case accepted:
        return 'Accepted';
      case noContent:
        return 'No Content';
      case badRequest:
        return 'Bad Request';
      case unauthorized:
        return 'Unauthorized';
      case forbidden:
        return 'Forbidden';
      case notFound:
        return 'Not Found';
      case methodNotAllowed:
        return 'Method Not Allowed';
      case conflict:
        return 'Conflict';
      case internalServerError:
        return 'Internal Server Error';
      case notImplemented:
        return 'Not Implemented';
      case badGateway:
        return 'Bad Gateway';
      case serviceUnavailable:
        return 'Service Unavailable';
      default:
        return 'Unknown Status Code';
    }
  }
}
