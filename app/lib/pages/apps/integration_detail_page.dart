import 'package:flutter/material.dart';
import 'package:omi/backend/schema/integration.dart';
import 'package:omi/providers/integration_provider.dart';
import 'package:provider/provider.dart';

class IntegrationDetailPage extends StatefulWidget {
  final Integration integration;
  
  const IntegrationDetailPage({super.key, required this.integration});
  
  @override
  State<IntegrationDetailPage> createState() => _IntegrationDetailPageState();
}

class _IntegrationDetailPageState extends State<IntegrationDetailPage> {
  bool _isDisconnecting = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.integration.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and status
            Center(
              child: Column(
                children: [
                  Container(
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
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    widget.integration.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                        SizedBox(width: 6),
                        Text(
                          'Connected',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Description
            Text(
              widget.integration.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Features section
            const Text(
              'Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (widget.integration.tools != null)
              ...widget.integration.tools!.map((tool) => _buildFeatureItem(tool)),
            
            const SizedBox(height: 32),
            
            // Connection info
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white70, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Connection Info',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Status', 'Active'),
                  _buildInfoRow('Connected', _getConnectionTime()),
                  if (widget.integration.config != null && 
                      widget.integration.config!['connected_at'] != null)
                    _buildInfoRow('Since', _formatDate(widget.integration.config!['connected_at'])),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Disconnect button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _isDisconnecting ? null : _handleDisconnect,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isDisconnecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.red,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Disconnect',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(String tool) {
    final displayName = tool.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4FAFBE), size: 18),
          const SizedBox(width: 12),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getConnectionTime() {
    if (widget.integration.config != null && 
        widget.integration.config!['connected_at'] != null) {
      try {
        final connectedAt = DateTime.parse(widget.integration.config!['connected_at']);
        final now = DateTime.now();
        final difference = now.difference(connectedAt);
        
        if (difference.inDays > 0) {
          return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
        } else if (difference.inHours > 0) {
          return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
        } else if (difference.inMinutes > 0) {
          return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
        } else {
          return 'Just now';
        }
      } catch (e) {
        return 'Recently';
      }
    }
    return 'Recently';
  }
  
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
  
  Future<void> _handleDisconnect() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disconnect ${widget.integration.name}?'),
        content: const Text(
          'You can always reconnect later. Your data will remain safe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() => _isDisconnecting = true);
    
    try {
      final provider = Provider.of<IntegrationProvider>(context, listen: false);
      final success = await provider.disconnectIntegration(widget.integration.id);
      
      if (mounted) {
        setState(() => _isDisconnecting = false);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.integration.name} disconnected'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Go back to integrations page
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to disconnect. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDisconnecting = false);
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


