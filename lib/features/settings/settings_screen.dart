import 'package:flutter/material.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Language'),
            subtitle: Text('Somali / Arabic / English'),
          ),
          ListTile(
            title: Text('About'),
            subtitle: Text(AppConstants.appName),
          ),
        ],
      ),
    );
  }
}
