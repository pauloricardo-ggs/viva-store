import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:viva_store/components/blurred_container.dart';
import 'package:viva_store/components/page_view_indicators.dart';
import 'package:viva_store/models/produto.dart';

class CadastrarProdutoPage extends StatefulWidget {
  const CadastrarProdutoPage({super.key});

  @override
  State<CadastrarProdutoPage> createState() => _CadastrarProdutoPageState();
}

class _CadastrarProdutoPageState extends State<CadastrarProdutoPage> {
  final _formKey = GlobalKey<FormState>();

  late String categoriaSelecionada;
  late String escalaDimensaoSelecionada;
  late String escalaPesoSelecionada;

  late List<String> categorias;
  final List<File> _imagens = [];

  final nomeController = TextEditingController();
  final precoController = TextEditingController(text: "R\$ 0,00");
  final comprimentoController = TextEditingController();
  final larguraController = TextEditingController();
  final alturaController = TextEditingController();
  final pesoController = TextEditingController();
  final estoqueController = TextEditingController();
  final porcentagemDescontoController = TextEditingController(text: "Não");
  final descricaoController = TextEditingController();

  bool comprimentoVazio = false;
  bool larguraVazia = false;
  bool alturaVazia = false;
  bool pesoVazio = false;

  bool pesoEstaFocado = false;
  bool dimensoesEstaFocado = false;

  bool cadastrando = false;

  @override
  void initState() {
    setState(() {
      categorias = obterCategorias();
      categoriaSelecionada = categorias.first;
      escalaDimensaoSelecionada = "mm";
      escalaPesoSelecionada = "g";
    });
    super.initState();
  }

