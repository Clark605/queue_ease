import 'dart:io';

import 'automation.dart';

void main() {
  final context = AutomationContext();

  try {
    context.ensureEnvPlaceholders();
    context.runFormatCheck();
    context.runAnalyze();
    context.runTests();
  } on AutomationFailure catch (error) {
    stderr.writeln(error);
    exit(error.exitCode == 0 ? 1 : error.exitCode);
  }
}
