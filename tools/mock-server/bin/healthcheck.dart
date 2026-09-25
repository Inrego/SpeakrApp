// Container health probe for the Speakr mock server.
//
// It exists because the runtime image is `FROM scratch` — there is no shell,
// no curl and no wget to hand to `HEALTHCHECK`. This compiles to a second
// small AOT binary that hits the unauthenticated banner route (`GET /`) and
// exits 0 only when it answers 200 with the expected service name.
//
// Port: `--port`, else `$SPEAKR_MOCK_PORT`, else 8420.

import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  var port = int.tryParse(
        Platform.environment['SPEAKR_MOCK_PORT'] ?? '',
      ) ??
      8420;

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--port' && i + 1 < args.length) {
      port = int.tryParse(args[i + 1]) ?? port;
    } else if (args[i].startsWith('--port=')) {
      port = int.tryParse(args[i].substring('--port='.length)) ?? port;
    }
  }

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
  try {
    final request = await client.getUrl(Uri.parse('http://127.0.0.1:$port/'));
    final response =
        await request.close().timeout(const Duration(seconds: 3));
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      stderr.writeln('unhealthy: GET / returned ${response.statusCode}');
      exit(1);
    }
    if (!body.contains('speakr-mock-server')) {
      stderr.writeln('unhealthy: unexpected banner: $body');
      exit(1);
    }
    exit(0);
  } catch (e) {
    stderr.writeln('unhealthy: $e');
    exit(1);
  } finally {
    client.close(force: true);
  }
}
