import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:viva_store/components/blurred_container.dart';
import 'package:viva_store/components/page_view_indicators.dart';

class CadastrarProdutoPage extends StatefulWidget {
  const CadastrarProdutoPage({super.key});

  @override
  State<CadastrarProdutoPage> createState() => _CadastrarProdutoPageState();
}

class _CadastrarProdutoPageState extends State<CadastrarProdutoPage> {
  late String selectedCategory;
  late String selectedDimensionMetric;
  late String selectedWeightMetric;

  late List<String> categories;
  final List<File> _images = [];
  final List<String> weightMetrics = ["g", "kg"];
  final List<String> dimensionMetrics = ["mm", "cm", "m"];

  final nameController = TextEditingController();
  final priceController = TextEditingController(text: "R\$ 0,00");
  final lenghtController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final stockController = TextEditingController();
  final discountController = TextEditingController(text: "Não");
  final descriptionController = TextEditingController();

  bool nameIsEmpty = false;
  bool lenghtIsEmpty = false;
  bool widthIsEmpty = false;
  bool heightIsEmpty = false;
  bool weightIsEmpty = false;
  bool stockIsEmpty = false;
  bool categoryIsEmpty = false;

  bool weightDropdownTextFieldIsFocused = false;
  bool dimensionsDropdownTextFieldIsFocused = false;

