// lib/providers/detection_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:multi_detection_system/models/detection_result.dart';
import 'package:multi_detection_system/services/gemini_service.dart';

/// Enum used across the app
enum DetectionType { news, url, image, audio }

class DetectionProvider extends ChangeNotifier {
  DetectionType currentType = DetectionType.news;

  bool isLoading = false;

  DetectionResult? result;

  Map<String, dynamic>? lastMetadata;

  final GeminiService _api = GeminiService();

  void setDetectionType(DetectionType t) {
    if (t == currentType) return;
    currentType = t;
    notifyListeners();
  }

  void clearResult() {
    result = null;
    lastMetadata = null;
    notifyListeners();
  }

  Future<void> detectFakeNews(String text, {String? sourceUrl}) async {
    isLoading = true;
    notifyListeners();
    try {
      final resp = await _api.detectFakeNews(text, sourceUrl: sourceUrl);
      result = resp;
      lastMetadata = {
        'type': 'news',
        'length': text.length,
        'source_url': sourceUrl ?? '',
        'checkedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      result = DetectionResult(
        verdict: 'Error',
        score: 0,
        explanation: 'Network error: ${e.toString()}',
      );
      lastMetadata = {'error': e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> detectMaliciousUrl(String url) async {
    isLoading = true;
    notifyListeners();
    try {
      final resp = await _api.detectMaliciousUrl(url);
      result = resp;
      lastMetadata = {'type': 'url', 'url': url, 'checkedAt': DateTime.now().toIso8601String()};
    } catch (e) {
      result = DetectionResult(
        verdict: 'Error',
        score: 0,
        explanation: 'Network error: ${e.toString()}',
      );
      lastMetadata = {'error': e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> detectAiImage(File image) async {
    isLoading = true;
    notifyListeners();
    try {
      final resp = await _api.detectAiImage(image);
      result = resp;
      final size = await image.length();
      lastMetadata = {'type': 'image', 'path': image.path, 'size': size, 'checkedAt': DateTime.now().toIso8601String()};
    } catch (e) {
      result = DetectionResult(
        verdict: 'Error',
        score: 0,
        explanation: 'Network error: ${e.toString()}',
      );
      lastMetadata = {'error': e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyzeAudio(File audioFile) async {
    isLoading = true;
    notifyListeners();
    try {
      final resp = await _api.analyzeAudioCharacteristics(audioFile);
      result = resp;
      lastMetadata = {'type': 'audio', 'path': audioFile.path, 'checkedAt': DateTime.now().toIso8601String()};
    } catch (e) {
      result = DetectionResult(
        verdict: 'Error',
        score: 0,
        explanation: 'Network error: ${e.toString()}',
      );
      lastMetadata = {'error': e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
