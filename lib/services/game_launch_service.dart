import 'dart:io';

import 'package:path/path.dart' as p;

import 'path_service.dart';

class GameLaunchRequest {
  const GameLaunchRequest({required this.gameRoot, required this.debugMode});

  final String gameRoot;
  final bool debugMode;
}

class GameLaunchResult {
  const GameLaunchResult({
    required this.exe,
    required this.args,
    required this.pid,
  });

  final String exe;
  final List<String> args;
  final String pid;

  String get displayCommand => '$exe ${args.join(' ')}'.trim();
}

class GameLaunchService {
  const GameLaunchService();

  Future<GameLaunchResult> launch(GameLaunchRequest request) async {
    final exe = PathService.findGameExe(request.gameRoot);
    if (exe.isEmpty) {
      throw const GameExecutableNotFoundException();
    }
    final args = request.debugMode ? ['-debug_mode'] : <String>[];
    final pid = await _startGameProcess(exe, args);
    return GameLaunchResult(exe: exe, args: args, pid: pid);
  }

  Future<String> _startGameProcess(String exe, List<String> args) async {
    if (!Platform.isWindows) {
      final process = await Process.start(
        exe,
        args,
        workingDirectory: p.dirname(exe),
        mode: ProcessStartMode.detached,
      );
      return process.pid.toString();
    }

    const script = r'''
$ErrorActionPreference = 'Stop'
$file = $env:VIC3_LAUNCH_FILE
$work = $env:VIC3_LAUNCH_WORK
$argLine = $env:VIC3_LAUNCH_ARGS
if ([string]::IsNullOrWhiteSpace($argLine)) {
  $process = Start-Process -FilePath $file -WorkingDirectory $work -PassThru
} else {
  $process = Start-Process -FilePath $file -WorkingDirectory $work -ArgumentList $argLine -PassThru
}
$process.Id
''';
    final result = await Process.run(
      'powershell',
      ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', script],
      environment: {
        'VIC3_LAUNCH_FILE': exe,
        'VIC3_LAUNCH_WORK': p.dirname(exe),
        'VIC3_LAUNCH_ARGS': args.join(' '),
      },
    );
    if (result.exitCode != 0) {
      final stderr = result.stderr.toString().trim();
      final stdout = result.stdout.toString().trim();
      throw Exception(
        [
          if (stderr.isNotEmpty) stderr,
          if (stdout.isNotEmpty) stdout,
          if (stderr.isEmpty && stdout.isEmpty)
            'PowerShell Start-Process exit code ${result.exitCode}',
        ].join('\n'),
      );
    }
    return result.stdout.toString().trim();
  }
}

class GameExecutableNotFoundException implements Exception {
  const GameExecutableNotFoundException();

  @override
  String toString() {
    return 'victoria3.exe tidak ditemukan. Pilih folder install Victoria 3 yang benar.';
  }
}
