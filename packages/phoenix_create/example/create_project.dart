import 'dart:io';

Future<void> main() async {
  final result = await Process.run('dart', [
    'run',
    'phoenix_flutter:phoenix_create@',
    'create',
    'my_app',
    '--org',
    'com.acme',
    '--title',
    'My App',
    '--api-host',
    'localhost:4000',
  ]);

  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    exitCode = result.exitCode;
  }
}
