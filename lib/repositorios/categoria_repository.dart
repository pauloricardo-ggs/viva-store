import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/categoria.dart';

class CategoriaRepository {
  final firebaseFirestore = FirebaseFirestore.instance;

  final collection = 'categorias';

  List<Categoria> listar() {
    return [
      Categoria(nome: "Quarto", icone: Icons.bed_outlined),
      Categoria(nome: "Cozinha", icone: Icons.kitchen_outlined),
      Categoria(nome: "Banheiro", icone: Icons.shower_outlined),
      Categoria(nome: "Decoração", icone: Icons.filter_frames_outlined),
      Categoria(nome: "Masculino", icone: Icons.man),
      Categoria(nome: "Feminino", icone: Icons.woman),
      Categoria(nome: "Cosméticos", icone: Icons.brush_outlined),
    ];
  }
}
