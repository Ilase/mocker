import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('No version provided');
    exit(1);
  }
  final newVersion = args.first.trim();

  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) exit(1);

  final content = await pubspec.readAsString();
  final updated = content.replaceFirst(RegExp(r'version:\s*[^\n]+'), 'version: $newVersion');

  await pubspec.writeAsString(updated);
  print('Updated pubspec.yaml to version $newVersion');
}