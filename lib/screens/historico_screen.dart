import 'package:flutter/material.dart';
import 'package:lens_can_talk/palavra.dart';
import 'package:lens_can_talk/palavra_service.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final service = PalavraService();
  List<Palavra> palavras = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarPalavras();
  }

  Future<void> carregarPalavras() async {
    final lista = await service.buscarPalavras();
    setState(() {
      palavras = lista;
      carregando = false;
    });
  }

  Future<void> deletar(String id) async {
    await service.deletarPalavra(id);
    carregarPalavras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Traduções'),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : palavras.isEmpty
              ? const Center(child: Text('Nenhuma palavra traduzida ainda.'))
              : ListView.builder(
                  itemCount: palavras.length,
                  itemBuilder: (context, index) {
                    final p = palavras[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
    );
  }
}
