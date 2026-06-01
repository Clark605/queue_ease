import 'dart:io';

import 'automation.dart';

void main() {
  final context = AutomationContext();

  try {
    context.ensureEnvPlaceholders();
    context.runPubGet();
    context.installHooksPath();

    stdout.writeln('Hooks installed at .githooks.');
    stdout.writeln(
      'Run `dart run tool/automation/pre_commit.dart` to verify the local hook flow.',
    );
    stdout.writeln(
      'Make sure the Firebase CLI is installed before committing firestore.rules changes.',
    );
  } on AutomationFailure catch (error) {
    stderr.writeln(error);
    exit(error.exitCode == 0 ? 1 : error.exitCode);
  }
}
