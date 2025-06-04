import 'package:flutter/material.dart';
import '../palavra.dart';
import '../palavra_service.dart';

class CadastroPalavraScreen extends StatefulWidget {
  const CadastroPalavraScreen({super.key});

  @override
  State<CadastroPalavraScreen> createState() => _CadastroPalavraScreenState();
}

class _CadastroPalavraScreenState extends State<CadastroPalavraScreen> {
  final service = PalavraService();
  List<Palavra> palavras = [];

  final nomeController = TextEditingController();
  final traducaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarPalavras();
  }

  Future<void> carregarPalavras() async {
    final lista = await service.buscarPalavras();
    setState(() {
      palavras = lista;
    });
  }

  Future<void> adicionarPalavra() async {
    if (nomeController.text.isEmpty || traducaoController.text.isEmpty) return;

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
  }

  Future<void> deletar(String id) async {
    await service.deletarPalavra(id);
    carregarPalavras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Palavras'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome (PT)'),
            ),
            TextField(
              controller: traducaoController,
              decoration: const InputDecoration(labelText: 'Tradução (EN)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: adicionarPalavra,
              child: const Text('Salvar Palavra'),
            ),
            const SizedBox(height: 16),
            const Text('Histórico', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: palavras.length,
                itemBuilder: (context, index) {
                  final p = palavras[index];
                  return Card(
                    child: ListTile(
                      title: Text('${p.nome} → ${p.traducao}'),
                      subtitle: Text(
                          'Data: ${p.data.day}/${p.data.month}/${p.data.year}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deletar(p.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
