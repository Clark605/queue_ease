import 'dart:io';

import 'automation.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    stderr.writeln('Missing commit message file path.');
    exit(1);
  }

  final context = AutomationContext();

  try {
    context.validateCommitMessage(arguments.first);
  } on AutomationFailure catch (error) {
    stderr.writeln(error);
    exit(error.exitCode == 0 ? 1 : error.exitCode);
  }
}
