import 'package:cloud_firestore/cloud_firestore.dart';
import 'palavra.dart';

class PalavraService {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('palavras');

  Future<void> salvarPalavra(Palavra palavra) async {
    await collection.add(palavra.toMap());
  }

  Future<List<Palavra>> buscarPalavras() async {
    final snapshot = await collection.orderBy('data', descending: true).get();
    return snapshot.docs
        .map((doc) => Palavra.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deletarPalavra(String id) async {
    await collection.doc(id).delete();
  }
}
