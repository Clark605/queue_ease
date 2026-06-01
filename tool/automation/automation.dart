import 'dart:io';

class AutomationContext {
  AutomationContext({String? repoRoot})
    : repoRoot = repoRoot ?? _resolveRepoRoot();

  final String repoRoot;

  void ensureEnvPlaceholders() {
    for (final relativePath in ['.env.dev', '.env.prod']) {
      final file = File(_resolvePath(relativePath));
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }
    }
  }

  void runFormatCheck() {
    _runCommand('dart', ['format', '.']);
  }

  void runAnalyze() {
    _runCommand('flutter', ['analyze']);
  }

  void runTests() {
    _runCommand('flutter', ['test']);
  }

  void runBuildRunner() {
    _runCommand('dart', [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);
  }

  void stageGeneratedDiOutputs() {
    _runCommand('git', ['add', 'lib/core/di']);
  }

  void installHooksPath() {
    _runCommand('git', ['config', 'core.hooksPath', '.githooks']);
  }

  void runRulesDeployment() {
    _runCommand('firebase', [
      'deploy',
      '--only',
      'firestore:rules',
      '--project',
      'ease-queue-dev',
    ]);
  }

  void runPubGet() {
    _runCommand('flutter', ['pub', 'get']);
  }

  void validateCommitMessage(String commitMessagePath) {
    final messageFile = File(commitMessagePath);
    if (!messageFile.existsSync()) {
      throw AutomationFailure(
        'commit message validation',
        1,
        'Commit message file not found: $commitMessagePath',
      );
    }

    final message = messageFile.readAsStringSync().trim();
    final commitPattern = RegExp(
      r'^(feat|fix|docs|style|refactor|perf|test|chore)(\([^)]+\))?: .+',
    );

    if (!commitPattern.hasMatch(message)) {
      throw AutomationFailure(
        'commit message validation',
        1,
        'Invalid commit message. Use: type(scope): description',
      );
    }
  }

  List<String> stagedFiles() {
    final result = _runCommand('git', [
      'diff',
      '--cached',
      '--name-only',
      '--diff-filter=ACMR',
    ], allowFailure: true);
    return _splitLines(
      result.stdout,
    ).where((line) => line.isNotEmpty).toList(growable: false);
  }

  bool shouldRunBuildRunner() {
    final files = stagedFiles();
    if (files.any(_isDiWatchPath)) {
      return true;
    }

    final watchedFiles = files
        .where(_isWatchedDartFile)
        .toList(growable: false);
    for (final path in watchedFiles) {
      final diff = _runCommand('git', [
        'diff',
        '--cached',
        '--unified=0',
        '--',
        path,
      ], allowFailure: true);

      if (_containsInjectableMarkers(diff.stdout) ||
          _containsInjectableMarkers(diff.stderr)) {
        return true;
      }
    }

    return false;
  }

  bool commitTouchedRulesFile() {
    final result = _runCommand('git', [
      'show',
      '--name-only',
      '--format=',
      'HEAD',
    ], allowFailure: true);
    return _splitLines(result.stdout).contains('firestore.rules');
  }

  String _resolvePath(String relativePath) =>
      '$repoRoot${Platform.pathSeparator}$relativePath';

  CommandResult _runCommand(
    String executable,
    List<String> arguments, {
    bool allowFailure = false,
  }) {
    final processResult = Process.runSync(
      executable,
      arguments,
      workingDirectory: repoRoot,
      runInShell: true,
    );

    final commandLine = [executable, ...arguments].join(' ');
    stdout.writeln('> $commandLine');
    _writeProcessOutput(processResult.stdout, stdout);
    _writeProcessOutput(processResult.stderr, stderr);

    final result = CommandResult(
      exitCode: processResult.exitCode,
      stdout: processResult.stdout.toString(),
      stderr: processResult.stderr.toString(),
    );

    if (result.exitCode != 0 && !allowFailure) {
      throw AutomationFailure(
        commandLine,
        result.exitCode,
        result.stderr.isEmpty ? result.stdout : result.stderr,
      );
    }

    return result;
  }

  static String _resolveRepoRoot() {
    final result = Process.runSync('git', [
      'rev-parse',
      '--show-toplevel',
    ], runInShell: true);

    if (result.exitCode != 0) {
      throw AutomationFailure(
        'git rev-parse --show-toplevel',
        result.exitCode,
        result.stderr.toString(),
      );
    }

    return result.stdout.toString().trim();
  }

  static void _writeProcessOutput(Object? value, IOSink sink) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return;
    }

    sink.writeln(text);
  }

  static List<String> _splitLines(String value) {
    return value
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .toList(growable: false);
  }

  static bool _isDiWatchPath(String path) {
    return path.startsWith('lib/core/di/') ||
        path == 'pubspec.yaml' ||
        path == 'pubspec.lock';
  }

  static bool _isWatchedDartFile(String path) {
    return path.startsWith('lib/') && path.endsWith('.dart');
  }

  static bool _containsInjectableMarkers(String text) {
    const markers = [
      '@injectable',
      '@lazySingleton',
      '@LazySingleton',
      '@module',
      '@InjectableInit',
    ];
    return markers.any(text.contains);
  }
}

class CommandResult {
  const CommandResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
}

class AutomationFailure implements Exception {
  AutomationFailure(this.command, this.exitCode, this.message);

  final String command;
  final int exitCode;
  final String message;

  @override
  String toString() => 'Command failed ($exitCode): $command\n$message';
}
