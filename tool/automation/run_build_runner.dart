import 'dart:io';

import 'automation.dart';

void main() {
  final context = AutomationContext();

  try {
    context.runBuildRunner();
    context.stageGeneratedDiOutputs();
  } on AutomationFailure catch (error) {
    stderr.writeln(error);
    exit(error.exitCode == 0 ? 1 : error.exitCode);
  }
}
