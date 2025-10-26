import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class OnboardingController extends GetxController {
  // 0=Step 1, 1=Step 2, 2=Step 3
  final currentStep = 0.obs;

  // Make the player reactive so Obx can rebuild properly
  final Rxn<VideoPlayerController> player = Rxn<VideoPlayerController>();

  // Replace with your actual asset paths
  final List<String> _videos = const [
    'assets/videos/step1.mp4', // Step 1 : Choose a category
    'assets/videos/step2.mp4', // Step 2 : Choose a Filter
    'assets/videos/step3.mp4', // Step 3 : Search & Result View
  ];

  Future<void> _loadStep(int index) async {
    // Dispose previous controller safely
    final old = player.value;
    if (old != null) {
      old.removeListener(_onTick);
      await old.pause();
      await old.dispose();
    }

    final c = VideoPlayerController.asset(_videos[index]);
    player.value = c; // set early so UI can show skeleton while initializing

    await c.initialize();
    c.setLooping(false);
    c.addListener(_onTick);
    await c.play();

    // Nudge listeners (Obx) to rebuild
    player.refresh();
    currentStep.refresh();
  }

  void _onTick() {
    final p = player.value;
    if (p == null) return;
    final v = p.value;
    if (v.isInitialized && !v.isPlaying && v.position >= v.duration) {
      nextStep();
    }
  }

  Future<void> nextStep() async {
    if (currentStep.value < _videos.length - 1) {
      currentStep.value++;
      await _loadStep(currentStep.value);
    } else {
      // Finished all steps; optionally navigate or loop
      // await restart(); // if you want to loop
    }
  }

  Future<void> restart() async {
    currentStep.value = 0;
    await _loadStep(0);
  }

  @override
  void onInit() {
    super.onInit();
    _loadStep(0);
  }

  @override
  void onClose() {
    final p = player.value;
    if (p != null) {
      p.removeListener(_onTick);
      p.dispose();
    }
    super.onClose();
  }
}
