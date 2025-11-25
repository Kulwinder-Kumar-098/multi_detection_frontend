// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/detection_provider.dart';
import '../utils/theme.dart';
import '../widgets/detector_widgets.dart';
import '../widgets/feedback_container.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DetectionProvider>(
      builder: (context, detectionProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.light),
                const SizedBox(width: 8),
                const Text('Veritas Suite'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildDetector(detectionProvider.currentType),
                ),
              ),
              const FeedbackContainer(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: detectionProvider.currentType.index,
            onTap: (index) {
              detectionProvider.setDetectionType(DetectionType.values[index]);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.secondary,
            selectedItemColor: AppColors.text,
            unselectedItemColor: AppColors.light,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                label: 'News',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.link),
                label: 'URL',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.image_outlined),
                label: 'Image',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.audiotrack_outlined),
                label: 'Audio',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetector(DetectionType type) {
    switch (type) {
      case DetectionType.news:
        return const FakeNewsDetector();
      case DetectionType.url:
        return const MaliciousUrlDetector();
      case DetectionType.image:
        return const AiImageDetector();
      case DetectionType.audio:
        return const FakeAudioDetector();
    }

    // Defensive fallback to keep Dart analyzer happy (shouldn't reach here)
    return const SizedBox.shrink();
  }
}
