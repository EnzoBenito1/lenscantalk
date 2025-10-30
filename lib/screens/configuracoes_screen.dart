import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
              // Se não tem PIN, sai direto
              if (pinSalvo == null) {
                setState(() => isChildMode = false);
                await _salvarModo(false);
                if (context.mounted) Navigator.pop(context);
                return;
              }
              
              // Se tem PIN, valida
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

  Widget _buildModoFilho() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Modo Filho Ativado',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _alternarModo,
          child: const Text('Sair do modo filho'),
        ),
      ],
    );
  }

  Widget _buildModoPai() {
    return ListView(
      children: [
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isChildMode ? _buildModoFilho() : _buildModoPai(),
      ),
    );
  }
}