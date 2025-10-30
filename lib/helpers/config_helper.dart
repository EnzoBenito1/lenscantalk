import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/configuracoes_screen.dart';

class ConfigHelper {
  static Future<void> abrirConfiguracoes(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool modoFilho = prefs.getBool('modoFilho') ?? false;
    String? pin = prefs.getString('pin');

    if (!context.mounted) return;

    // Só pede PIN se estiver no modo filho E tiver PIN configurado
    if (modoFilho && pin != null && pin.isNotEmpty) {
      // Mostrar diálogo de PIN
      _mostrarDialogoPIN(context, pin);
    } else {
      // Abrir direto (não está no modo filho ou não tem PIN)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ConfiguracoesScreen(),
        ),
      );
    }
  }

  static void _mostrarDialogoPIN(BuildContext context, String pinCorreto) {
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Modo Filho Ativo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite o PIN para acessar as configurações:'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Confirmar'),
            onPressed: () {
              if (pinController.text == pinCorreto) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConfiguracoesScreen(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN incorreto!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}