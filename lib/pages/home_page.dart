import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:viva_store/components/page_view_indicators.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Categoria> _categories = [
    Categoria(nome: "Quarto", icon: Icons.bed_outlined),
    Categoria(nome: "Cozinha", icon: Icons.kitchen_outlined),
    Categoria(nome: "Banheiro", icon: Icons.shower_outlined),
    Categoria(nome: "Roupas", icon: Icons.woman),
    Categoria(nome: "Banheiro", icon: Icons.shower_outlined),
    Categoria(nome: "Banheiro", icon: Icons.shower_outlined),
    Categoria(nome: "Banheiro", icon: Icons.shower_outlined),
  ];

  final List<String> _offers = [
    "images/home_page/banners/oferta_decoracao.png",
    "images/home_page/banners/oferta_roupa.jpg",
    "images/home_page/banners/oferta_banheiro.jpg",
  ];

  final List<Produto> _products = [
    Produto(
      photo: "images/home_page/produtos/fronha.png",
      name: "Fronha 50cmx70cm Natureza geométrica",
      price: 19.90,
      discount: 5,
      onSale: true,
      onCart: false,
      favorited: false,
    ),
    Produto(
      photo: "images/home_page/produtos/frigideira.png",
      name: "Chilli frigideira 16cm",
      price: 79.90,
      discount: 20,
      onSale: true,
      onCart: false,
      favorited: true,
    ),
    Produto(
      photo: "images/home_page/produtos/cafeteira.png",
      name: "Grano cafeteira prensa francesa 350ml",
      price: 35.90,
      discount: 10,
      onSale: true,
      onCart: true,
      favorited: false,
    ),
    Produto(
      photo: "images/home_page/produtos/luminaria.png",
      name: "Cafezal luminária de mesa",
      price: 119.90,
      discount: 40,
      onSale: true,
      onCart: true,
      favorited: true,
    ),
    Produto(
      photo: "images/home_page/produtos/vestido_1.png",
      name: "Vestido midi em viscolinho com estampa abstrata multicores",
      price: 239.90,
      discount: 15,
      onSale: true,
      onCart: false,
      favorited: false,
    ),
    Produto(
      photo: "images/home_page/produtos/vestido_2.png",
      name: "Vestido curto em tricô canelado com manga longa e fenda no punho preto",
      price: 159.90,
      discount: 5,
      onSale: true,
      onCart: false,
      favorited: false,
    ),
    Produto(
      photo: "images/home_page/produtos/jaqueta.png",
      name: "Jaqueta corta vento esportiva com blocos de cor branco",
      price: 219.90,
      discount: 20,
      onSale: true,
      onCart: false,
      favorited: false,
    ),
  ];

  int currentBanner = 0;
  final searchController = TextEditingController();

  void onPageChanged(int index) {
    setState(() => currentBanner = index);
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: _SearchTextField(controller: searchController),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: () => Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark),
            icon: Icon(
              Get.isDarkMode ? CupertinoIcons.sun_min_fill : CupertinoIcons.moon_fill,
              color: colorScheme.secondary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () => {},
              icon: Icon(
                CupertinoIcons.cart_fill,
                color: colorScheme.secondary,
                size: 30,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _CategoriesList(categorias: _categories),
            const SizedBox(height: 10),
            _BannerPageView(ofertas: _offers, onPageChanged: onPageChanged),
            PageViewIndicators(numberOfPages: _offers.length, selectedPage: currentBanner),
            _ProductsOnSale(products: _products),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _ProductsOnSale extends StatefulWidget {
  const _ProductsOnSale({required this.products});

  final List<Produto> products;

  @override
  State<_ProductsOnSale> createState() => _ProductsOnSaleState();
}

class _ProductsOnSaleState extends State<_ProductsOnSale> {
  late int numberOfProducts;

  @override
  void initState() {
    setState(() => numberOfProducts = 5);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _title(),
        const SizedBox(height: 8.0),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          itemCount: widget.products.length >= numberOfProducts ? numberOfProducts : widget.products.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8.0),
          itemBuilder: (context, i) => SizedBox(
            height: 170,
            child: _productCard(
              primaryColor: Theme.of(context).colorScheme.primary,
              product: widget.products[i],
            ),
          ),
        ),
        const SizedBox(height: 3.0),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: ElevatedButton(
            onPressed: widget.products.length <= numberOfProducts ? null : () => setState(() => numberOfProducts += 5),
            child: const Text("Ver mais"),
          ),
        ),
      ],
    );
  }

  Widget _title() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: const Text(
        "Ofertas",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _productCard({required Color primaryColor, required Produto product}) {
    return Stack(
      children: [
        Material(
          color: Get.isDarkMode ? const Color(0x18FFFFFF) : const Color(0xCEFFFFFF),
          borderRadius: BorderRadius.circular(8.0),
          elevation: 1,
          child: Row(
            children: [
              _productPhoto(photo: product.photo),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 15.0, bottom: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _productName(name: product.name),
                      ),
                      _productPrices(primaryColor: primaryColor, price: product.price, discount: product.discount),
                      const SizedBox(height: 10.0),
                      _buttons(primaryColor: primaryColor, onCart: product.onCart, favorited: product.favorited),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _discountTag(discount: product.discount),
      ],
    );
  }

  Widget _discountTag({required int discount}) {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        height: 20,
        width: 58,
        child: CustomPaint(
          painter: PriceTagPaint(color: Theme.of(context).colorScheme.primary),
          child: Center(
            child: Text(
              "-$discount%   ",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _productPhoto({required String photo}) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            color: Get.isDarkMode ? const Color(0x61FFFFFF) : const Color(0xFFFFFFFF),
            border: Border.all(color: Get.isDarkMode ? const Color(0xFF757575) : const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              photo,
              height: 170,
              width: 170,
            ),
          ),
        ),
      ),
    );
  }

  Widget _productName({required String name}) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _productPrices({required Color primaryColor, required double price, required int discount}) {
    var formatter = NumberFormat.currency(decimalDigits: 2, symbol: 'R\$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formatter.format(price - (price * discount / 100)),
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formatter.format(price),
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              decoration: TextDecoration.lineThrough,
              decorationThickness: 1.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buttons({required Color primaryColor, required bool onCart, required bool favorited}) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: const ButtonStyle(padding: MaterialStatePropertyAll(EdgeInsets.zero)),
              child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Comprar",
                    style: TextStyle(fontSize: 18),
                  )),
            ),
          ),
          const SizedBox(width: 8.0),
          Icon(CupertinoIcons.cart_fill, size: 30, color: onCart ? primaryColor : Colors.grey.shade500),
          const SizedBox(width: 8.0),
          Icon(CupertinoIcons.heart_fill, size: 30, color: favorited ? Colors.red : Colors.grey.shade500),
        ],
      ),
    );
  }
}