  @override
  void initState() {
    setState(() {
      categories = _getCategories();
      selectedCategory = categories.first;
      selectedDimensionMetric = "mm";
      selectedWeightMetric = "g";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Cadastrar Produto"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            _PhotoPicker(
              images: _images,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 5.0),
              child: Column(
                children: [
                  _NameField(
                    controller: nameController,
                    verify: () => setState(() => nameIsEmpty = nameController.text.isEmpty),
                    onTap: () => _changedFocus,
                    isEmpty: nameIsEmpty,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PriceField(
                        controller: priceController,
                        onTap: () => _changedFocus,
                      ),
                      const SizedBox(width: 10),
                      _DiscountField(
                        controller: discountController,
                        onTap: () => _changedFocus,
                      ),
                      const SizedBox(width: 10),
                      _StockField(
                        controller: stockController,
                        verify: () => setState(() => stockIsEmpty = stockController.text.isEmpty),
                        onTap: () => _changedFocus,
                        isEmpty: stockIsEmpty,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _DimensionsField(
                    lenghtController: lenghtController,
                    widthController: widthController,
                    heightController: heightController,
                    verifyLenght: () => setState(() => lenghtIsEmpty = lenghtController.text.isEmpty),
                    verifyWidth: () => setState(() => widthIsEmpty = widthController.text.isEmpty),
                    verifyHeight: () => setState(() => heightIsEmpty = heightController.text.isEmpty),
                    changeMetric: (newMetric) => setState(() => selectedDimensionMetric = newMetric),
                    onTap: ({focused = "dimensionsDropdownTextField"}) => _changedFocus(focusedField: focused),
                    isFocused: dimensionsDropdownTextFieldIsFocused,
                    lenghtIsEmpty: lenghtIsEmpty,
                    widthIsEmpty: widthIsEmpty,
                    heightIsEmpty: heightIsEmpty,
                    selectedMetric: selectedDimensionMetric,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 135,
                        child: _WeightDropDownTextField(
                          text: "Peso",
                          selectedMetric: selectedWeightMetric,
                          controller: weightController,
                          verify: () => setState(() => weightIsEmpty = weightController.text.isEmpty),
                          onChanged: (newMetric) => setState(() => selectedWeightMetric = newMetric),
                          onTap: ({focused = "weightDropdownTextField"}) => _changedFocus(focusedField: focused),
                          isEmpty: weightIsEmpty,
                          isFocused: weightDropdownTextFieldIsFocused,
                          items: weightMetrics,
                          selectorWidth: 67,
                          maxLenght: 4,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CategoryField(
                          selectedCategory: selectedCategory,
                          categories: categories,
                          changeCategory: (newCategory) => setState(() => selectedCategory = newCategory),
                          onTap: () => _changedFocus,
                          isEmpty: categoryIsEmpty,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  _DescriptionField(
                    controller: descriptionController,
                    onTap: () => _changedFocus,
                  ),
                  ElevatedButton(onPressed: () => _createProduct(), child: const Text("Enviar")),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changedFocus({String? focusedField}) {
    setState(() {
      weightDropdownTextFieldIsFocused = focusedField == "weightDropdownTextField";
      dimensionsDropdownTextFieldIsFocused = focusedField == "dimensionsDropdownTextField";
    });
  }

  List<String> _getCategories() {
    return ["Vestuário", "Beleza", "Decoração", "Cama, Mesa e Banho"];
  }

  Future _createProduct() async {
    if (!_validPhotos()) {
      showCupertinoModalPopup(context: context, builder: _noPhotosAddedDialog);
      return;
    }
    if (!_validFields()) {
      return;
    }

    final docProduct = FirebaseFirestore.instance.collection('produtos').doc();

    try {
      for (var index = 0; index < _images.length; index++) {
        final diretorio = FirebaseStorage.instance.ref().child('imagens/produtos/${docProduct.id}/${docProduct.id}_${index + 1}');
        await diretorio.putFile(_images[index]);
        //referenciaImagem.getDownloadURL();
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    final json = {
      'nome': nameController.value.text,
      'preco': priceController.value.text,
      'desconto': discountController.value.text,
      'estoque': stockController.value.text,
      'dimensoes': "${lenghtController.value.text}x${widthController.value.text}x${widthController.value.text}$selectedDimensionMetric",
      'peso': "${weightController.value.text}$selectedWeightMetric",
      'categoria': selectedCategory,
      'descricao': descriptionController.value.text,
    };
    await docProduct.set(json);
    if (context.mounted) showCupertinoModalPopup(context: context, builder: _productCreatedDialog);
  }

  bool _validFields() {
    setState(() {
      nameIsEmpty = nameController.text.isEmpty;
      stockIsEmpty = stockController.text.isEmpty;
      weightIsEmpty = weightController.text.isEmpty;
      lenghtIsEmpty = lenghtController.text.isEmpty;
      widthIsEmpty = widthController.text.isEmpty;
      heightIsEmpty = heightController.text.isEmpty;
    });

    return !(nameIsEmpty || lenghtIsEmpty || widthIsEmpty || heightIsEmpty || weightIsEmpty || stockIsEmpty);
  }

  bool _validPhotos() {
    return _images.isNotEmpty;
  }

  Widget _noPhotosAddedDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text("Aviso"),
      content: const Text("Adicione ao menos uma foto"),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text("Ok"),
        )
      ],
    );
  }

  Widget _productCreatedDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text("Sucesso"),
      content: const Text("Produto cadastrado com sucesso"),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: const Text("Ok"),
        )
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final Function verify;
  final Function onTap;
  final bool isEmpty;

  const _NameField({
    Key? key,
    required this.controller,
    required this.verify,
    required this.onTap,
    required this.isEmpty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Nome"),
        const SizedBox(height: 2),
        TextField(
          controller: controller,
          onChanged: (newValue) => verify(),
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
          decoration: InputDecoration(errorText: isEmpty ? 'Obrigatório' : null),
          onTap: onTap(),
        ),
      ],
    );
  }
}

class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  final Function onTap;

  const _PriceField({
    Key? key,
    required this.controller,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Preço"),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
            onTap: onTap(),
            onChanged: (value) {
              final text = controller.text.replaceAll(',', '');
              if (text.isEmpty) {
                controller.text = 'R\$ 0,00';
              } else {
                final value = int.parse(text);
                final formattedValue = "R\$ ${(value / 100).toStringAsFixed(2).replaceAll('.', ',')}";
                controller.value = controller.value.copyWith(
                  text: formattedValue,
                  selection: TextSelection.collapsed(offset: formattedValue.length),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DiscountField extends StatelessWidget {
  final TextEditingController controller;
  final Function onTap;

  const _DiscountField({
    Key? key,
    required this.controller,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Desconto"),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
            onTap: onTap(),
            onChanged: (value) {
              final text = controller.text;
              if (text.isEmpty) {
                controller.text = 'Não';
              } else {
                final value = int.parse(text);
                final formattedValue = (value <= 100)
                    ? '$value%'
                    : (value == 100)
                        ? '100%'
                        : '${(value / 10).toString().split('.')[0]}%';
                controller.value = controller.value.copyWith(
                  text: formattedValue,
                  selection: TextSelection.fromPosition(TextPosition(offset: formattedValue.length - 1)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _StockField extends StatelessWidget {
  final TextEditingController controller;
  final Function verify;
  final Function onTap;
  final bool isEmpty;

  const _StockField({
    Key? key,
    required this.controller,
    required this.verify,
    required this.onTap,
    required this.isEmpty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Estoque"),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
            decoration: InputDecoration(errorText: isEmpty ? 'Obrigatório' : null),
            onChanged: (newValue) => verify(),
            onTap: onTap(),
          ),
        ],
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String) changeCategory;
  final Function onTap;
  final bool isEmpty;

  const _CategoryField({
    Key? key,
    required this.selectedCategory,
    required this.categories,
    required this.changeCategory,
    required this.onTap,
    required this.isEmpty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Categoria"),
        const SizedBox(height: 2),
        SizedBox(
          height: 59,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return DropdownButtonFormField(
                value: selectedCategory,
                menuMaxHeight: 400,
                borderRadius: BorderRadius.circular(15.0),
                onTap: onTap(),
                items: categories.map(
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
                onChanged: (newValue) => changeCategory(newValue!),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DimensionsField extends StatelessWidget {
  final TextEditingController lenghtController;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final Function verifyLenght;
  final Function verifyWidth;
  final Function verifyHeight;
  final VoidCallback onTap;
  final Function(String) changeMetric;
  final bool lenghtIsEmpty;
  final bool widthIsEmpty;
  final bool heightIsEmpty;
  final bool isFocused;
  final String selectedMetric;

  const _DimensionsField({
    Key? key,
    required this.lenghtController,
    required this.widthController,
    required this.heightController,
    required this.verifyLenght,
    required this.verifyWidth,
    required this.verifyHeight,
    required this.onTap,
    required this.changeMetric,
    required this.lenghtIsEmpty,
    required this.widthIsEmpty,
    required this.heightIsEmpty,
    required this.isFocused,
    required this.selectedMetric,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> dimensionMetrics = ["mm", "cm", "m"];
    var isEmpty = lenghtIsEmpty || widthIsEmpty || heightIsEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Dimensões (CxLxA)"),
        const SizedBox(height: 2),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: isEmpty
                  ? Colors.red.shade700
                  : isFocused
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: TextField(
                  onTap: onTap,
                  controller: lenghtController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: (newValue) => verifyLenght(),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  decoration: const InputDecoration(
                    hintText: "C",
                    fillColor: Colors.transparent,
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 60,
                width: 20,
                child: Text("X", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
              Flexible(
                child: TextField(
                  onTap: onTap,
                  textAlign: TextAlign.center,
                  controller: widthController,
                  keyboardType: TextInputType.number,
                  onChanged: (newValue) => verifyWidth(),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  decoration: const InputDecoration(
                    hintText: "L",
                    fillColor: Colors.transparent,
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 60,
                width: 20,
                child: Text("X", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
              Flexible(
                child: TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  onTap: onTap,
                  onChanged: (newValue) => verifyHeight(),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: "A",
                    fillColor: Colors.transparent,
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 76,
                height: 59,
                child: DropdownButtonFormField<String>(
                  value: selectedMetric,
                  menuMaxHeight: 400,
                  borderRadius: BorderRadius.circular(15.0),
                  focusColor: Colors.transparent,
                  onTap: onTap,
                  onChanged: (newValue) => changeMetric(newValue!),
                  items: dimensionMetrics.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
                  decoration: InputDecoration(
                    fillColor: isFocused
                        ? isEmpty
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
        isEmpty
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
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final Function onTap;

  const _DescriptionField({
    Key? key,
    required this.controller,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Descrição"),
        const SizedBox(height: 2),
        TextFormField(
          minLines: 10,
          maxLines: 20,
          maxLength: 1000,
          controller: controller,
          onTap: onTap(),
        ),
      ],
    );
  }
}

class _WeightDropDownTextField extends StatelessWidget {
  final String text;
  final String selectedMetric;
  final TextEditingController controller;
  final Function verify;
  final Function(String) onChanged;
  final VoidCallback onTap;
  final bool isEmpty;
  final bool isFocused;
  final List<String> items;
  final double selectorWidth;
  final int maxLenght;

  const _WeightDropDownTextField({
    Key? key,
    required this.text,
    required this.selectedMetric,
    required this.controller,
    required this.verify,
    required this.onChanged,
    required this.onTap,
    required this.isEmpty,
    required this.isFocused,
    required this.items,
    required this.selectorWidth,
    required this.maxLenght,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text),
        const SizedBox(height: 2),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
                color: isEmpty
                    ? Colors.red.shade700
                    : isFocused
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent),
          ),
          child: Row(
            children: [
              Flexible(
                child: SizedBox(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    onChanged: (newValue) => verify(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(maxLenght)],
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), bottomLeft: Radius.circular(15.0)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), bottomLeft: Radius.circular(15.0)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    onTap: onTap,
                  ),
                ),
              ),
              SizedBox(
                width: selectorWidth,
                height: 59,
                child: DropdownButtonFormField<String>(
                  value: selectedMetric,
                  menuMaxHeight: 400,
                  borderRadius: BorderRadius.circular(15.0),
                  onTap: onTap,
                  onChanged: (newValue) => onChanged(newValue!),
                  items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
                  decoration: InputDecoration(
                    fillColor: isFocused
                        ? isEmpty
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
        isEmpty
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
    );
  }
}

class _PhotoPicker extends StatefulWidget {
  const _PhotoPicker({Key? key, required this.images}) : super(key: key);

  final List<File> images;

  @override
  State<_PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<_PhotoPicker> {
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
                return _addPhotoButton(size, isDark, secondary);
              } else {
                return const SizedBox();
              }
            } else {
              return Stack(
                children: [
                  _photo(index, isDark, secondary),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _tapped
                        ? _blurriedPhotoMenu(isDark, index)
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

  Future _pickImage({required ImageSource source}) async {
    var picker = ImagePicker();
    try {
      if (source == ImageSource.camera) {
        final image = await picker.pickImage(source: source);
        var croppedImage = await _cropImage(File(image!.path));
        if (croppedImage != null) setState(() => widget.images.add(croppedImage));
      } else {
        final images = await picker.pickMultiImage();
        if (images.length <= 5 - widget.images.length) {
          for (var i = 0; i < images.length; i++) {
            var croppedImage = await _cropImage(File(images[i].path));
            if (croppedImage != null) setState(() => widget.images.add(croppedImage));
          }
        } else {
          if (context.mounted) showCupertinoDialog(context: context, builder: _numberOfPhotosExcededDialog);
        }
      }
    } on Exception catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    var croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  Widget _photo(int index, bool isDark, Color secondary) {
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

  Widget _addPhotoButton(double size, bool isDark, Color secondary) {
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
          showCupertinoModalPopup(context: context, builder: _selectSourceActionSheet);
        },
      ),
    );
  }

  Widget _numberOfPhotosExcededDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text("Limite excedido"),
      content: const Text("Limite máximo de 5 fotos"),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
            _pickImage(source: ImageSource.gallery);
          },
          child: const Text("Ok"),
        )
      ],
    );
  }

  Widget _selectSourceActionSheet(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text("Adicionar foto"),
      message: const Text("De onde gostaria de adicionar a foto?"),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _pickImage(source: ImageSource.camera);
          },
          child: const Text("Câmera"),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _pickImage(source: ImageSource.gallery);
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

  Widget _blurriedPhotoMenu(bool isDark, int index) {
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
              _menuTextButton(
                text: "Remover",
                isDark: isDark,
                onPressed: () => index == _frontImage ? setState(() => widget.images.removeAt(index)) : null,
              ),
              _divider(isDark),
              _menuTextButton(
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
              _divider(isDark),
              _menuTextButton(
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
              _divider(isDark),
              _menuTextButton(
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

  Widget _divider(bool isDark) {
    return Divider(
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
      thickness: 1,
      height: 0,
    );
  }

  Widget _menuTextButton({required String text, required bool isDark, VoidCallback? onPressed}) {
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
