import 'dart:convert';
import 'dart:io';
import 'dart:math';

final _random = Random();

dynamic generateMock(dynamic schema) {
  if (schema is String) {
    switch (schema) {
      case 'string':
        return 'mock_${_random.nextInt(1000)}';
      case 'number':
        return _random.nextInt(100);
      case 'boolean':
        return _random.nextBool();
      default:
        return null;
    }
  } else if (schema is List && schema.length == 1) {
    // Генерация массива
    return List.generate(_random.nextInt(5) + 1, (_) => generateMock(schema[0]));
  } else if (schema is Map<String, dynamic>) {
    // Вложенный объект
    final result = <String, dynamic>{};
    schema.forEach((key, value) {
      result[key] = generateMock(value);
    });
    return result;
  }
  return null;
}

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run generator.dart <template.json>');
    exit(1);
  }

  final file = File(args[0]);
  if (!await file.exists()) {
    print('File not found: ${args[0]}');
    exit(1);
  }

  final templateJson = await file.readAsString();
  final schema = jsonDecode(templateJson);

  final mockData = generateMock(schema);

  final outputJson = JsonEncoder.withIndent('  ').convert(mockData);
  print(outputJson);

  // Если нужно сохранить в файл:
  await File('mock_output.json').writeAsString(outputJson);
  print('Mock data saved to mock_output.json');
}