class _BannerPageView extends StatelessWidget {
  const _BannerPageView({
    required this.ofertas,
    required this.onPageChanged,
  });

  final List<String> ofertas;
  final Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return CarouselSlider.builder(
      itemCount: ofertas.length,
      itemBuilder: (context, index, realIndex) => _banner(image: ofertas[index], isDark: isDark),
      options: CarouselOptions(
        height: 200,
        onPageChanged: (index, reason) => onPageChanged(index),
        enlargeCenterPage: true,
        enlargeFactor: 0.2,
        autoPlayAnimationDuration: const Duration(milliseconds: 1500),
        autoPlay: true,
        pauseAutoPlayOnManualNavigate: true,
        pauseAutoPlayOnTouch: true,
        autoPlayInterval: const Duration(seconds: 10),
      ),
    );
  }

  Widget _banner({required String image, required bool isDark}) {
    Color borderColor = isDark ? Colors.white30 : Colors.black26;
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 10,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoriesList extends StatelessWidget {
  const _CategoriesList({required this.categorias});

  final List<Categoria> categorias;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        itemBuilder: (context, i) => Center(
          child: _categoryButton(
            icon: categorias[i].icon,
            text: categorias[i].nome,
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }

  Widget _categoryButton({required String text, required IconData icon, required Color backgroundColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: backgroundColor,
          ),
          child: IconButton(
            onPressed: () => {},
            icon: Icon(icon),
            color: Colors.black,
            iconSize: 30,
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 65,
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}

class _SearchTextField extends StatelessWidget {
  final TextEditingController controller;

  const _SearchTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: TextField(
        style: const TextStyle(color: Colors.black),
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          prefixIcon: const Icon(CupertinoIcons.search),
          prefixIconColor: Colors.black45,
          fillColor: Theme.of(context).colorScheme.secondary,
          hintText: "Pesquisar",
          hintStyle: const TextStyle(color: Colors.black45),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
    );
  }
}

class Categoria {
  String nome;
  IconData icon;

  Categoria({
    required this.nome,
    required this.icon,
  });
}

class Produto {
  String photo;
  String name;
  double price;
  int discount;
  bool onSale;
  bool onCart;
  bool favorited;

  Produto({
    required this.photo,
    required this.name,
    required this.price,
    required this.discount,
    required this.onSale,
    required this.onCart,
    required this.favorited,
  });
}

class PriceTagPaint extends CustomPainter {
  const PriceTagPaint({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    Path path = Path();

    path
      ..moveTo(0, 0)
      ..lineTo(size.width * .87, 0)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width * .87, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    //* Circle
    canvas.drawCircle(
      Offset(size.width * .87, size.height * .5),
      size.height * .15,
      paint..color = Get.isDarkMode ? const Color(0xFF666666) : const Color(0xFFFFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
