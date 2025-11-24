import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../helpers/theme_manager.dart';
import '../palavra.dart';
import '../palavra_service.dart';

enum GameMode { learning, quiz }

class MLKitScreen extends StatefulWidget {
  const MLKitScreen({super.key});

  @override
  State<MLKitScreen> createState() => _MLKitScreenState();
}

class _MLKitScreenState extends State<MLKitScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final FlutterTts flutterTts = FlutterTts();
  final PalavraService _palavraService = PalavraService();
  
  File? _image;
  List<DetectedObject> _detectedObjects = [];
  bool _isProcessing = false;
  bool _isSaving = false;
  String _currentLanguage = 'pt-BR';
  late AnimationController _animationController;
  late AnimationController _gameAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  GameMode _currentMode = GameMode.learning;
  int _score = 0;
  int _streak = 0;
  bool _showingQuizOptions = false;
  List<ObjectTranslation> _quizOptions = [];
  ObjectTranslation? _correctAnswer;
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.green;

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
    _gameAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _gameAnimationController, curve: Curves.bounceOut),
    );
  }

  Future<void> _setupTTS() async {
    await flutterTts.setLanguage(_currentLanguage);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  void _toggleGameMode() {
    setState(() {
      _currentMode = _currentMode == GameMode.learning ? GameMode.quiz : GameMode.learning;
      _showingQuizOptions = false;
      _feedbackMessage = '';
      if (_currentMode == GameMode.quiz) {
        _score = 0;
        _streak = 0;
      }
    });
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
          _showingQuizOptions = false;
          _feedbackMessage = '';
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
        
        if (_currentMode == GameMode.learning) {
          await _speak(detectedObjects.first.translation.english);
        } else if (_currentMode == GameMode.quiz) {
          _setupQuiz(detectedObjects.first.translation);
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Erro ao processar imagem: $e');
    }
  }

  Future<void> _salvarNoHistorico() async {
    if (_detectedObjects.isEmpty || _isSaving) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      final translation = _detectedObjects.first.translation;
      final palavra = Palavra(
        id: '',
        nome: translation.english,
        traducao: translation.portuguese,
        data: DateTime.now(),
        imagem: translation.emoji,
      );
      
      await _palavraService.salvarPalavra(palavra);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(translation.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('✓ "${translation.english}" salvo no histórico!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _setupQuiz(ObjectTranslation correctAnswer) {
    final random = Random();
    final allObjects = _objectMap.values.toList();
    allObjects.shuffle(random);
    
    List<ObjectTranslation> options = [correctAnswer];
    
    for (var obj in allObjects) {
      if (obj != correctAnswer && options.length < 4) {
        options.add(obj);
      }
    }
    
    options.shuffle(random);
    
    setState(() {
      _correctAnswer = correctAnswer;
      _quizOptions = options;
      _showingQuizOptions = true;
      _feedbackMessage = '';
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _speakInLanguage("What is this in English?", "en-US");
    });
  }

  void _handleQuizAnswer(ObjectTranslation selectedAnswer) {
    final isCorrect = selectedAnswer == _correctAnswer;
    
    setState(() {
      _showingQuizOptions = false;
      if (isCorrect) {
        _score += 10 + (_streak * 2);
        _streak++;
        _feedbackMessage = '🎉 Correto! +${10 + ((_streak - 1) * 2)} pontos';
        _feedbackColor = Colors.green;
      } else {
        _streak = 0;
        _feedbackMessage = '❌ Ops! Era "${_correctAnswer!.english}"';
        _feedbackColor = Colors.red;
      }
    });
    
    _gameAnimationController.forward().then((_) {
      _gameAnimationController.reset();
    });
    
    if (isCorrect) {
      _speakInLanguage("Correct!", "en-US");
    } else {
      _speakInLanguage(_correctAnswer!.english, "en-US");
    }
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _feedbackMessage = '';
        });
      }
    });
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

  Future<void> _speakInLanguage(String text, String language) async {
    try {
      await flutterTts.setLanguage(language);
      await flutterTts.speak(text);
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
    _gameAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final gradientColors = _currentMode == GameMode.learning 
        ? themeManager.currentTheme.gradientColors
        : [const Color.fromARGB(228, 104, 58, 183), Colors.deepPurpleAccent];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentMode == GameMode.learning 
              ? "LensCanTalk - Aprenda se Divertindo" 
              : "LensCanTalk - Modo Game",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
            ),
          ),
        ),
        actions: [
          if (_currentMode == GameMode.quiz) 
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'Score: $_score',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    onPressed: _toggleGameMode,
                    icon: Icon(_currentMode == GameMode.learning ? Icons.games : Icons.school),
                    label: Text(_currentMode == GameMode.learning ? 'Modo Game' : 'Modo Aprendizado'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _currentMode == GameMode.learning 
                          ? themeManager.currentTheme.gradientColors[2]
                          : Colors.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),

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
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _currentMode == GameMode.learning ? Icons.camera_alt : Icons.quiz,
                                    size: 64, 
                                    color: Colors.grey
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _currentMode == GameMode.learning
                                        ? "Capture uma imagem para começar!"
                                        : "Capture e teste seus conhecimentos!",
                                    style: const TextStyle(
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
                        : _showingQuizOptions
                            ? _buildQuizWidget()
                            : _detectedObjects.isNotEmpty
                                ? _buildResultsWidget()
                                : Center(
                                    child: Text(
                                      _currentMode == GameMode.learning
                                          ? "Aponte para objetos, brinquedos, frutas ou animais!"
                                          : "Aponte para um objeto e responda o quiz!",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
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
                          foregroundColor: _currentMode == GameMode.learning 
                              ? themeManager.currentTheme.gradientColors[2]
                              : Colors.purple,
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

  Widget _buildQuizWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_feedbackMessage.isNotEmpty)
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: _feedbackColor.withOpacity(0.1),
                    border: Border.all(color: _feedbackColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _feedbackMessage,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _feedbackColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

        if (_feedbackMessage.isEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _correctAnswer?.emoji ?? '',
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "What is this in English?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _quizOptions.map((option) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () => _handleQuizAnswer(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      option.english,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),

          if (_streak > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '🔥 Sequência: $_streak',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildResultsWidget() {
    final primaryObject = _detectedObjects.first;
    
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (_feedbackMessage.isNotEmpty)
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _feedbackColor.withOpacity(0.1),
                      border: Border.all(color: _feedbackColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _feedbackMessage,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _feedbackColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                primaryObject.translation.emoji,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      primaryObject.translation.english.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      primaryObject.translation.portuguese.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (_currentMode == GameMode.learning) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _speak(primaryObject.translation.english),
                    icon: const Icon(Icons.volume_up, size: 18),
                    label: const Text("English", style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _speakPortuguese(primaryObject.translation.portuguese),
                    icon: const Icon(Icons.volume_up, size: 18),
                    label: const Text("Português", style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Botão "Entendi" para salvar no histórico
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _salvarNoHistorico,
                icon: _isSaving 
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_circle, size: 20),
                label: Text(
                  _isSaving ? "Salvando..." : "Entendi",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
          
          if (_detectedObjects.length > 1) ...[
            const SizedBox(height: 12),
            const Divider(),
            const Text(
              "Outros objetos:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _detectedObjects.skip(1).take(2).map((obj) => 
                Chip(
                  avatar: Text(obj.translation.emoji, style: const TextStyle(fontSize: 16)),
                  label: Text(
                    "${obj.translation.english} • ${obj.translation.portuguese}",
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.grey.shade200,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ).toList(),
            ),
          ],
        ],
      ),
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