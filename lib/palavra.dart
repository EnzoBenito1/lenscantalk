import 'package:cloud_firestore/cloud_firestore.dart';

class Palavra {
  final String id;
  final String nome;
  final String traducao;
  final DateTime data;
  final String? imagem;

  Palavra({
    required this.id,
    required this.nome,
    required this.traducao,
    required this.data,
    this.imagem,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'traducao': traducao,
      'data': data,
      'imagem': imagem ?? '',
    };
  }

  factory Palavra.fromMap(String id, Map<String, dynamic> map) {
    return Palavra(
      id: id,
      nome: map['nome'] ?? '',
      traducao: map['traducao'] ?? '',
      data: (map['data'] as Timestamp).toDate(),
      imagem: map['imagem'],
    );
  }
}
