import 'package:flutter/material.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool somAtivado = true;
  bool temaInfantil = true;
  bool salvarHistorico = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Configurações"),
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: SwitchListTile(
              title: const Text(
                "Ativar sons",
                style: TextStyle(fontSize: 18),
              ),
              subtitle: const Text("Reproduzir sons ao traduzir"),
              value: somAtivado,
              onChanged: (value) {
                setState(() {
                  somAtivado = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: SwitchListTile(
              title: const Text(
                "Tema infantil",
                style: TextStyle(fontSize: 18),
              ),
              subtitle: const Text("Interface colorida para crianças"),
              value: temaInfantil,
              onChanged: (value) {
                setState(() {
                  temaInfantil = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: SwitchListTile(
              title: const Text(
                "Salvar histórico",
                style: TextStyle(fontSize: 18),
              ),
              subtitle: const Text("Guardar palavras traduzidas"),
              value: salvarHistorico,
              onChanged: (value) {
                setState(() {
                  salvarHistorico = value;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Configurações salvas com sucesso!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text(
              "Salvar",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
