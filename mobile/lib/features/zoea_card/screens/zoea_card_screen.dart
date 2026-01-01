import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';

class ZoeaCardScreen extends ConsumerStatefulWidget {
  const ZoeaCardScreen({super.key});

  @override
  ConsumerState<ZoeaCardScreen> createState() => _ZoeaCardScreenState();
}

class _ZoeaCardScreenState extends ConsumerState<ZoeaCardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Zoea Card'),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.credit_card,
              size: 64,
              color: context.primaryColorTheme,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'Zoea Card',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppTheme.spacing8),
            const Text(
              'Your digital wallet for seamless payments',
              style: TextStyle(
                color: context.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
