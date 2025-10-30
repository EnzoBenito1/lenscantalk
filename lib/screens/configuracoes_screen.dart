import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../helpers/theme_manager.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool isChildMode = false;
  String? pinSalvo;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isChildMode = prefs.getBool('modoFilho') ?? false;
      pinSalvo = prefs.getString('pin');
    });
  }

  Future<void> _salvarModo(bool modoFilho) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modoFilho', modoFilho);
  }

  Future<void> _salvarPin(String? novoPin) async {
    final prefs = await SharedPreferences.getInstance();
    if (novoPin == null) {
      await prefs.remove('pin');
    } else {
      await prefs.setString('pin', novoPin);
    }
    setState(() {
      pinSalvo = novoPin;
    });
  }

  void _alternarModo() async {
    if (!isChildMode) {
      setState(() => isChildMode = true);
      await _salvarModo(true);
      return;
    }

    _mostrarDialogoPIN();
  }

  void _mostrarDialogoPIN() {
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do modo filho'),
        content: pinSalvo != null 
          ? TextField(
              controller: pinController,
              decoration: const InputDecoration(labelText: 'Digite o PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            )
          : const Text('Nenhum PIN configurado. Deseja sair do modo filho?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Confirmar'),
            onPressed: () async {
              if (pinSalvo == null) {
                setState(() => isChildMode = false);
                await _salvarModo(false);
                if (context.mounted) Navigator.pop(context);
                return;
              }
              
              if (pinController.text == pinSalvo) {
                setState(() => isChildMode = false);
                await _salvarModo(false);
                if (context.mounted) Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN incorreto!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoNovoPin({bool alterar = false}) {
    final TextEditingController novoPinController = TextEditingController();
    final TextEditingController confirmarPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alterar ? 'Alterar PIN' : 'Definir PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: novoPinController,
              decoration: const InputDecoration(labelText: 'Novo PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: confirmarPinController,
              decoration: const InputDecoration(labelText: 'Confirmar PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Salvar'),
            onPressed: () async {
              if (novoPinController.text == confirmarPinController.text &&
                  novoPinController.text.isNotEmpty) {
                await _salvarPin(novoPinController.text);
                if (context.mounted) Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PINs não coincidem!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _mostrarSeletorTema() {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolha um tema'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppThemeData.themes.length,
            itemBuilder: (context, index) {
              final theme = AppThemeData.themes[index];
              final isSelected = themeManager.currentTheme.name == theme.name;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: theme.gradientColors),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: ListTile(
                  leading: Icon(theme.icon, color: Colors.white),
                  title: Text(
                    theme.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.white)
                      : null,
                  onTap: () {
                    themeManager.setTheme(theme);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tema "${theme.displayName}" aplicado!'),
                        backgroundColor: theme.gradientColors[2],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildModoFilho() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Modo Filho Ativado',
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _alternarModo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
          child: const Text('Sair do modo filho'),
        ),
      ],
    );
  }

  Widget _buildModoPai() {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Tema'),
            subtitle: Text(themeManager.currentTheme.displayName),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themeManager.currentTheme.gradientColors,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 2),
              ),
            ),
            onTap: _mostrarSeletorTema,
          ),
          const Divider(),
          const ListTile(
            title: Text('Alterar senha'),
          ),
          const ListTile(
            title: Text('Preferências'),
          ),
          const ListTile(
            title: Text('Gerenciar contas'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.child_care),
            title: const Text('Ativar modo filho'),
            onTap: _alternarModo,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(pinSalvo == null ? 'Definir PIN' : 'Alterar PIN'),
            subtitle: const Text('PIN para sair do modo filho'),
            onTap: () => _mostrarDialogoNovoPin(alterar: pinSalvo != null),
          ),
          if (pinSalvo != null)
            ListTile(
              leading: const Icon(Icons.lock_open),
              title: const Text('Remover PIN'),
              onTap: () async {
                await _salvarPin(null);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN removido com sucesso.')),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeManager.currentTheme.gradientColors,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeManager.currentTheme.gradientColors,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isChildMode ? _buildModoFilho() : _buildModoPai(),
        ),
      ),
    );
  }
}