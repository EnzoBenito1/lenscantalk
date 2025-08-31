import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MLKitScreen extends StatefulWidget {
  @override
  _MLKitScreenState createState() => _MLKitScreenState();
}

class _MLKitScreenState extends State<MLKitScreen> {
  final ImagePicker _picker = ImagePicker();
  String _resultText = "Toque no botão e tire uma foto para começar!";
  File? _imageFile;
  late ImageLabeler _imageLabeler;
  late OnDeviceTranslator _translator;
  final FlutterTts _flutterTts = FlutterTts();

  final Map<String, String> objectMap = {
    "glasses": "Óculos",
    "chair": "Cadeira",
    "ball": "Bola",
    "shirt": "Camiseta",
    "t-shirt": "Camiseta",
    "table": "Mesa",
    "phone": "Celular",
    "cellphone": "Celular",
    "sofa": "Sofá",
    "car": "Carro",
    "dog": "Cachorro",
    "cat": "Gato"
  };

  @override
  void initState() {
    super.initState();
    _imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.6));
    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.portuguese,
    );
  }

  @override
  void dispose() {
    _imageLabeler.close();
    _translator.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _resultText = "Analisando imagem...";
      });
      await _processImage(File(pickedFile.path));
    }
  }

  Future<void> _processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final labels = await _imageLabeler.processImage(inputImage);

    if (labels.isEmpty) {
      setState(() {
        _resultText = "Não consegui identificar nada! Tente mostrar outro objeto.";
      });
      await _flutterTts.speak("Não consegui identificar nada! Tente mostrar outro objeto.");
      return;
    }

    String detected = labels.first.label.toLowerCase();

    // Normaliza para objetos comuns
    objectMap.forEach((key, value) {
      if (detected.contains(key)) {
        detected = key;
      }
    });

    String translatedText;
    if (objectMap.containsKey(detected)) {
      translatedText = objectMap[detected]!;
    } else {
      translatedText = await _translator.translateText(detected);
    }

    setState(() {
      _resultText = "Detectado: ${detected.toUpperCase()} → $translatedText";
    });

    await _flutterTts.speak(translatedText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text("LensCanTalk"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile != null
                ? Image.file(_imageFile!, height: 200)
                : Icon(Icons.photo_camera, size: 120, color: Colors.blueAccent),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _resultText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.camera_alt),
              label: Text("Tirar Foto"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
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
