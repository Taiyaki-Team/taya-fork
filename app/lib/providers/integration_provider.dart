import 'package:flutter/material.dart';
import 'package:omi/backend/http/api/integrations.dart';
import 'package:omi/backend/schema/integration.dart';

class IntegrationProvider with ChangeNotifier {
  List<Integration> _integrations = [];
  bool _isLoading = false;
  String? _error;

  List<Integration> get integrations => _integrations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get only optional integrations (exclude built-in ones)
  List<Integration> get optionalIntegrations =>
      _integrations.where((i) => i.type == IntegrationType.optional).toList();

  /// Get only built-in integrations
  List<Integration> get builtinIntegrations =>
      _integrations.where((i) => i.type == IntegrationType.builtin).toList();

  /// Get a specific integration by ID
  Integration? getIntegration(String id) {
    try {
      return _integrations.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Load all integrations
  Future<void> loadIntegrations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _integrations = await retrieveIntegrations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle an integration on/off
  Future<bool> toggleIntegration(String id, bool enabled) async {
    try {
      final success = await toggleIntegrationApi(id, enabled);

      if (success) {
        final index = _integrations.indexWhere((i) => i.id == id);
        if (index != -1) {
          _integrations[index] = _integrations[index].copyWith(enabled: enabled);
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Connect an optional integration (OAuth or API key setup)
  Future<bool> connectIntegration(String id) async {
    try {
      final result = await connectIntegrationApi(id);

      if (result != null && result['success'] == true) {
        final index = _integrations.indexWhere((i) => i.id == id);
        if (index != -1) {
          _integrations[index] = _integrations[index].copyWith(
            status: IntegrationStatus.connected,
            enabled: true,
            config: result['config'],
          );
          notifyListeners();
        }
        return true;
      }

      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Disconnect an optional integration
  Future<bool> disconnectIntegration(String id) async {
    try {
      final success = await disconnectIntegrationApi(id);

      if (success) {
        final index = _integrations.indexWhere((i) => i.id == id);
        if (index != -1) {
          _integrations[index] = _integrations[index].copyWith(
            status: IntegrationStatus.not_connected,
            enabled: false,
            config: null,
          );
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

