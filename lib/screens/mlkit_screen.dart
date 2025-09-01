import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MLKitScreen extends StatefulWidget {
  const MLKitScreen({super.key});

  @override
  State<MLKitScreen> createState() => _MLKitScreenState();
}

class _MLKitScreenState extends State<MLKitScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final FlutterTts flutterTts = FlutterTts();
  
  File? _image;
  List<DetectedObject> _detectedObjects = [];
  bool _isProcessing = false;
  String _currentLanguage = 'pt-BR';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.5),
  );

  final Map<String, ObjectTranslation> _objectMap = {
    "glasses": ObjectTranslation("glasses", "óculos", "👓"),
    "sunglasses": ObjectTranslation("sunglasses", "óculos de sol", "🕶️"),
    "hat": ObjectTranslation("hat", "chapéu", "👒"),
    "cap": ObjectTranslation("cap", "boné", "🧢"),
    "shirt": ObjectTranslation("shirt", "camisa", "👔"),
    "t-shirt": ObjectTranslation("t-shirt", "camiseta", "👕"),
    "dress": ObjectTranslation("dress", "vestido", "👗"),
    "pants": ObjectTranslation("pants", "calça", "👖"),
    "jeans": ObjectTranslation("jeans", "jeans", "👖"),
    "shoe": ObjectTranslation("shoe", "sapato", "👞"),
    "sneaker": ObjectTranslation("sneaker", "tênis", "👟"),
    "boot": ObjectTranslation("boot", "bota", "👢"),
    
    "chair": ObjectTranslation("chair", "cadeira", "🪑"),
    "table": ObjectTranslation("table", "mesa", "🪑"),
    "bed": ObjectTranslation("bed", "cama", "🛏️"),
    "sofa": ObjectTranslation("sofa", "sofá", "🛋️"),
    "door": ObjectTranslation("door", "porta", "🚪"),
    "window": ObjectTranslation("window", "janela", "🪟"),
    "lamp": ObjectTranslation("lamp", "lâmpada", "💡"),
    "mirror": ObjectTranslation("mirror", "espelho", "🪞"),
    "clock": ObjectTranslation("clock", "relógio", "🕐"),
    
    "phone": ObjectTranslation("phone", "telefone", "📱"),
    "computer": ObjectTranslation("computer", "computador", "💻"),
    "laptop": ObjectTranslation("laptop", "notebook", "💻"),
    "television": ObjectTranslation("television", "televisão", "📺"),
    "tv": ObjectTranslation("tv", "TV", "📺"),
    "camera": ObjectTranslation("camera", "câmera", "📷"),
    
    "book": ObjectTranslation("book", "livro", "📚"),
    "pen": ObjectTranslation("pen", "caneta", "🖊️"),
    "pencil": ObjectTranslation("pencil", "lápis", "✏️"),
    "notebook": ObjectTranslation("notebook", "caderno", "📓"),
    "bag": ObjectTranslation("bag", "mochila", "🎒"),
    "backpack": ObjectTranslation("backpack", "mochila", "🎒"),
    
    "apple": ObjectTranslation("apple", "maçã", "🍎"),
    "banana": ObjectTranslation("banana", "banana", "🍌"),
    "orange": ObjectTranslation("orange", "laranja", "🍊"),
    "grape": ObjectTranslation("grape", "uva", "🍇"),
    "grapes": ObjectTranslation("grapes", "uvas", "🍇"),
    "pineapple": ObjectTranslation("pineapple", "abacaxi", "🍍"),
    "watermelon": ObjectTranslation("watermelon", "melancia", "🍉"),
    "strawberry": ObjectTranslation("strawberry", "morango", "🍓"),
    "lemon": ObjectTranslation("lemon", "limão", "🍋"),
    "peach": ObjectTranslation("peach", "pêssego", "🍑"),
    
    "toy": ObjectTranslation("toy", "brinquedo", "🧸"),
    "ball": ObjectTranslation("ball", "bola", "⚽"),
    "doll": ObjectTranslation("doll", "boneca", "🪆"),
    "teddy bear": ObjectTranslation("teddy bear", "urso de pelúcia", "🧸"),
    "balloon": ObjectTranslation("balloon", "balão", "🎈"),
    "puzzle": ObjectTranslation("puzzle", "quebra-cabeça", "🧩"),
    
    "dog": ObjectTranslation("dog", "cachorro", "🐕"),
    "cat": ObjectTranslation("cat", "gato", "🐱"),
    "bird": ObjectTranslation("bird", "pássaro", "🐦"),
    "fish": ObjectTranslation("fish", "peixe", "🐟"),
    "horse": ObjectTranslation("horse", "cavalo", "🐴"),
    "cow": ObjectTranslation("cow", "vaca", "🐄"),
    "pig": ObjectTranslation("pig", "porco", "🐷"),
    
    "red": ObjectTranslation("red", "vermelho", "🔴"),
    "blue": ObjectTranslation("blue", "azul", "🔵"),
    "green": ObjectTranslation("green", "verde", "🟢"),
    "yellow": ObjectTranslation("yellow", "amarelo", "🟡"),
    "black": ObjectTranslation("black", "preto", "⚫"),
    "white": ObjectTranslation("white", "branco", "⚪"),
    "pink": ObjectTranslation("pink", "rosa", "🩷"),
    "purple": ObjectTranslation("purple", "roxo", "🟣"),
    "orange color": ObjectTranslation("orange", "cor laranja", "🟠"),
    
    "bottle": ObjectTranslation("bottle", "garrafa", "🍼"),
    "cup": ObjectTranslation("cup", "xícara", "☕"),
    "glass": ObjectTranslation("glass", "copo", "🥛"),
    "plate": ObjectTranslation("plate", "prato", "🍽️"),
    "spoon": ObjectTranslation("spoon", "colher", "🥄"),
    "fork": ObjectTranslation("fork", "garfo", "🍴"),
    "knife": ObjectTranslation("knife", "faca", "🔪"),
  };

  @override
  void initState() {
    super.initState();
    _setupTTS();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  Future<void> _setupTTS() async {
    await flutterTts.setLanguage(_currentLanguage);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _getImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isProcessing = true;
          _detectedObjects.clear();
        });
        await _processImage();
      }
    } catch (e) {
      _showErrorDialog('Erro ao capturar imagem: $e');
    }
  }

  Future<void> _processImage() async {
    if (_image == null) return;

    try {
      final inputImage = InputImage.fromFile(_image!);
      final labels = await _imageLabeler.processImage(inputImage);

      List<DetectedObject> detectedObjects = [];

      for (var label in labels) {
        final matchedObject = _findBestMatch(label.label.toLowerCase());
        if (matchedObject != null) {
          detectedObjects.add(DetectedObject(
            translation: matchedObject,
            confidence: label.confidence,
          ));
        }
      }

      setState(() {
        _detectedObjects = detectedObjects;
        _isProcessing = false;
      });

      if (detectedObjects.isNotEmpty) {
        _animationController.forward();
        await _speak(detectedObjects.first.translation.english);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Erro ao processar imagem: $e');
    }
  }

  ObjectTranslation? _findBestMatch(String detected) {
    if (_objectMap.containsKey(detected)) {
      return _objectMap[detected];
    }

    for (var entry in _objectMap.entries) {
      if (detected.contains(entry.key) || entry.key.contains(detected)) {
        return entry.value;
      }
    }

    for (var entry in _objectMap.entries) {
      if (_calculateSimilarity(detected, entry.key) > 0.7) {
        return entry.value;
      }
    }

    return null;
  }

  double _calculateSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    
    int maxLength = [a.length, b.length].reduce((a, b) => a > b ? a : b);
    int distance = _levenshteinDistance(a, b);
    
    return (maxLength - distance) / maxLength;
  }

  int _levenshteinDistance(String a, String b) {
    List<List<int>> matrix = List.generate(
      a.length + 1, 
      (i) => List.generate(b.length + 1, (j) => 0),
    );

    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        int cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }

  Future<void> _speak(String text) async {
    try {
      await flutterTts.speak(text);
    } catch (e) {
      _showErrorDialog('Erro no áudio: $e');
    }
  }

  Future<void> _speakPortuguese(String text) async {
    try {
      await flutterTts.setLanguage("pt-BR");
      await flutterTts.speak(text);
      await flutterTts.setLanguage("en-US");
    } catch (e) {
      _showErrorDialog('Erro no áudio: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _imageLabeler.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LensCanTalk - Aprenda Brincando"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.lightBlue],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _image != null
                          ? Image.file(_image!, fit: BoxFit.cover)
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    "Capture uma imagem para começar!",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _isProcessing
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text("Processando imagem..."),
                              ],
                            ),
                          )
                        : _detectedObjects.isNotEmpty
                            ? _buildResultsWidget()
                            : const Center(
                                child: Text(
                                  "Aponte para objetos, brinquedos, frutas ou animais!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        onPressed: _isProcessing ? null : _getImage,
                        icon: const Icon(Icons.camera_alt, size: 28),
                        label: const Text(
                          "Abrir Câmera",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsWidget() {
    final primaryObject = _detectedObjects.first;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              primaryObject.translation.emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primaryObject.translation.english.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    primaryObject.translation.portuguese.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  // Text(
                  //   "Confiança: ${(primaryObject.confidence * 100).toStringAsFixed(1)}%",
                  //   style: const TextStyle(
                  //     fontSize: 12,
                  //     color: Colors.grey,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _speak(primaryObject.translation.english),
              icon: const Icon(Icons.volume_up),
              label: const Text("English"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _speakPortuguese(primaryObject.translation.portuguese),
              icon: const Icon(Icons.volume_up),
              label: const Text("Português"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        
        if (_detectedObjects.length > 1) ...[
          const SizedBox(height: 16),
          const Divider(),
          const Text(
            "Outros objetos:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _detectedObjects.skip(1).take(3).map((obj) => 
              Chip(
                avatar: Text(obj.translation.emoji),
                label: Text("${obj.translation.english} • ${obj.translation.portuguese}"),
                backgroundColor: Colors.grey.shade200,
              ),
            ).toList(),
          ),
        ],
      ],
    );
  }
}

class ObjectTranslation {
  final String english;
  final String portuguese;
  final String emoji;

  ObjectTranslation(this.english, this.portuguese, this.emoji);
}

class DetectedObject {
  final ObjectTranslation translation;
  final double confidence;

  DetectedObject({required this.translation, required this.confidence});
}