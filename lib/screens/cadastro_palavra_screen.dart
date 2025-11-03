import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../palavra.dart';
import '../palavra_service.dart';
import '../helpers/theme_manager.dart';

class CadastroPalavraScreen extends StatefulWidget {
  const CadastroPalavraScreen({super.key});

  @override
  State<CadastroPalavraScreen> createState() => _CadastroPalavraScreenState();
}

class _CadastroPalavraScreenState extends State<CadastroPalavraScreen>
    with TickerProviderStateMixin {
  final service = PalavraService();
  List<Palavra> palavras = [];

  final nomeController = TextEditingController();
  final traducaoController = TextEditingController();

  late AnimationController _headerAnimationController;
  late AnimationController _formAnimationController;
  late AnimationController _listAnimationController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _formAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.bounceOut),
    );
    _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formAnimationController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _listAnimationController, curve: Curves.easeOutBack),
    );

    _startAnimations();
    carregarPalavras();
  }

  void _startAnimations() async {
    _headerAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _formAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _formAnimationController.dispose();
    _listAnimationController.dispose();
    nomeController.dispose();
    traducaoController.dispose();
    super.dispose();
  }

  Future<void> carregarPalavras() async {
    final lista = await service.buscarPalavras();
    setState(() {
      palavras = lista;
    });
  }

  Future<void> adicionarPalavra() async {
    if (nomeController.text.isEmpty || traducaoController.text.isEmpty) {
      _showFunSnackBar('🤔 Oops! Preencha todos os campos para continuar! ✨', Colors.orange);
      return;
    }

    final nova = Palavra(
      id: '',
      nome: nomeController.text,
      traducao: traducaoController.text,
      data: DateTime.now(),
    );

    await service.salvarPalavra(nova);
    nomeController.clear();
    traducaoController.clear();
    carregarPalavras();
    
    _showFunSnackBar('🎉 Palavra adicionada com sucesso! Parabéns!', Colors.green);
  }

  Future<void> deletar(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => _buildFunDialog(),
    );
    
    if (confirmar == true) {
      await service.deletarPalavra(id);
      carregarPalavras();
      _showFunSnackBar('🗑️ Palavra removida! Vamos aprender outras! 💫', Colors.purple);
    }
  }

  Widget _buildFunDialog() {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              themeManager.currentTheme.gradientColors[0].withOpacity(0.3),
              themeManager.currentTheme.gradientColors[3].withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🤗',
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tem certeza?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você realmente quer remover esta palavra?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('❌ Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('🗑️ Remover'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFunSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final gradientColors = themeManager.currentTheme.gradientColors;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header animado
              ScaleTransition(
                scale: _headerAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: gradientColors[2]),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [gradientColors[1], gradientColors[2]],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('✏️', style: TextStyle(fontSize: 24)),
                                  SizedBox(width: 10),
                                  Text(
                                    'Cadastro de Palavras',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text('📚', style: TextStyle(fontSize: 24)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Adicione novas palavras e expanda seu vocabulário!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Formulário animado
              ScaleTransition(
                scale: _formAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('🇧🇷', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: nomeController,
                              decoration: InputDecoration(
                                labelText: 'Palavra em Português',
                                labelStyle: TextStyle(color: gradientColors[2]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: gradientColors[2]),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: gradientColors[2], width: 2),
                                ),
                                filled: true,
                                fillColor: gradientColors[3].withOpacity(0.1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: traducaoController,
                              decoration: InputDecoration(
                                labelText: 'Tradução em Inglês',
                                labelStyle: TextStyle(color: gradientColors[2]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: gradientColors[2]),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: gradientColors[2], width: 2),
                                ),
                                filled: true,
                                fillColor: gradientColors[3].withOpacity(0.1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: adicionarPalavra,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [gradientColors[1], gradientColors[2]],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                '💾 Salvar Palavra',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Lista de palavras animada
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text('📖', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Text(
                      'Suas Palavras (${palavras.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Text('uwu', style: TextStyle(fontSize: 24, color: Colors.white)),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: palavras.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🤗', style: TextStyle(fontSize: 60)),
                                const SizedBox(height: 20),
                                const Text(
                                  'Nenhuma palavra ainda!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Adicione sua primeira palavra acima!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: palavras.length,
                            itemBuilder: (context, index) {
                              final p = palavras[index];
                              return TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 300 + (index * 100)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOutBack,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value.clamp(0.1, 1.0),
                                    child: Opacity(
                                      opacity: value.clamp(0.0, 1.0),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        gradientColors[3].withOpacity(0.2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: gradientColors[2].withOpacity(0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [gradientColors[1], gradientColors[2]],
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: Text(
                                          p.imagem ?? '💬',
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      '${p.nome} → ${p.traducao}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    subtitle: Text(
                                      '📅 ${p.data.day}/${p.data.month}/${p.data.year}',
                                      style: const TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () => deletar(p.id),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}