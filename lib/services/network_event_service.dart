import 'dart:async';

class NetworkEventService {
  static final StreamController<void> _onInternetRestored = StreamController<void>.broadcast();

  /// Stream that emits an event whenever the internet connection is restored.
  static Stream<void> get onInternetRestored => _onInternetRestored.stream;

  /// Fire the internet restored event.
  static void fireInternetRestored() {
    _onInternetRestored.add(null);
  }
}
