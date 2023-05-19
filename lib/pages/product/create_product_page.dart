// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  late dynamic selectedCategory;
  late String selectedDimensionMetric;
  late String selectedWeightMetric;

  late List<String> categories;
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
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              const PhotoImporteeer(),
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
                      verify: () => setState(() => categoryIsEmpty = selectedCategory == null),
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
              ElevatedButton(onPressed: () => _create(), child: const Text("Enviar")),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _create() {
    setState(() {
      nameIsEmpty = nameController.text.isEmpty;
      stockIsEmpty = stockController.text.isEmpty;
      weightIsEmpty = weightController.text.isEmpty;
      lenghtIsEmpty = lenghtController.text.isEmpty;
      widthIsEmpty = widthController.text.isEmpty;
      heightIsEmpty = heightController.text.isEmpty;
    });

    if (!(nameIsEmpty || lenghtIsEmpty || widthIsEmpty || heightIsEmpty || weightIsEmpty || stockIsEmpty)) {
      debugPrint(nameController.value.text);
      debugPrint(priceController.value.text.removeAllWhitespace);
      debugPrint(discountController.value.text);
      debugPrint(stockController.value.text);
      debugPrint("${lenghtController.value.text}x${widthController.value.text}x${heightController.value.text}$selectedDimensionMetric");
      debugPrint("${weightController.value.text} $selectedWeightMetric");
      debugPrint(selectedCategory);
      debugPrint(descriptionController.value.text);
    }
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
  final Function verify;
  final Function onTap;
  final bool isEmpty;

  const _CategoryField({
    Key? key,
    required this.selectedCategory,
    required this.categories,
    required this.changeCategory,
    required this.verify,
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

class PhotoImporteeer extends StatefulWidget {
  const PhotoImporteeer({Key? key}) : super(key: key);

  @override
  State<PhotoImporteeer> createState() => _PhotoImporteeerState();
}

class _PhotoImporteeerState extends State<PhotoImporteeer> {
  final List<File> _image = [];

  Future _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      File temporaryImage = File(image.path);
      File? croppedImage = await _cropImage(imageFile: temporaryImage);

      if (croppedImage != null) {
        setState(() {
          _image.add(croppedImage);
        });
      }
    } on Exception catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  @override
  Widget build(BuildContext context) {
    const double size = 250.0;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color secondary = Theme.of(context).colorScheme.secondary;
    return CarouselSlider.builder(
      itemCount: _image.length + 1,
      options: CarouselOptions(
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        disableCenter: true,
        enlargeFactor: 0.2,
      ),
      itemBuilder: (context, index, realIndex) {
        return _image.isEmpty || index >= _image.length
            ? AspectRatio(
                aspectRatio: 1,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: isDark ? secondary.withOpacity(0.2) : secondary.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: IconButton(
                    icon: const Icon(CupertinoIcons.photo, size: 50),
                    onPressed: _pickImage,
                  ),
                ),
              )
            : AspectRatio(
                aspectRatio: 1,
                child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: isDark ? secondary.withOpacity(0.2) : secondary.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(15.0),
                      image: DecorationImage(image: FileImage(_image[index]), fit: BoxFit.cover),
                    )),
              );
      },
    );
  }
}
