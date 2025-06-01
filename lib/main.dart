import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'palavra_service.dart';
import 'palavra.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        title: const Text('LensCanTalk - Histórico'),
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
                  return ListTile(
                    title: Text('${p.nome} → ${p.traducao}'),
                    subtitle:
                        Text('Data: ${p.data.day}/${p.data.month}/${p.data.year}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deletar(p.id),
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
