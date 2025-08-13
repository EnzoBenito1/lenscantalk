import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class MLKitScreen extends StatefulWidget {
  const MLKitScreen({super.key});

  @override
  State<MLKitScreen> createState() => _MLKitScreenState();
}

class _MLKitScreenState extends State<MLKitScreen> {
  late CameraController cameraController;
  late FlutterTts tts;
  bool isCameraInitialized = false;

  final List<String> objetosConhecidos = [
    'Person (Pessoa)',
    'Dog (Cachorro)',
    'Cat (Gato)',
    'Chair (Cadeira)',
    'Ball (Bola)',
    'Car (Carro)',
  ];

  @override
  void initState() {
    super.initState();
    initCamera();
    tts = FlutterTts();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    cameraController = CameraController(backCamera, ResolutionPreset.medium);
    await cameraController.initialize();
    setState(() {
      isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    tts.stop();
    super.dispose();
  }

  Future<void> processImage() async {
    final picture = await cameraController.takePicture();
    final InputImage inputImage = InputImage.fromFile(File(picture.path));

    final options = ObjectDetectorOptions(
      mode: DetectionMode.single,
      classifyObjects: true,
      multipleObjects: true,
    );
    final objectDetector = ObjectDetector(options: options);

    final detectedObjects = await objectDetector.processImage(inputImage);

    if (detectedObjects.isEmpty) {
      if (!mounted) return;

      await tts.speak("Hmm, eu não consegui ver nada desta vez. Tente chegar mais perto ou mudar de ângulo!");

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Nada reconhecido 🤔'),
          content: const Text(
            'Eu não consegui reconhecer nenhum objeto desta vez.\n\nTente apontar para outros objetos:\n- Uma pessoa\n- Um cachorro\n- Uma cadeira\n- Uma bola\n- Um carro\n\nDica: fique em um lugar bem iluminado e mantenha o objeto no centro da tela!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );

      return;
    }


    List<String> labels = [];
    for (var obj in detectedObjects) {
      for (var label in obj.labels) {
        labels.add(label.text);
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detectado: ${labels.join(", ")}')),
    );

    await translateAndSpeak(labels);
  }

  Future<void> translateAndSpeak(List<String> texts) async {
    final translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.portuguese,
    );

    List<String> results = [];
    for (var text in texts) {
      final translatedText = await translator.translateText(text);
      results.add('$text: $translatedText');
    }

    if (!mounted) return;

    final translatedOnly =
        results.map((e) => e.split(': ').last).join(", ");
    await tts.speak("Eu vejo: $translatedOnly");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Objetos Detectados'),
        content: Text(results.join('\n')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Kit - LensCanTalk'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: cameraController.value.aspectRatio,
            child: CameraPreview(cameraController),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  'Eu sei reconhecer:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: objetosConhecidos
                      .map((obj) => Chip(label: Text(obj)))
                      .toList(),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Detectar e Traduzir'),
            onPressed: processImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
            ),
          )
        ],
      ),
    );
  }
}
