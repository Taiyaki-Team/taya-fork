import 'package:flutter/material.dart';

enum IntegrationType {
  builtin,  // Location - always shown, just toggle
  optional, // Others - user adds them
}

enum IntegrationStatus {
  ready,          // Location - ready to use
  not_connected,  // Optional - needs setup
  connected,      // Optional - setup complete
  error,          // Setup failed
}

class Integration {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final IntegrationType type;
  final IntegrationStatus status;
  final bool enabled;
  final bool setupRequired;
  final List<String>? tools;
  final Map<String, dynamic>? config;

  Integration({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.status,
    required this.enabled,
    this.setupRequired = false,
    this.tools,
    this.config,
  });

  bool get isConnected => status == IntegrationStatus.connected;
  bool get isBuiltin => type == IntegrationType.builtin;
  bool get needsSetup => setupRequired && !isConnected;

  Integration copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    IntegrationType? type,
    IntegrationStatus? status,
    bool? enabled,
    bool? setupRequired,
    List<String>? tools,
    Map<String, dynamic>? config,
  }) {
    return Integration(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      status: status ?? this.status,
      enabled: enabled ?? this.enabled,
      setupRequired: setupRequired ?? this.setupRequired,
      tools: tools ?? this.tools,
      config: config ?? this.config,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'status': status.toString(),
      'enabled': enabled,
      'setupRequired': setupRequired,
      'tools': tools,
      'config': config,
    };
  }

  factory Integration.fromJson(Map<String, dynamic> json) {
    return Integration(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: Icons.star, // Default icon, would need to map from string
      type: IntegrationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => IntegrationType.optional,
      ),
      status: IntegrationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => IntegrationStatus.not_connected,
      ),
      enabled: json['enabled'] ?? false,
      setupRequired: json['setupRequired'] ?? false,
      tools: json['tools'] != null ? List<String>.from(json['tools']) : null,
      config: json['config'],
    );
  }

  static List<Integration> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => Integration.fromJson(e)).toList();
  }
}

