import 'package:flutter/material.dart';
import 'package:omi/backend/schema/integration.dart';
import 'package:omi/pages/apps/integration_detail_page.dart';
import 'package:omi/pages/apps/integration_setup_page.dart';
import 'package:omi/pages/apps/widgets/integration_card.dart';
import 'package:omi/pages/apps/widgets/location_settings_sheet.dart';
import 'package:omi/providers/integration_provider.dart';
import 'package:provider/provider.dart';

class AppsPage extends StatefulWidget {
  final bool showAppBar;
  const AppsPage({super.key, this.showAppBar = false});

  @override
  State<AppsPage> createState() => AppsPageState();
}

class AppsPageState extends State<AppsPage> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IntegrationProvider>().loadIntegrations();
    });
  }

  void scrollToTop() {
    // Can be used if we add scroll functionality later
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              automaticallyImplyLeading: true,
              title: const Text('Integrations'),
              centerTitle: true,
              elevation: 0,
            )
          : null,
      body: Consumer<IntegrationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.white70),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading integrations',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadIntegrations(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Integrations',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Connect your conversations to the tools you use',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Built-in Section
              if (provider.builtinIntegrations.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'BUILT-IN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final integration = provider.builtinIntegrations[index];
                      return IntegrationCard(
                        integration: integration,
                        onTap: () => _handleBuiltinIntegrationTap(context, integration, provider),
                      );
                    },
                    childCount: provider.builtinIntegrations.length,
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Optional Integrations Section
              if (provider.optionalIntegrations.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'CONNECT SERVICES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final integration = provider.optionalIntegrations[index];
                      return IntegrationCard(
                        integration: integration,
                        onTap: () => _handleOptionalIntegrationTap(context, integration),
                      );
                    },
                    childCount: provider.optionalIntegrations.length,
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  void _handleBuiltinIntegrationTap(
    BuildContext context,
    Integration integration,
    IntegrationProvider provider,
  ) {
    // For built-in integrations (like location), show a detailed settings sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationSettingsSheet(
        integration: integration,
        provider: provider,
      ),
    );
  }

  void _handleOptionalIntegrationTap(BuildContext context, Integration integration) {
    // Navigate to setup or detail page based on connection status
    if (integration.isConnected) {
      // Already connected - show detail page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IntegrationDetailPage(integration: integration),
        ),
      );
    } else {
      // Not connected - show setup page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IntegrationSetupPage(integration: integration),
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
