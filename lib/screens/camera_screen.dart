import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> cameras;
  CameraController? controller;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    inicializarCamera();
  }

  Future<void> inicializarCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller!.initialize();
    setState(() {
      carregando = false;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> capturarFoto() async {
    if (!controller!.value.isInitialized) return;

    final foto = await controller!.takePicture();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Foto capturada: ${foto.path}')),
    );

    // Aqui futuramente você pode enviar a foto para reconhecimento de imagem
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Câmera - LensCanTalk'),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: controller!.value.aspectRatio,
            child: CameraPreview(controller!),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera),
            label: const Text('Capturar Foto'),
            onPressed: capturarFoto,
          ),
        ],
      ),
    );
  }
}
