import 'package:flutter/material.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: const Center(
        child: Text('Reciters will appear here'),
      ),
    );
  }
}
