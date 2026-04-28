class ApiStatus {
  static const Set<int> handledStatuses = <int>{200, 201, 400, 409, 500};

  static bool isSuccess(int statusCode) =>
      statusCode == 200 || statusCode == 201;

  static bool isHandled(int statusCode) => handledStatuses.contains(statusCode);
}
