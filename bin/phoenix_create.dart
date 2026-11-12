import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

const _usage = '''
Usage:
  dart run phoenix_flutter:phoenix_create@ create <project_name> [options]

Options:
  --org <reverse-domain>  Organization identifier (default: com.example)
  --title <app title>     Visible app title (default: derived from project name)
  --api-host <host:port>  Phoenix host (default: localhost:4000)
  --output <directory>   Destination directory (default: <project_name>)
  -h, --help              Show this help
''';

Future<void> main(List<String> args) async {
  try {
    await _run(args);
  } on FormatException catch (error) {
    stderr.writeln('Error: ${error.message}\n\n$_usage');
    exitCode = 64;
  } on FileSystemException catch (error) {
    stderr.writeln('File error: ${error.message}');
    exitCode = 1;
  } on ProcessException catch (error) {
    stderr.writeln(
      'Command failed: ${error.executable} ${error.arguments.join(' ')}',
    );
    exitCode = 1;
  }
}

Future<void> _run(List<String> args) async {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    stdout.write(_usage);
    return;
  }
  if (args.length < 2 || args.first != 'create') {
    throw const FormatException('Use "create <project_name>".');
  }
  final projectName = args[1];
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(projectName)) {
    throw const FormatException(
      'Project name must start with a lowercase letter and contain only lowercase letters, digits, and underscores.',
    );
  }

  final options = _parseOptions(args.skip(2).toList());
  final orgId = options['org'] ?? 'com.example';
  if (!RegExp(r'^[A-Za-z][A-Za-z0-9]*(\.[A-Za-z][A-Za-z0-9]*)+$')
      .hasMatch(orgId)) {
    throw const FormatException(
      'Organization ID must be reverse-domain form, such as com.acme.',
    );
  }
  final apiHost = options['api-host'] ?? 'localhost:4000';
  if (apiHost.isEmpty || apiHost.contains('://') || apiHost.contains('/')) {
    throw const FormatException(
      'API host must be a host and optional port, without a scheme or path.',
    );
  }
  final appTitle = options['title'] ?? _titleFrom(projectName);
  final output = Directory(options['output'] ?? projectName);
  if (await output.exists()) {
    final existingEntries = await output.list().take(1).toList();
    if (existingEntries.isNotEmpty) {
      throw FormatException('Output directory is not empty: ${output.path}');
    }
  }

  final template = await _resolveTemplateDirectory();
  await output.create(recursive: true);
  final values = <String, String>{
    '__PROJECT_NAME__': projectName,
    '__ORG_ID__': orgId,
    '__ORG_PATH__': orgId.split('.').join(Platform.pathSeparator),
    '__APP_TITLE__': appTitle,
    '__API_HOST__': apiHost,
  };

  await for (final entity in template.list(
    recursive: true,
    followLinks: false,
  )) {
    final relative = entity.path.substring(template.path.length + 1);
    if (_skipRelativePath(relative)) continue;
    final renderedRelative = _replace(relative, values);
    final targetPath =
        '${output.path}${Platform.pathSeparator}$renderedRelative';
    if (entity is Directory) {
      await Directory(targetPath).create(recursive: true);
    } else if (entity is File) {
      final target = File(targetPath);
      await target.parent.create(recursive: true);
      final bytes = await entity.readAsBytes();
      try {
        await target.writeAsString(
          _replace(utf8.decode(bytes), values),
          flush: true,
        );
      } on FormatException {
        await target.writeAsBytes(bytes, flush: true);
      }
    }
  }

  stdout.writeln('Created ${output.path}');
  stdout.writeln('Fetching Flutter dependencies...');
  final result = await Process.run(
    'flutter',
    ['pub', 'get'],
    workingDirectory: output.absolute.path,
    runInShell: Platform.isWindows,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    throw const ProcessException('flutter', ['pub', 'get']);
  }
  stdout.writeln('Project ready. Run: cd ${output.path} && flutter run');
}

Future<Directory> _resolveTemplateDirectory() async {
  final script = File.fromUri(Platform.script);
  final packageRoot = script.parent.parent;
  final localTemplate = Directory(
    '${packageRoot.path}${Platform.pathSeparator}templates'
    '${Platform.pathSeparator}phoenix_flutter',
  );
  if (await localTemplate.exists()) return localTemplate;

  final packageUri = await Isolate.resolvePackageUri(
    Uri.parse('package:phoenix_flutter/templates/phoenix_flutter/'),
  );
  if (packageUri != null && packageUri.scheme == 'file') {
    final installedTemplate = Directory.fromUri(packageUri);
    if (await installedTemplate.exists()) return installedTemplate;
  }

  throw FileSystemException(
    'Bundled Flutter template is missing from the installed phoenix_flutter package.',
    localTemplate.path,
  );
}

Map<String, String> _parseOptions(List<String> args) {
  const supported = {'org', 'title', 'api-host', 'output'};
  final values = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (!arg.startsWith('--'))
      throw FormatException('Unexpected argument: $arg');
    final parts = arg.substring(2).split('=');
    final key = parts.first;
    if (!supported.contains(key))
      throw FormatException('Unknown option: --$key');
    if (parts.length > 1) {
      values[key] = parts.skip(1).join('=');
    } else {
      if (i + 1 >= args.length || args[i + 1].startsWith('--'))
        throw FormatException('Missing value for --$key');
      values[key] = args[++i];
    }
  }
  return values;
}

String _replace(String input, Map<String, String> values) {
  var output = input;
  for (final entry in values.entries) {
    output = output.replaceAll(entry.key, entry.value);
  }
  return output;
}

bool _skipRelativePath(String relative) => relative
    .split(Platform.pathSeparator)
    .any(
      (segment) =>
          segment == '.git' ||
          segment == '.dart_tool' ||
          segment == 'build' ||
          segment == 'ephemeral' ||
          segment == 'local.properties' ||
          segment == 'Generated.xcconfig' ||
          segment == 'flutter_export_environment.sh' ||
          segment == '.flutter-plugins-dependencies',
    );

String _titleFrom(String projectName) => projectName
    .split('_')
    .map(
      (part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}',
    )
    .join(' ');
