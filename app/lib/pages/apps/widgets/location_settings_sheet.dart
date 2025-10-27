import 'package:flutter/material.dart';
import 'package:omi/backend/schema/integration.dart';
import 'package:omi/providers/integration_provider.dart';

class LocationSettingsSheet extends StatelessWidget {
  final Integration integration;
  final IntegrationProvider provider;

  const LocationSettingsSheet({
    super.key,
    required this.integration,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(integration.icon, size: 32, color: const Color(0xFF4FAFBE)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  integration.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1F40),
                  ),
                ),
              ),
              Switch(
                value: integration.enabled,
                onChanged: (value) async {
                  await provider.toggleIntegration(integration.id, value);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                activeColor: const Color(0xFF4FAFBE),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            integration.description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF0D1F40),
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildFeatureItem(
            Icons.pin_drop,
            'Location Context',
            'Remember where important conversations happened',
          ),
          _buildFeatureItem(
            Icons.search,
            'Smart Recall',
            'Find conversations by location: "Show me talks at Starbucks"',
          ),
          _buildFeatureItem(
            Icons.insights,
            'Place Intelligence',
            'Understand patterns: where deals close, best meeting spots',
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location data is stored locally and never shared unless you explicitly share a conversation',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4FAFBE)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D1F40),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


