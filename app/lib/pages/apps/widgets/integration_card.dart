import 'package:flutter/material.dart';
import 'package:omi/backend/schema/integration.dart';

class IntegrationCard extends StatelessWidget {
  final Integration integration;
  final VoidCallback onTap;

  const IntegrationCard({
    super.key,
    required this.integration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(186, 236, 243, 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: integration.isConnected
                ? Colors.green.withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(186, 236, 243, 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                integration.icon,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          integration.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (integration.isBuiltin) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Built-in',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    integration.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (integration.isConnected) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.check_circle, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Connected',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Action icon
            Icon(
              integration.isBuiltin
                  ? (integration.enabled ? Icons.toggle_on : Icons.toggle_off)
                  : (integration.isConnected ? Icons.settings : Icons.add_circle_outline),
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

