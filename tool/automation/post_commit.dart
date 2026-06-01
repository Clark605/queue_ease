import 'dart:io';

import 'automation.dart';

void main() {
  final context = AutomationContext();

  try {
    if (!context.commitTouchedRulesFile()) {
      stdout.writeln(
        'No firestore.rules changes detected. Skipping Firestore deploy.',
      );
      return;
    }

    stdout.writeln(
      'firestore.rules changed in the last commit. Deploying dev rules.',
    );
    context.runRulesDeployment();
  } on AutomationFailure catch (error) {
    stderr.writeln(error);
    exit(error.exitCode == 0 ? 1 : error.exitCode);
  }
}
