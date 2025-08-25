import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MLKitScreen extends StatefulWidget {
  @override
  _MLKitScreenState createState() => _MLKitScreenState();
}

class _MLKitScreenState extends State<MLKitScreen> {
  final ImagePicker _picker = ImagePicker();
  ImageLabeler? _imageLabeler;
  OnDeviceTranslator? _translator;
  FlutterTts flutterTts = FlutterTts();

  String _labelText = "Nenhuma imagem selecionada";
  String _translatedText = "";
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final options = ImageLabelerOptions(confidenceThreshold: 0.6);
    _imageLabeler = ImageLabeler(options: options);

    // Tradutor Inglês -> Português
    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.portuguese,
    );
  }

  @override
  void dispose() {
    _imageLabeler?.close();
    _translator?.close();
    super.dispose();
  }

  Future<void> _getImageAndDetect() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    setState(() {
      _imageFile = File(pickedFile.path);
      _labelText = "Detectando...";
      _translatedText = "";
    });

    final inputImage = InputImage.fromFile(_imageFile!);
    final labels = await _imageLabeler!.processImage(inputImage);

    if (labels.isEmpty) {
      setState(() {
        _labelText = "Nada reconhecido. Tente outro ângulo!";
        _translatedText = "";
      });
      return;
    }

    String detected = labels.first.label;

    // ✅ Ajuste para óculos
    if (detected.toLowerCase().contains("glass") ||
        detected.toLowerCase().contains("eyewear") ||
        detected.toLowerCase().contains("fashion")) {
      detected = "Glasses";
    }

    // Tradução
    final translated = await _translator!.translateText(detected);

    setState(() {
      _labelText = "Reconhecido: $detected";
      _translatedText = "Tradução: $translated";
    });

    // Falar o texto traduzido
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setSpeechRate(0.9);
    await flutterTts.speak("Isso é um $translated");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detector Educativo"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile != null
                ? Image.file(_imageFile!, height: 250)
                : Icon(Icons.camera_alt, size: 120, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              _labelText,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (_translatedText.isNotEmpty)
              Text(
                _translatedText,
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _getImageAndDetect,
              icon: Icon(Icons.camera),
              label: Text("Abrir Câmera"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
