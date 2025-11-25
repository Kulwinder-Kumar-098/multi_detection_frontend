// lib/services/gemini_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:multi_detection_system/models/detection_result.dart';

class GeminiService {
  // Your live Render backend URL (use the one you provided)
  static const String _baseUrl = 'https://multi-detection-backend-1.onrender.com';

  // Timeout configuration
  static const Duration _timeout = Duration(seconds: 60);

  /// Parses backend response (the backend returns JSON with an "analysis" string
  /// which itself might be a JSON string).
  DetectionResult _parseResponseBody(Map<String, dynamic> body) {
    // If backend used the format { "analysis": "<json or text>", ... }
    final analysisRaw = body['analysis'];
    if (analysisRaw is String && analysisRaw.trim().isNotEmpty) {
      // Try to extract JSON from the string
      final cleaned = analysisRaw.replaceAll(RegExp(r'```json|```'), '').trim();

      // If the analysis contains a JSON object, decode it
      try {
        final start = cleaned.indexOf('{');
        final end = cleaned.lastIndexOf('}');
        if (start != -1 && end != -1 && end > start) {
          final candidate = cleaned.substring(start, end + 1);
          final json = jsonDecode(candidate);
          if (json is Map<String, dynamic>) {
            return DetectionResult.fromJson(json);
          }
        }
      } catch (_) {
        // fallthrough to try parse plain JSON
      }

      // If analysis itself is pure JSON:
      try {
        final json = jsonDecode(cleaned);
        if (json is Map<String, dynamic>) {
          return DetectionResult.fromJson(json);
        }
      } catch (_) {
        // Not JSON: fallback to text parsing
        return DetectionResult(
          verdict: _guessVerdictFromText(analysisRaw),
          score: _guessScoreFromText(analysisRaw),
          explanation: analysisRaw,
        );
      }
    }

    // If backend returned the detection directly at top-level
    if (body.containsKey('verdict') || body.containsKey('score') || body.containsKey('confidence')) {
      return DetectionResult.fromJson(body);
    }

    // Fallback: construct a generic DetectionResult
    return DetectionResult(
      verdict: 'Uncertain',
      score: 50.0,
      explanation: jsonEncode(body),
    );
  }

  String _guessVerdictFromText(String t) {
    final lower = t.toLowerCase();
    if (lower.contains('fake') || lower.contains('malicious') || lower.contains('ai-generated') || lower.contains('phish')) {
      return 'Fake/Malicious';
    }
    if (lower.contains('real') || lower.contains('authentic') || lower.contains('safe')) {
      return 'Real/Authentic';
    }
    return 'Uncertain';
  }

  double _guessScoreFromText(String t) {
    final m = RegExp(r'(\d{1,3})\s*%').firstMatch(t);
    if (m != null) {
      final val = int.tryParse(m.group(1) ?? '');
      if (val != null) return val.clamp(0, 100).toDouble();
    }
    return 50.0;
  }

  /// Generic POST helper
  Future<Map<String, dynamic>> _postMultipart(String path, {Map<String, String>? fields, List<http.MultipartFile>? files}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final req = http.MultipartRequest('POST', uri);
    if (fields != null) req.fields.addAll(fields);
    if (files != null) req.files.addAll(files);
    final streamed = await req.send().timeout(_timeout);
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode != 200) {
      throw HttpException('Server returned ${resp.statusCode}: ${resp.body}');
    }
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    return decoded;
  }

  /// Detect fake news
  Future<DetectionResult> detectFakeNews(String article, {String? sourceUrl}) async {
    final fields = <String, String>{'news_text': article};
    if (sourceUrl != null && sourceUrl.isNotEmpty) fields['source_url'] = sourceUrl;

    final body = await _postMultipart('/detect/news', fields: fields);
    return _parseResponseBody(body);
  }

  /// Detect malicious URL
  Future<DetectionResult> detectMaliciousUrl(String url) async {
    final body = await _postMultipart('/detect/url', fields: {'url': url});
    return _parseResponseBody(body);
  }

  /// Detect AI-generated image
  Future<DetectionResult> detectAiImage(File imageFile) async {
    final file = await http.MultipartFile.fromPath('file', imageFile.path);
    final body = await _postMultipart('/detect/image', files: [file]);
    return _parseResponseBody(body);
  }

  /// Analyze audio for AI generation
  Future<DetectionResult> analyzeAudioCharacteristics(File audioFile) async {
    final file = await http.MultipartFile.fromPath('file', audioFile.path);
    final body = await _postMultipart('/detect/audio', files: [file]);
    return _parseResponseBody(body);
  }

  /// Health check
  Future<bool> checkBackendHealth() async {
    try {
      final resp = await http.get(Uri.parse('$_baseUrl/health')).timeout(Duration(seconds: 8));
      if (resp.statusCode != 200) return false;
      final data = jsonDecode(resp.body);
      // The backend uses {"status":"healthy", "api_configured": true}
      return (data['status'] == 'healthy') && (data['api_configured'] == true);
    } catch (_) {
      return false;
    }
  }

  /// Wake up (GET /)
  Future<void> wakeUpBackend() async {
    try {
      await http.get(Uri.parse('$_baseUrl/')).timeout(Duration(seconds: 20));
    } catch (_) {}
  }
}
