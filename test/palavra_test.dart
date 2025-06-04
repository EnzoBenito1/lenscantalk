import 'package:flutter_test/flutter_test.dart';
import 'package:lens_can_talk/palavra.dart';

void main() {
  group('Palavra Model Test', () {
    test('Conversão toMap funciona corretamente', () {
      final palavra = Palavra(
        id: '1',
        nome: 'Cachorro',
        traducao: 'Dog',
        data: DateTime(2025, 06, 01),
      );

      final map = palavra.toMap();

      expect(map['nome'], 'Cachorro');
      expect(map['traducao'], 'Dog');
      expect(map['data'], isNotNull);
      expect(map['imagem'], '');
    });

    test('Conversão fromMap funciona corretamente', () {
      final map = {
        'nome': 'Gato',
        'traducao': 'Cat',
        'data': DateTime(2025, 06, 01),
        'imagem': '',
      };

      final palavra = Palavra(
        id: 'abc123',
        nome: map['nome'] as String,
        traducao: map['traducao'] as String,
        data: map['data'] as DateTime,
        imagem: map['imagem'] as String,
      );

      expect(palavra.id, 'abc123');
      expect(palavra.nome, 'Gato');
      expect(palavra.traducao, 'Cat');
      expect(palavra.data, DateTime(2025, 06, 01));
      expect(palavra.imagem, '');
    });
  });
}
