import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/detection_provider.dart';
import '../models/detection_result.dart';
import '../utils/theme.dart';

// Fake News Detector
class FakeNewsDetector extends StatefulWidget {
  const FakeNewsDetector({super.key});

  @override
  State<FakeNewsDetector> createState() => _FakeNewsDetectorState();
}

class _FakeNewsDetectorState extends State<FakeNewsDetector> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetectionProvider>(
      builder: (context, provider, _) {
        return DetectorTemplate(
          title: 'Fake News Detector',
          description:
          'Paste a news article to analyze it for misinformation and bias.',
          isLoading: provider.isLoading,
          result: provider.result,
          onAnalyze: () {
            if (_controller.text.trim().isNotEmpty) {
              provider.detectFakeNews(_controller.text.trim());
            }
          },
          canAnalyze: _controller.text.trim().isNotEmpty,
          child: TextField(
            controller: _controller,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Paste the full text of the news article here...',
            ),
            onChanged: (_) => setState(() {}),
          ),
        );
      },
    );
  }
}

// Malicious URL Detector
class MaliciousUrlDetector extends StatefulWidget {
  const MaliciousUrlDetector({super.key});

  @override
  State<MaliciousUrlDetector> createState() => _MaliciousUrlDetectorState();
}

class _MaliciousUrlDetectorState extends State<MaliciousUrlDetector> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetectionProvider>(
      builder: (context, provider, _) {
        return DetectorTemplate(
          title: 'Malicious URL Detector',
          description: 'Enter a URL to check for phishing or malware.',
          isLoading: provider.isLoading,
          result: provider.result,
          onAnalyze: () {
            if (_controller.text.trim().isNotEmpty) {
              provider.detectMaliciousUrl(_controller.text.trim());
            }
          },
          canAnalyze: _controller.text.trim().isNotEmpty,
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'https://example.com',
              prefixIcon: Icon(Icons.link),
            ),
            onChanged: (_) => setState(() {}),
          ),
        );
      },
    );
  }
}

// AI Image Detector
class AiImageDetector extends StatefulWidget {
  const AiImageDetector({super.key});

  @override
  State<AiImageDetector> createState() => _AiImageDetectorState();
}

class _AiImageDetectorState extends State<AiImageDetector> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      final provider = Provider.of<DetectionProvider>(context, listen: false);
      provider.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetectionProvider>(
      builder: (context, provider, _) {
        return DetectorTemplate(
          title: 'AI Image Detector',
          description: 'Upload an image to check if it was AI-generated.',
          isLoading: provider.isLoading,
          result: provider.result,
          onAnalyze: () {
            if (_imageFile != null) {
              provider.detectAiImage(_imageFile!);
            }
          },
          canAnalyze: _imageFile != null,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accent, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary,
              ),
              child: _imageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, fit: BoxFit.contain),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      size: 48, color: AppColors.light),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload image',
                    style: TextStyle(color: AppColors.light),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Fake Audio Detector
class FakeAudioDetector extends StatefulWidget {
  const FakeAudioDetector({super.key});

  @override
  State<FakeAudioDetector> createState() => _FakeAudioDetectorState();
}

class _FakeAudioDetectorState extends State<FakeAudioDetector> {
  String? _audioFileName;
  File? _audioFile;

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      setState(() {
        _audioFileName = result.files.single.name;
        _audioFile = File(path);
      });
      final provider = Provider.of<DetectionProvider>(context, listen: false);
      provider.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetectionProvider>(
      builder: (context, provider, _) {
        return DetectorTemplate(
          title: 'Fake Audio Detector',
          description: 'Upload an audio file to analyze if it is AI-generated or real.',
          isLoading: provider.isLoading,
          result: provider.result,
          onAnalyze: () {
            if (_audioFile != null) {
              // Calls provider method that should perform the upload + analysis against your Render backend
              provider.analyzeAudio(_audioFile!);
            }
          },
          canAnalyze: _audioFile != null,
          child: GestureDetector(
            onTap: _pickAudio,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accent, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.audiotrack_outlined,
                      size: 48, color: AppColors.light),
                  const SizedBox(height: 8),
                  Text(
                    _audioFileName ?? 'Tap to upload audio (required for analysis)',
                    style: TextStyle(color: AppColors.light),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Detector Template Widget
class DetectorTemplate extends StatelessWidget {
  final String title;
  final String description;
  final bool isLoading;
  final DetectionResult? result;
  final VoidCallback onAnalyze;
  final bool canAnalyze;
  final Widget child;

  const DetectorTemplate({
    super.key,
    required this.title,
    required this.description,
    required this.isLoading,
    required this.result,
    required this.onAnalyze,
    required this.canAnalyze,
    required this.child,
  });

  Color _getVerdictColor(String verdict, double score) {
    final lower = verdict.toLowerCase();
    if (lower.contains('fake') ||
        lower.contains('malicious') ||
        lower.contains('ai-generated')) {
      if (score > 60) return AppColors.danger;
      if (score > 30) return AppColors.warning;
      return AppColors.success;
    }
    if (lower.contains('authentic') ||
        lower.contains('real') ||
        lower.contains('safe')) {
      if (score > 60) return AppColors.success;
      if (score > 30) return AppColors.warning;
      return AppColors.danger;
    }
    return AppColors.light;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(color: AppColors.light),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                child,
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: (isLoading || !canAnalyze) ? null : onAnalyze,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text('Analyze'),
                ),
              ],
            ),
          ),
        ),
        if (result != null) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analysis Result',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Verdict: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        result!.verdict,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getVerdictColor(
                              result!.verdict, result!.score),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Confidence Score:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: result!.score / 100,
                    backgroundColor: AppColors.primary,
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result!.score.toStringAsFixed(0)}% confidence',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.light),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Explanation:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result!.explanation,
                    style: const TextStyle(color: AppColors.light),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
