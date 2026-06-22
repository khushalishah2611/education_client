import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/http_client.dart';
import '../services/network_event_service.dart';

class NetworkConnectivityWrapper extends StatefulWidget {
  const NetworkConnectivityWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<NetworkConnectivityWrapper> createState() => _NetworkConnectivityWrapperState();
}

class _NetworkConnectivityWrapperState extends State<NetworkConnectivityWrapper> {
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final isOffline = result.contains(ConnectivityResult.none) && result.length == 1;
    if (mounted && _isOffline != isOffline) {
      setState(() {
        _isOffline = isOffline;
      });

      if (_isOffline) {
        // Just went offline: cancel all ongoing API requests
        AppHttpClient.resetAndClose();
      } else {
        // Just came online: trigger auto-reload for active screens
        NetworkEventService.fireInternetRestored();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (_isOffline)
            Positioned.fill(
              child: _AdvancedNoInternetOverlay(),
            ),
        ],
      ),
    );
  }
}

class _AdvancedNoInternetOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String message = 'No Internet Connection\nPlease check your network and try again.';
    String oops = 'Oops!';
    try {
      message = context.l10n.text('noInternetMessage');
      oops = context.l10n.text('oops');
    } catch (_) {}

    return Material(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.red.shade50,
                   shape: BoxShape.circle,
                 ),
                 child: Icon(
                   Icons.wifi_off_rounded,
                   color: Colors.red.shade600,
                   size: 36,
                 ),
               ),
               const SizedBox(height: 20),
               Text(
                 oops,
                 style: const TextStyle(
                   fontSize: 22,
                   fontWeight: FontWeight.w800,
                   color: Colors.black87,
                 ),
               ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
