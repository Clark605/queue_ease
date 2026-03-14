import 'package:flutter/material.dart';

class ContinueFooter extends StatelessWidget {
  const ContinueFooter({
    super.key,
    required this.enabled,
    required this.onContinue,
  });

  final bool enabled;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: enabled ? onContinue : null,
            child: const Text('Continue'),
          ),
        ),
      ),
    );
  }
}
