import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class BackendService {
  final String baseUrl = 'http://localhost:8000';

  Future<Map<String, dynamic>> generateCode({
    required String prompt,
    required String language,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        'language': language,
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate code: ${response.body}');
    }
  }

  // SSE Stream for progress tracking
  Stream<Map<String, dynamic>> generateCodeStream({
    required String prompt,
    required String language,
    required String userId,
    bool useMock = false,
  }) async* {
    try {
      final endpoint = useMock ? '/generate/stream/mock' : '/generate/stream';
      final request = http.Request('POST', Uri.parse('$baseUrl$endpoint'))
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode({
          'prompt': prompt,
          'language': language,
          'user_id': userId,
        });

      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        yield {'step': 'error', 'error': 'Failed to connect to stream: ${response.statusCode}'};
        return;
      }

      final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());

      await for (final line in stream) {
        if (line.startsWith('data: ')) {
          final dataString = line.substring(6).trim();
          if (dataString.isNotEmpty) {
            try {
              final json = jsonDecode(dataString);
              yield json;
            } catch (e) {
              print('Error parsing SSE data: $dataString -> $e');
            }
          }
        }
      }
    } catch (e) {
      yield {'step': 'error', 'error': e.toString()};
    }
  }
}
