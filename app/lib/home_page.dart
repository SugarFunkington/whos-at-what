import 'package:flutter/material.dart';

import 'styles/spacing.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: const Padding(
        padding: pagePadding,
        child: Text('Events will go here'),
      ),
    );
  }
}
