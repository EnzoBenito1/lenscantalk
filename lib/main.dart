import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/historico_screen.dart';
import 'screens/cadastro_palavra_screen.dart';
import 'screens/mlkit_screen.dart';
import 'screens/configuracoes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LensCanTalk',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Comic Sans MS',
        scaffoldBackgroundColor: const Color(0xFFF0F8FF),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// Tela de boas-vindas com fundo azul
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    
    // Animação do logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.bounceOut),
    );
    _logoRotation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Animação do texto
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    
    _startAnimations();
  }

  void _startAnimations() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3C72), // Azul escuro
              Color(0xFF2A5298), // Azul médio
              Color(0xFF4A90E2), // Azul claro
              Color(0xFF87CEEB), // Azul céu
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Transform.rotate(
                        angle: _logoRotation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF87CEEB), Color(0xFF1E3C72)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.visibility,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Título principal animado
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: const Text(
                      'LensCanTalk',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black26,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const SizedBox(height: 40),

                // Descrição animada
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: const Text(
                      'Bem vindo a tela inicial, toque em "começar" para aprender! ✏️📚🌍⚙️',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Botão "Começar" animado
                ScaleTransition(
                  scale: _buttonScale,
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const MenuScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 800),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E3C72),
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Começar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3C72).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Indicadores de funcionalidades
                FadeTransition(
                  opacity: _textFade,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeatureIcon('✏️', 'Cadastrar'),
                      _buildFeatureIcon('📚', 'Histórico'),
                      _buildFeatureIcon('🌍', 'Traduzir'),
                      _buildFeatureIcon('⚙️', 'Config'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(String emoji, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
              Color(0xFF4A90E2),
              Color(0xFF87CEEB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF87CEEB), Color(0xFF1E3C72)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'LensCanTalk',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5,
                                    color: Colors.black26,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.chat_bubble,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Vamos aprender juntos!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 252, 251, 251),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Botões do menu
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedButton(
                        context: context,
                        icon: Icons.edit,
                        emoji: '✏️',
                        label: 'Cadastro de Palavras',
                        description: 'Adicione novas palavras!',
                        colors: [const Color(0xFFFF9A9E), const Color(0xFFFECACA)],
                        delay: 200,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CadastroPalavraScreen()),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildAnimatedButton(
                        context: context,
                        icon: Icons.history,
                        emoji: '📚',
                        label: 'Ver Histórico',
                        description: 'Veja o que já aprendeu!',
                        colors: [const Color(0xFFA8EDEA), const Color(0xFFFED6E3)],
                        delay: 400,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HistoricoScreen()),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildAnimatedButton(
                        context: context,
                        icon: Icons.language,
                        emoji: '🌍',
                        label: 'Câmera Tradução',
                        description: 'Traduza com inteligência!',
                        colors: [const Color(0xFFFFD89B), const Color(0xFF19547B)],
                        delay: 600,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MLKitScreen()),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildAnimatedButton(
                        context: context,
                        icon: Icons.settings,
                        emoji: '⚙️',
                        label: 'Configurações',
                        description: 'Personalize seu app!',
                        colors: [const Color.fromARGB(62, 90, 92, 88), const Color.fromARGB(255, 90, 130, 175)],
                        delay: 800,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ConfiguracoesScreen()),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildAnimatedButton(
                        context: context,
                        icon: Icons.warning,
                        emoji: '⚠️',
                        label: 'Recursos em Desenvolvimento',
                        description: 'Função em desenvolvimento!',
                        colors: [const Color.fromARGB(255, 247, 164, 10), const Color(0xFFFEF9D7)],
                        delay: 800,
                        onPressed: () {
                          _showFunSnackBar(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Footer divertido
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBouncingEmoji('', 0),
                    const SizedBox(width: 10),
                    const Text(
                      'Divirta-se aprendendo!',
                      style: TextStyle(
                        color: Color.fromARGB(255, 248, 247, 247),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildBouncingEmoji('', 500),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required BuildContext context,
    required IconData icon,
    required String emoji,
    required String label,
    required String description,
    required List<Color> colors,
    required int delay,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        // Garantir que os valores estejam dentro dos limites válidos
        final clampedValue = value.clamp(0.0, 1.0);
        final scaleValue = (clampedValue * 0.8 + 0.2).clamp(0.2, 1.0);
        
        return Transform.scale(
          scale: scaleValue,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - clampedValue)),
            child: Opacity(
              opacity: clampedValue,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            shadowColor: colors[0].withOpacity(0.4),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 2),
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 3,
                                color: Colors.black26,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBouncingEmoji(String emoji, int delay) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 2000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        // Animação de bounce suave
        final bounceValue = (1 - (1 - value) * (1 - value)) * 10;
        return Transform.translate(
          offset: Offset(0, -bounceValue.clamp(0.0, 10.0)),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
        );
      },
    );
  }

  void _showFunSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Text('🚧'),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Funcionalidade em desenvolvimento! Em breve teremos mais diversão! 🎈',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Text('🎨'),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF4ECDC4),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}