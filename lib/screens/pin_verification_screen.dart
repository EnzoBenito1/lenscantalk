import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinVerificationScreen extends StatefulWidget {
  final String pinCorreto;
  final VoidCallback onSuccess;

  const PinVerificationScreen({
    super.key,
    required this.pinCorreto,
    required this.onSuccess,
  });

  @override
  State<PinVerificationScreen> createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  final pinController = TextEditingController();
  int tentativasRestantes = 3;
  bool bloqueado = false;

  void _verificarPin() {
    if (pinController.text == widget.pinCorreto) {
      widget.onSuccess();
    } else {
      setState(() {
        tentativasRestantes--;
        if (tentativasRestantes <= 0) {
          bloqueado = true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bloqueado
                ? "Acesso bloqueado! Tente novamente mais tarde."
                : "PIN incorreto! $tentativasRestantes tentativas restantes",
          ),
          backgroundColor: Colors.red,
        ),
      );

      pinController.clear();

      if (bloqueado) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Verificação de Segurança"),
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: bloqueado ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    bloqueado ? "Bloqueado!" : "Digite o PIN",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: bloqueado ? Colors.red : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    bloqueado
                        ? "Muitas tentativas incorretas"
                        : "Insira o PIN de 4 dígitos",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: pinController,
                    enabled: !bloqueado,
                    decoration: InputDecoration(
                      labelText: "PIN",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.pin),
                      filled: true,
                      fillColor: bloqueado ? Colors.grey.shade200 : Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    maxLength: 4,
                    style: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onSubmitted: (_) => _verificarPin(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: bloqueado ? null : _verificarPin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Confirmar",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  if (!bloqueado && tentativasRestantes < 3) ...[
                    const SizedBox(height: 16),
                    Text(
                      "⚠️ $tentativasRestantes tentativas restantes",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }
}