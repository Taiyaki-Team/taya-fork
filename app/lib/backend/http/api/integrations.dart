import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:omi/backend/http/shared.dart';
import 'package:omi/backend/preferences.dart';
import 'package:omi/backend/schema/integration.dart';
import 'package:omi/env/env.dart';

/// Retrieve all available integrations (built-in and optional)
Future<List<Integration>> retrieveIntegrations() async {
  // Get saved preferences
  final prefs = SharedPreferencesUtil();
  final locationEnabled = prefs.locationTrackingEnabled ?? true;

  // Fetch user's connected integrations from backend
  Map<String, Map<String, dynamic>> connectedIntegrations = {};
  try {
    var response = await makeApiCall(
      url: '${Env.apiBaseUrl}v1/integrations',
      headers: {},
      method: 'GET',
      body: '',
    );

    if (response != null && response.statusCode == 200) {
      List<dynamic> userIntegrations = jsonDecode(response.body);
      for (var integration in userIntegrations) {
        connectedIntegrations[integration['id']] = integration;
      }
      debugPrint('Loaded ${connectedIntegrations.length} connected integrations from backend');
    }
  } catch (e) {
    debugPrint('Error fetching user integrations: $e');
  }

  // Build integrations list with connection status from backend
  return [
    // Built-in: Location Tracking
    Integration(
      id: 'location',
      name: 'Location Tracking',
      description: 'Automatically save where conversations happen for context and recall',
      icon: Icons.location_on,
      type: IntegrationType.builtin,
      enabled: locationEnabled,
      status: IntegrationStatus.ready,
      setupRequired: false,
    ),

    // Optional: Calendar
    Integration(
      id: 'calendar',
      name: 'Calendar',
      description: 'Auto-create calendar events from conversations',
      icon: Icons.calendar_today,
      type: IntegrationType.optional,
      enabled: connectedIntegrations.containsKey('calendar'),
      status: connectedIntegrations.containsKey('calendar')
          ? IntegrationStatus.connected
          : IntegrationStatus.not_connected,
      setupRequired: true,
      tools: [
        'create_event',
        'list_events',
        'update_event',
        'delete_event',
      ],
      config: connectedIntegrations['calendar']?['config'],
    ),

    // Optional: Notion
    Integration(
      id: 'notion',
      name: 'Notion',
      description: 'Save conversations as structured Notion pages',
      icon: Icons.note,
      type: IntegrationType.optional,
      enabled: connectedIntegrations.containsKey('notion'),
      status: connectedIntegrations.containsKey('notion')
          ? IntegrationStatus.connected
          : IntegrationStatus.not_connected,
      setupRequired: true,
      tools: [
        'create_page',
        'update_page',
        'search',
        'query_database',
      ],
      config: connectedIntegrations['notion']?['config'],
    ),

    // Optional: Slack
    Integration(
      id: 'slack',
      name: 'Slack',
      description: 'Post conversation summaries to team channels',
      icon: Icons.chat_bubble_outline,
      type: IntegrationType.optional,
      enabled: connectedIntegrations.containsKey('slack'),
      status: connectedIntegrations.containsKey('slack')
          ? IntegrationStatus.connected
          : IntegrationStatus.not_connected,
      setupRequired: true,
      tools: [
        'post_message',
        'list_channels',
        'upload_file',
        'add_reaction',
      ],
      config: connectedIntegrations['slack']?['config'],
    ),

    // Optional: Task Manager
    Integration(
      id: 'tasks',
      name: 'Task Manager',
      description: 'Create tasks from action items (Todoist, Linear, Asana)',
      icon: Icons.check_circle_outline,
      type: IntegrationType.optional,
      enabled: connectedIntegrations.containsKey('tasks'),
      status: connectedIntegrations.containsKey('tasks')
          ? IntegrationStatus.connected
          : IntegrationStatus.not_connected,
      setupRequired: true,
      tools: [
        'create_task',
        'list_projects',
        'update_task',
        'complete_task',
      ],
      config: connectedIntegrations['tasks']?['config'],
    ),
  ];
}

/// Save integration preferences
Future<void> saveIntegrationPreferences(List<Integration> integrations) async {
  final prefs = SharedPreferencesUtil();

  // Save location tracking state
  final locationIntegration = integrations.firstWhere((i) => i.id == 'location');
  prefs.locationTrackingEnabled = locationIntegration.enabled;

  // In the future, we'll save other integration states to backend
}

/// Toggle an integration on/off
Future<bool> toggleIntegrationApi(String integrationId, bool enabled) async {
  try {
    final prefs = SharedPreferencesUtil();

    switch (integrationId) {
      case 'location':
        prefs.locationTrackingEnabled = enabled;
        return true;

      default:
        // For optional integrations, we'll call backend API
        // TODO: Implement backend API call
        return false;
    }
  } catch (e) {
    debugPrint('Error toggling integration $integrationId: $e');
    return false;
  }
}

/// Connect an optional integration (OAuth flow or API key setup)
Future<Map<String, dynamic>?> connectIntegrationApi(String integrationId) async {
  try {
    debugPrint('Connecting integration: $integrationId');
    
    var response = await makeApiCall(
      url: '${Env.apiBaseUrl}v1/integrations/connect',
      headers: {},
      method: 'POST',
      body: jsonEncode({
        'server_id': integrationId,
        'config': {},
      }),
    );

    if (response != null && response.statusCode == 200) {
      var data = jsonDecode(response.body);
      debugPrint('Integration connected successfully: $integrationId');
      return data;
    } else {
      debugPrint('Failed to connect integration: ${response?.statusCode}');
      return null;
    }
  } catch (e) {
    debugPrint('Error connecting integration $integrationId: $e');
    return null;
  }
}

/// Disconnect an optional integration
Future<bool> disconnectIntegrationApi(String integrationId) async {
  try {
    debugPrint('Disconnecting integration: $integrationId');
    
    var response = await makeApiCall(
      url: '${Env.apiBaseUrl}v1/integrations/$integrationId/disconnect',
      headers: {},
      method: 'POST',
      body: '',
    );

    if (response != null && response.statusCode == 200) {
      debugPrint('Integration disconnected successfully: $integrationId');
      return true;
    } else {
      debugPrint('Failed to disconnect integration: ${response?.statusCode}');
      return false;
    }
  } catch (e) {
    debugPrint('Error disconnecting integration $integrationId: $e');
    return false;
  }
}

