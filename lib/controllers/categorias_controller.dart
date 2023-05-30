import 'package:get/get.dart';
import 'package:viva_store/models/categoria.dart';
import 'package:viva_store/repositorios/categoria_repository.dart';

class CategoriasController extends GetxController {
  final CategoriaRepository _categoriaRepository = Get.put(CategoriaRepository());

  List<Categoria> listar() {
    return _categoriaRepository.listar();
  }
}
