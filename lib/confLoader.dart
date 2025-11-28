import 'dart:io';

import 'package:yaml/yaml.dart';

Future<Map<String,dynamic>> confLoader() async {
  final conf = File('config.yaml');
  if(!await conf.exists()) {
    print('Configuration file does not exist. Creating default one...');
    await conf.writeAsString('''
    host: "localhost"
    port: 8080
    mockDir: "mocks"
    ''');
    print('Default configuration file created.');
  }

  final confContent = await conf.readAsString();
  final yamlMap = loadYaml(confContent);
  return Map<String,dynamic>.from(yamlMap);

}