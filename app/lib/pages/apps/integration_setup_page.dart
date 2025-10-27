import 'package:flutter/material.dart';
import 'package:omi/backend/schema/integration.dart';
import 'package:omi/providers/integration_provider.dart';
import 'package:provider/provider.dart';

class IntegrationSetupPage extends StatefulWidget {
  final Integration integration;
  
  const IntegrationSetupPage({super.key, required this.integration});
  
  @override
  State<IntegrationSetupPage> createState() => _IntegrationSetupPageState();
}

class _IntegrationSetupPageState extends State<IntegrationSetupPage> {
  bool _isConnecting = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Connect ${widget.integration.name}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and description
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(186, 236, 243, 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  widget.integration.icon,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Center(
              child: Text(
                widget.integration.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Center(
              child: Text(
                widget.integration.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // What this integration can do
            const Text(
              'What it does',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (widget.integration.tools != null)
              ...widget.integration.tools!.map((tool) => _buildToolItem(tool)),
            
            const SizedBox(height: 32),
            
            // Connect button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _handleConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FAFBE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isConnecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Connect ${widget.integration.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You\'ll be redirected to ${widget.integration.name} to authorize access. Your conversations will remain private.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildToolItem(String tool) {
    // Map tool names to readable descriptions
    final descriptions = <String, Map<String, dynamic>>{
      'create_event': {
        'icon': Icons.event,
        'text': 'Automatically create calendar events',
      },
      'list_events': {
        'icon': Icons.event_available,
        'text': 'View upcoming events',
      },
      'update_event': {
        'icon': Icons.edit_calendar,
        'text': 'Modify existing events',
      },
      'delete_event': {
        'icon': Icons.event_busy,
        'text': 'Remove events',
      },
      'create_page': {
        'icon': Icons.note_add,
        'text': 'Save conversations as Notion pages',
      },
      'update_page': {
        'icon': Icons.edit_note,
        'text': 'Update existing pages',
      },
      'search': {
        'icon': Icons.search,
        'text': 'Search your workspace',
      },
      'query_database': {
        'icon': Icons.storage,
        'text': 'Access database entries',
      },
      'post_message': {
        'icon': Icons.send,
        'text': 'Send summaries to Slack channels',
      },
      'list_channels': {
        'icon': Icons.tag,
        'text': 'Browse available channels',
      },
      'upload_file': {
        'icon': Icons.upload_file,
        'text': 'Share files with team',
      },
      'add_reaction': {
        'icon': Icons.emoji_emotions,
        'text': 'React to messages',
      },
      'create_task': {
        'icon': Icons.add_task,
        'text': 'Turn action items into tasks',
      },
      'list_projects': {
        'icon': Icons.folder,
        'text': 'View your projects',
      },
      'update_task': {
        'icon': Icons.edit,
        'text': 'Modify task details',
      },
      'complete_task': {
        'icon': Icons.check_circle,
        'text': 'Mark tasks as done',
      },
    };
    
    final toolInfo = descriptions[tool] ?? {
      'icon': Icons.check_circle,
      'text': tool.replaceAll('_', ' ').toUpperCase(),
    };
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(toolInfo['icon'] as IconData, color: const Color(0xFF4FAFBE), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              toolInfo['text'] as String,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleConnect() async {
    setState(() => _isConnecting = true);
    
    try {
      final provider = Provider.of<IntegrationProvider>(context, listen: false);
      final success = await provider.connectIntegration(widget.integration.id);
      
      if (mounted) {
        setState(() => _isConnecting = false);
        
        if (success) {
          // Success - show confirmation and go back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.integration.name} connected successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Wait a moment for user to see the message, then go back
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          // Error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to connect ${widget.integration.name}. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConnecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}


