// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Produto {
  String id;
  String nome;
  double preco;
  int porcentagemDesconto;
  int estoque;
  double comprimento;
  double largura;
  double altura;
  String escalaDimensao;
  double peso;
  String escalaPeso;
  String categoria;
  String descricao;
  List<String> imagensUrl;

  Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.porcentagemDesconto,
    required this.estoque,
    required this.comprimento,
    required this.largura,
    required this.altura,
    required this.escalaDimensao,
    required this.peso,
    required this.escalaPeso,
    required this.categoria,
    required this.descricao,
    required this.imagensUrl,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'preco': preco,
      'porcentagemDesconto': porcentagemDesconto,
      'estoque': estoque,
      'comprimento': comprimento,
      'largura': largura,
      'altura': altura,
      'escalaDimensao': escalaDimensao,
      'peso': peso,
      'escalaPeso': escalaPeso,
      'categoria': categoria,
      'descricao': descricao,
      'imagensUrl': imagensUrl,
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'] as String,
      nome: map['nome'] as String,
      preco: map['preco'] as double,
      porcentagemDesconto: map['porcentagemDesconto'] as int,
      estoque: map['estoque'] as int,
      comprimento: map['comprimento'] as double,
      largura: map['largura'] as double,
      altura: map['altura'] as double,
      escalaDimensao: map['escalaDimensao'] as String,
      peso: map['peso'] as double,
      escalaPeso: map['escalaPeso'] as String,
      categoria: map['categoria'] as String,
      imagensUrl: List<String>.from(map['imagensUrl']),
      descricao: map['descricao'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Produto.fromJson(String source) => Produto.fromMap(json.decode(source) as Map<String, dynamic>);
}
