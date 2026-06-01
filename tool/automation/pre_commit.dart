import 'dart:io';

import 'automation.dart';

void main() {
  final context = AutomationContext();

  try {
    context.ensureEnvPlaceholders();

    if (context.shouldRunBuildRunner()) {
      stdout.writeln('DI change detected. Regenerating injectable output.');
      context.runBuildRunner();
      context.stageGeneratedDiOutputs();
    }

    context.runFormatCheck();
  } on AutomationFailure catch (error) {
    stderr.writeln(error);
    exit(error.exitCode == 0 ? 1 : error.exitCode);
  }
}
