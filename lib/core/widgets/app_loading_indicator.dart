import 'package:flutter/material.dart';

/// A centered, full-screen-safe loading indicator.
///
/// Use this as the standard loading state widget across all feature pages.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
