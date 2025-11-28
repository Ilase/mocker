import 'dart:io';
import 'package:mocker/confLoader.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';



Future<void> main() async {

  final config = await confLoader();
  final serveHost = config['host'] ?? 'localhost';
  final servePort = config['port'] ?? 8080;
  final serveMockDir = config['mockDir'] ?? 'mocks';

  final router = Router();
  final Directory mockDir = Directory(serveMockDir);
  
  
  ///
  if(!await mockDir.exists()){
    print('Mock directory does not exists. Creating...');
    await mockDir.create(recursive: true);
    new File('${mockDir.path}/GET.json').create(recursive: true).then((File file){
      file.writeAsString('''{"status" : "Works fine!"}''');
    });
    print('Mock directory created');
  } else {
    print('Mock directory already exists');
  }



  await for (final endpoint in mockDir.list(recursive: true, followLinks: false)){
    if(endpoint is File && endpoint.path.toLowerCase().endsWith('.json')){
      print( " --- " + endpoint.path);
    }
  }
  
  await for (final entity in mockDir.list(recursive: true, followLinks: false)){
    if(entity is! File) continue;
    if(!entity.path.endsWith('.json')) continue;

    final file = entity;
    final relativePath = file.path.replaceFirst(mockDir.path, '').replaceAll('\\', '/');

    final parts = relativePath.split('/').where((p) => p.isNotEmpty).toList();
    final filename = parts.removeLast();
    final method = filename.split('.').first.toUpperCase();

    final urlPath = parts.map((segment) {
      if(segment.startsWith('<') && segment.endsWith('>')){
        return segment;
      }
      return segment;
    }).join('/');
    final shelPath = '/' + urlPath;
    
    print('Register: $method $shelPath --> ${file.path}');
    final handler = (Request req) async {
      final text = await file.readAsString();
      return Response.ok(
        text,
        headers: {
          'ContentType' : 'application/json'
        }
      );
    };

    switch (method) {
      case 'GET':
        router.get(shelPath, handler);
        break;
      case 'POST':
        router.post(shelPath, handler);
        break;
      case 'PUT':
        router.put(shelPath, handler);
        break;
      case 'DELETE':
        router.delete(shelPath, handler);
        break;
      case 'PATCH':
        router.patch(shelPath, handler);
        break;
      default:
        print('Unknown method in: $method (${file.path})');
    }
  }



  final handler = Pipeline()
    .addMiddleware(logRequests())
    .addHandler(router);
  final server = await io.serve(handler, serveHost, servePort);
  print('Mock server running: ${server.address.host}:${server.port}');
}