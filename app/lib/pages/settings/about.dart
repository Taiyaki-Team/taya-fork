import 'package:flutter/material.dart';
import 'package:omi/pages/settings/webview.dart';
import 'package:omi/utils/analytics/intercom.dart';
import 'package:omi/utils/analytics/mixpanel.dart';
import 'package:omi/utils/other/temp.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutOmiPage extends StatefulWidget {
  const AboutOmiPage({super.key});

  @override
  State<AboutOmiPage> createState() => _AboutOmiPageState();
}

class _AboutOmiPageState extends State<AboutOmiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('About Taya'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
              title: const Text('Privacy Policy', style: TextStyle(color: const Color(0xFF0D1F40))),
              trailing: const Icon(Icons.privacy_tip_outlined, size: 20),
              onTap: () {
                MixpanelManager().pageOpened('About Privacy Policy');
                routeToPage(
                  context,
                  const PageWebView(url: 'https://www.tayanecklace.com/pages/privacy', title: 'Privacy Policy'),
                );
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
              title: const Text('Visit Website', style: TextStyle(color: const Color(0xFF0D1F40))),
              subtitle: const Text('https://tayanecklace.com'),
              trailing: const Icon(Icons.language_outlined, size: 20),
              onTap: () {
                MixpanelManager().pageOpened('About Visit Website');
                // routeToPage(context, const PageWebView(url: 'https://www.omi.me/', title: 'omi'));
                launchUrl(Uri.parse('https://tayanecklace.com/'));
              },
            ),
            ListTile(
              title: const Text('Help or Inquiries?', style: TextStyle(color: const Color(0xFF0D1F40))),
              subtitle: const Text('team@tayanecklace.com'),
              contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
              trailing: const Icon(Icons.help_outline_outlined, color: const Color(0xFF0D1F40), size: 20),
              onTap: () async {
                await IntercomManager.instance.intercom.displayMessenger();
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
              title: const Text('Join the community!', style: TextStyle(color: const Color(0xFF0D1F40))),
              subtitle: const Text('8000+ members and counting.'),
              trailing: const Icon(Icons.discord, color: Color(0xFF4FAFBE), size: 20),
              onTap: () {
                MixpanelManager().pageOpened('About Join Discord');
                launchUrl(Uri.parse('http://discord.tayanecklace.com'));
              },
            ),
          ],
        ),
      ),
    );
  }
}