  @override
  void dispose() {
    nomeController.dispose();
    precoController.dispose();
    comprimentoController.dispose();
    larguraController.dispose();
    alturaController.dispose();
    pesoController.dispose();
    estoqueController.dispose();
    porcentagemDescontoController.dispose();
    descricaoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: cadastrando ? null : () => Navigator.pop(context),
        ),
        title: const Text("Cadastrar Produto"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20.0),
                CarrosselDeImagens(
                  images: _imagens,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 5.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildNome(),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildPreco(),
                            const SizedBox(width: 10),
                            buildPorcentagemDesconto(),
                            const SizedBox(width: 10),
                            buildEstoque(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        buildDimensoes(),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildPeso(),
                            const SizedBox(width: 10),
                            buildCategoria(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        buildDescricao(),
                        ElevatedButton(onPressed: () => cadastrar(), child: const Text("Cadastrar")),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          cadastrando
              ? const Stack(
                  children: [
                    ModalBarrier(dismissible: false),
                    BlurredContainer(blurriness: 4, child: Center(child: SizedBox(width: 60, height: 60, child: CircularProgressIndicator()))),
                  ],
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  void trocarFoco({String? focusedField}) {
    setState(() {
      pesoEstaFocado = focusedField == "peso";
      dimensoesEstaFocado = focusedField == "dimensoes";
    });
  }

  List<String> obterCategorias() {
    return ["Vestuário", "Beleza", "Decoração", "Cama, Mesa e Banho"];
  }

  bool existeAoMenosUmaFoto() {
    return _imagens.isNotEmpty;
  }

  bool camposValidos() {
    final valido = _formKey.currentState!.validate();
    setState(() {
      pesoVazio = pesoController.text.isEmpty;
      comprimentoVazio = comprimentoController.text.isEmpty;
      larguraVazia = larguraController.text.isEmpty;
      alturaVazia = alturaController.text.isEmpty;
    });
    return valido && !pesoVazio && !comprimentoVazio && !larguraVazia && !alturaVazia;
  }

  Future cadastrar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => cadastrando = true);

    if (!existeAoMenosUmaFoto()) {
      exibirMensagem('Adicione ao menos uma foto', sucesso: false);
      camposValidos();
      setState(() => cadastrando = false);
      return;
    }

    if (!camposValidos()) {
      setState(() => cadastrando = false);
      return;
    }

    final produtoDoc = FirebaseFirestore.instance.collection('produtos').doc();
    final List<String> imagensUrl = [];

    try {
      for (var index = 0; index < _imagens.length; index++) {
        final diretorio = FirebaseStorage.instance.ref().child('imagens/produtos/${produtoDoc.id}/${produtoDoc.id}_${index + 1}');
        await diretorio.putFile(_imagens[index]);
        imagensUrl.add(await diretorio.getDownloadURL());
      }
    } catch (e) {
      setState(() => cadastrando = false);
      exibirMensagem(e.toString(), sucesso: false);
    }

    final json = Produto(
            id: produtoDoc.id,
            nome: nomeController.value.text,
            preco: double.parse(precoController.value.text.replaceAll('R\$ ', '').replaceAll(',', '.')),
            porcentagemDesconto: int.tryParse(porcentagemDescontoController.value.text.replaceAll('%', '')) ?? 0,
            estoque: int.parse(estoqueController.value.text),
            comprimento: double.parse(comprimentoController.value.text.replaceAll(',', '.')),
            largura: double.parse(larguraController.value.text.replaceAll(',', '.')),
            altura: double.parse(alturaController.value.text.replaceAll(',', '.')),
            escalaDimensao: escalaDimensaoSelecionada,
            peso: double.parse(pesoController.value.text.replaceAll(',', '.')),
            escalaPeso: escalaPesoSelecionada,
            categoria: categoriaSelecionada,
            descricao: descricaoController.value.text,
            imagensUrl: imagensUrl)
        .toMap();

    await produtoDoc.set(json);

    setState(() => cadastrando = false);

    if (context.mounted) Navigator.pop(context);
    exibirMensagem('Produto cadastrado com sucesso');
  }

  void exibirMensagem(String mensagem, {bool sucesso = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: sucesso ? Colors.green : Colors.red.shade600,
      ),
    );
  }

  Widget buildNome() {
    return TextFormField(
      minLines: 1,
      maxLines: 5,
      controller: nomeController,
      onTap: () => trocarFoco(),
      decoration: const InputDecoration(label: Text("Nome")),
      inputFormatters: [LengthLimitingTextInputFormatter(80)],
      validator: (value) {
        if (value!.removeAllWhitespace.length < 5) return 'O nome deve ter no entre 5 e 80 caracteres';
        return null;
      },
    );
  }

  Widget buildPreco() {
    return Flexible(
      child: TextFormField(
        controller: precoController,
        keyboardType: TextInputType.number,
        onTap: () => trocarFoco(),
        decoration: const InputDecoration(label: Text("Preço")),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
        onChanged: (value) {
          final numeros = precoController.text.replaceAll(',', '');
          if (numeros.isEmpty) {
            precoController.text = 'R\$ 0,00';
          } else {
            final precoFormatado = "R\$ ${(int.parse(numeros) / 100).toStringAsFixed(2).replaceAll('.', ',')}";
            precoController.value = precoController.value.copyWith(
              text: precoFormatado,
              selection: TextSelection.collapsed(offset: precoFormatado.length),
            );
          }
        },
      ),
    );
  }

  Widget buildPorcentagemDesconto() {
    return Flexible(
      child: TextFormField(
        controller: porcentagemDescontoController,
        keyboardType: TextInputType.number,
        onTap: () => trocarFoco(),
        decoration: const InputDecoration(label: Text("Desconto")),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
        onChanged: (value) {
          final numeros = porcentagemDescontoController.text;
          if (numeros.isEmpty) {
            porcentagemDescontoController.text = 'Não';
          } else {
            final numerosInt = int.parse(numeros);
            final formattedValue = (numerosInt <= 100)
                ? '$numerosInt%'
                : (numerosInt == 100)
                    ? '100%'
                    : '${(numerosInt / 10).toString().split('.')[0]}%';
            porcentagemDescontoController.value = porcentagemDescontoController.value.copyWith(
              text: formattedValue,
              selection: TextSelection.fromPosition(TextPosition(offset: formattedValue.length - 1)),
            );
          }
        },
      ),
    );
  }

  Widget buildEstoque() {
    return SizedBox(
      width: 85,
      child: TextFormField(
        controller: estoqueController,
        keyboardType: TextInputType.number,
        onTap: () => trocarFoco(),
        decoration: const InputDecoration(label: FittedBox(fit: BoxFit.fitWidth, child: Text("Estoque"))),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
        validator: (value) {
          if (value!.isEmpty) return 'Obrigatório';
          return null;
        },
      ),
    );
  }

  Widget buildDimensoes() {
    final List<String> escalas = ["mm", "cm", "m"];
    const focado = "dimensoes";
    var vazio = comprimentoVazio || larguraVazia || alturaVazia;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: vazio
                    ? Colors.red.shade700
                    : dimensoesEstaFocado
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDimensaoIndividual('Comprimento', controller: comprimentoController, vazio: comprimentoVazio, focado: focado),
                Container(
                  alignment: Alignment.center,
                  height: 60,
                  child: Text("X", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
                buildDimensaoIndividual('Largura', controller: larguraController, vazio: larguraVazia, focado: focado),
                Container(
                  alignment: Alignment.center,
                  height: 60,
                  child: Text("X", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
                buildDimensaoIndividual('Altura', controller: alturaController, vazio: alturaVazia, focado: focado),
                const SizedBox(width: 10),
                SizedBox(
                  width: 76,
                  height: 59,
                  child: DropdownButtonFormField<String>(
                    value: escalaDimensaoSelecionada,
                    menuMaxHeight: 400,
                    borderRadius: BorderRadius.circular(15.0),
                    focusColor: Colors.transparent,
                    onTap: () => trocarFoco(focusedField: focado),
                    onChanged: (newValue) => setState(() => escalaDimensaoSelecionada = newValue!),
                    items: escalas.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
                    decoration: InputDecoration(
                      fillColor: dimensoesEstaFocado
                          ? vazio
                              ? Colors.red.withOpacity(0.2)
                              : Theme.of(context).colorScheme.secondary.withOpacity(0.16)
                          : Colors.transparent,
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), bottomRight: Radius.circular(15.0)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), bottomRight: Radius.circular(15.0)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        vazio
            ? Padding(
                padding: const EdgeInsets.only(left: 14.0, top: 8.0),
                child: Text(
                  "Obrigatório",
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget buildDimensaoIndividual(String texto, {required TextEditingController controller, required bool vazio, required String focado}) {
    return Flexible(
      child: TextFormField(
        onTap: () => trocarFoco(focusedField: focado),
        textAlign: TextAlign.center,
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
        decoration: InputDecoration(
          fillColor: Colors.transparent,
          label: Text(texto),
          labelStyle: const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 12),
          floatingLabelStyle: TextStyle(overflow: TextOverflow.ellipsis, color: vazio ? Colors.red.shade600 : null),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
        ),
        onChanged: (value) {
          final numerosInt = int.parse(controller.text.replaceAll(',', ''));
          final valorFormatado = (numerosInt / 10).toStringAsFixed(1).replaceAll('.', ',');
          controller.value = controller.value.copyWith(
            text: valorFormatado,
            selection: TextSelection.collapsed(offset: valorFormatado.length),
          );
        },
      ),
    );
  }

  Widget buildPeso() {
    final List<String> escalas = ["g", "kg"];
    const focado = "peso";

    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                  color: pesoVazio
                      ? Colors.red.shade700
                      : pesoEstaFocado
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent),
            ),
            child: Row(
              children: [
                Flexible(
                  child: SizedBox(
                    child: TextFormField(
                      controller: pesoController,
                      keyboardType: TextInputType.number,
                      onTap: () => trocarFoco(focusedField: focado),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                      onChanged: (value) {
                        final numerosInt = int.parse(pesoController.text.replaceAll(',', ''));
                        final valorFormatado = (numerosInt / 10).toStringAsFixed(1).replaceAll('.', ',');
                        pesoController.value = pesoController.value.copyWith(
                          text: valorFormatado,
                          selection: TextSelection.collapsed(offset: valorFormatado.length),
                        );
                      },
                      decoration: InputDecoration(
                        label: const Text('Peso'),
                        floatingLabelStyle: TextStyle(overflow: TextOverflow.ellipsis, color: pesoVazio ? Colors.red.shade600 : null),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), bottomLeft: Radius.circular(15.0)),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), bottomLeft: Radius.circular(15.0)),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 67,
                  height: 59,
                  child: DropdownButtonFormField<String>(
                    value: escalaPesoSelecionada,
                    menuMaxHeight: 400,
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () => trocarFoco(focusedField: focado),
                    onChanged: (newValue) => setState(() => escalaPesoSelecionada = newValue!),
                    items: escalas.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
                    decoration: InputDecoration(
                      fillColor: pesoEstaFocado
                          ? pesoVazio
                              ? Theme.of(context).brightness == Brightness.dark
                                  ? const Color.fromRGBO(55, 39, 36, 1)
                                  : const Color.fromRGBO(230, 206, 202, 1)
                              : Theme.of(context).colorScheme.secondary.withOpacity(0.3)
                          : null,
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), bottomRight: Radius.circular(15.0)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), bottomRight: Radius.circular(15.0)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          pesoVazio
              ? Padding(
                  padding: const EdgeInsets.only(left: 14.0, top: 8.0),
                  child: Text(
                    "Obrigatório",
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget buildCategoria() {
    return Expanded(
      child: SizedBox(
        height: 59,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return DropdownButtonFormField(
              decoration: const InputDecoration(label: Text('Categoria')),
              value: categoriaSelecionada,
              menuMaxHeight: 400,
              borderRadius: BorderRadius.circular(15.0),
              onTap: () => trocarFoco(),
              items: categorias.map(
                (String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: SizedBox(
                      width: constraints.maxWidth - 50,
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ).toList(),
              onChanged: (newValue) => setState(() => categoriaSelecionada = newValue!),
            );
          },
        ),
      ),
    );
  }

  Widget buildDescricao() {
    return TextFormField(
      minLines: 10,
      maxLines: 20,
      maxLength: 1000,
      decoration: const InputDecoration(
        label: Text('Descrição'),
        alignLabelWithHint: true,
      ),
      controller: descricaoController,
      onTap: () => trocarFoco(),
    );
  }
}

class CarrosselDeImagens extends StatefulWidget {
  const CarrosselDeImagens({Key? key, required this.images}) : super(key: key);

  final List<File> images;

  @override
  State<CarrosselDeImagens> createState() => _CarrosselDeImagensState();
}

class _CarrosselDeImagensState extends State<CarrosselDeImagens> {
  var _frontImage = 0;
  var _tapped = false;
  final CarouselController controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    const size = 250.0;
    var isDark = Theme.of(context).brightness == Brightness.dark;
    var secondary = Theme.of(context).colorScheme.secondary;
    var itemsCount = widget.images.length + (widget.images.length < 5 ? 1 : 0);

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: controller,
          itemCount: itemsCount,
          options: CarouselOptions(
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            viewportFraction: 0.7,
            height: 250,
            onPageChanged: (index, reason) => setState(() => _frontImage = index),
          ),
          itemBuilder: (context, index, realIndex) {
            if (widget.images.isEmpty || index == widget.images.length) {
              if (widget.images.length < 5) {
                return buildBotaoAddImagem(size, isDark, secondary);
              } else {
                return const SizedBox();
              }
            } else {
              return Stack(
                children: [
                  buildImagem(index, isDark, secondary),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _tapped
                        ? buildMenuOpcoes(isDark, index)
                        : const SizedBox(
                            key: Key('2'),
                          ),
                  ),
                ],
              );
            }
          },
        ),
        PageViewIndicators(numberOfPages: itemsCount, selectedPage: _frontImage)
      ],
    );
  }

  Future obterImagens({required ImageSource source}) async {
    var picker = ImagePicker();
    try {
      if (source == ImageSource.camera) {
        final image = await picker.pickImage(source: source);
        var croppedImage = await cortarImagens(File(image!.path));
        if (croppedImage != null) setState(() => widget.images.add(croppedImage));
      } else {
        final images = await picker.pickMultiImage();
        if (images.length <= 5 - widget.images.length) {
          for (var i = 0; i < images.length; i++) {
            var croppedImage = await cortarImagens(File(images[i].path));
            if (croppedImage != null) setState(() => widget.images.add(croppedImage));
          }
        } else {
          if (context.mounted) showCupertinoDialog(context: context, builder: buildMensagemQuantidadeDeFotosExcedida);
        }
      }
    } on Exception catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<File?> cortarImagens(File imageFile) async {
    var croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  Widget buildImagem(int index, bool isDark, Color secondary) {
    return GestureDetector(
      onTap: () => _frontImage == index ? setState(() => _tapped = true) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? secondary.withOpacity(0.2) : secondary.withOpacity(0.16),
          borderRadius: BorderRadius.circular(15.0),
          image: DecorationImage(image: FileImage(widget.images[index]), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget buildBotaoAddImagem(double size, bool isDark, Color secondary) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? secondary.withOpacity(0.2) : secondary.withOpacity(0.16),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: IconButton(
        icon: const Icon(CupertinoIcons.photo, size: 50),
        onPressed: () {
          setState(() => _tapped = false);
          showCupertinoModalPopup(context: context, builder: buildSelecaoOrigem);
        },
      ),
    );
  }

  Widget buildMensagemQuantidadeDeFotosExcedida(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text("Limite excedido"),
      content: const Text("Limite máximo de 5 fotos"),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
            obterImagens(source: ImageSource.gallery);
          },
          child: const Text("Ok"),
        )
      ],
    );
  }

  Widget buildSelecaoOrigem(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text("Adicionar foto"),
      message: const Text("De onde gostaria de adicionar a foto?"),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            obterImagens(source: ImageSource.camera);
          },
          child: const Text("Câmera"),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            obterImagens(source: ImageSource.gallery);
          },
          child: const Text("Galeria"),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text("Cancelar"),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget buildMenuOpcoes(bool isDark, int index) {
    return ClipRRect(
      key: const Key('1'),
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? Colors.black : Colors.white).withOpacity(0.5),
        ),
        child: BlurredContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildOpcoes(
                text: "Remover",
                isDark: isDark,
                onPressed: () => index == _frontImage ? setState(() => widget.images.removeAt(index)) : null,
              ),
              divisor(isDark),
              buildOpcoes(
                text: "Mover para direita",
                isDark: isDark,
                onPressed: index != widget.images.length - 1 && index == _frontImage
                    ? () {
                        setState(() {
                          var image = widget.images.elementAt(index);
                          widget.images.removeAt(index);
                          widget.images.insert(index + 1, image);
                          controller.jumpToPage(index + 1);
                        });
                      }
                    : null,
              ),
              divisor(isDark),
              buildOpcoes(
                text: "Mover para esquerda",
                isDark: isDark,
                onPressed: index != 0 && index == _frontImage
                    ? () {
                        setState(() {
                          var image = widget.images.elementAt(index);
                          widget.images.removeAt(index);
                          widget.images.insert(index - 1, image);
                          controller.jumpToPage(index - 1);
                        });
                      }
                    : null,
              ),
              divisor(isDark),
              buildOpcoes(
                text: "Ok",
                isDark: isDark,
                onPressed: () => index == _frontImage ? setState(() => _tapped = false) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget divisor(bool isDark) {
    return Divider(
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
      thickness: 1,
      height: 0,
    );
  }

  Widget buildOpcoes({required String text, required bool isDark, VoidCallback? onPressed}) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 17),
        ),
      ),
    );
  }
}
