import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Connectivity service — monitors network state and auto-reconnects
/// Socket.io when the network resumes.
///
/// Singleton: use `ConnectivityService.instance`.
class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  VoidCallback? _onReconnect;

  /// Set the callback to run when network resumes.
  /// This should trigger Socket.io reconnection.
  void setReconnectCallback(VoidCallback callback) {
    _onReconnect = callback;
  }

  /// Start listening to connectivity changes.
  void init() {
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateState(results);
  }

  Future<void> _onConnectivityChanged(
    List<ConnectivityResult> results,
  ) async {
    _updateState(results);
  }

  void _updateState(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = results.any(
      (r) =>
          r != ConnectivityResult.none &&
          r != ConnectivityResult.bluetooth,
    );

    if (!wasConnected && _isConnected && _onReconnect != null) {
      _onReconnect!();
    }

    if (!_connectivityController.isClosed) {
      _connectivityController.add(_isConnected);
    }
  }

  /// Show a poetic snackbar when disconnected.
  static void showDisconnected(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'The thread is severed. Reconnecting...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.inverseOnSurface,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: AppColors.inverseSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show a poetic snackbar when reconnected.
  static void showReconnected(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'The thread is mended.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.inverseOnSurface,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void dispose() {
    _connectivityController.close();
  }
}
