// lib/models/detection_result.dart
class DetectionResult {
  final String verdict;
  final double score;
  final String explanation;

  DetectionResult({
    required this.verdict,
    required this.score,
    required this.explanation,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    // Accept both "confidence" and "score", and accept nested analysis structures
    final double scoreVal = (() {
      if (json['score'] != null) {
        return (json['score'] as num).toDouble();
      }
      if (json['confidence'] != null) {
        return (json['confidence'] as num).toDouble();
      }
      // fallback default
      return 50.0;
    })();

    return DetectionResult(
      verdict: json['verdict']?.toString() ?? json['verdict']?.toString() ?? 'Uncertain',
      score: scoreVal,
      explanation: json['explanation']?.toString() ?? 'No explanation provided.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verdict': verdict,
      'score': score,
      'explanation': explanation,
    };
  }
}
