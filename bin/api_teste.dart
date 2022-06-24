import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io; 
import 'package:supabase/supabase.dart';

const _hostName = 'localhost';

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '8080';
  var port = int.tryParse(portStr);

  if(port == null){
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    exitCode = 64;
    return;
  }

  var handler = const shelf.Pipeline()
    .addMiddleware(shelf.logRequests())
    .addHandler(_echoRequest);

  var server = await io.serve(handler, _hostName, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

Future<shelf.Response> _echoRequest(shelf.Request request) async {
  switch(request.url.toString()){
    case 'users': return _echoUsers(request);
    default: return shelf.Response.ok('Invalid url');
  }
}

Future<shelf.Response> _echoUsers(shelf.Request request) async {
  final client = SupabaseClient(
    'https://fazzghkkqtivabxqisfk.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhenpnaGtrcXRpdmFieHFpc2ZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NTYwNzgyNjgsImV4cCI6MTk3MTY1NDI2OH0.tqrX_XGo6V7cfIlpX5bXgG9q1KAj6Qki1CPt78oWdzk'
  );

  final response = await client.from('user').select().execute();

  var map = {
    'users': response.data
  }

  return shelf.Response.ok(jsonEncode(map));
}