import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viva_store/components/blurred_container.dart';
import 'package:viva_store/models/product.dart';
import 'package:viva_store/pages/account_page.dart';
import 'package:viva_store/pages/favorites_page.dart';
import 'package:viva_store/pages/home_page.dart';
import 'package:viva_store/pages/purchases_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> pages = [const HomePage(), const FavoritesPage(), const PurchasesPage(), const AccountPage()];
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          pages[_currentPage],
          const SizedBox(height: 100),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: ClipRect(
              child: BlurredContainer(
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                  selectedItemColor: Colors.black,
                  unselectedItemColor: HSLColor.fromColor(Theme.of(context).colorScheme.primary).withSaturation(Get.isDarkMode ? 0.3 : 0.7).toColor(),
                  selectedFontSize: 12,
                  currentIndex: _currentPage,
                  onTap: (value) {
                    setState(() => _currentPage = value);
                  },
                  items: const [
                    BottomNavigationBarItem(
                      activeIcon: Icon(CupertinoIcons.house_fill),
                      icon: Icon(CupertinoIcons.house),
                      label: 'Início',
                    ),
                    BottomNavigationBarItem(
                      activeIcon: Icon(CupertinoIcons.heart_fill),
                      icon: Icon(CupertinoIcons.heart),
                      label: 'Favoritos',
                    ),
                    BottomNavigationBarItem(
                      activeIcon: Icon(CupertinoIcons.bag_fill),
                      icon: Icon(CupertinoIcons.bag),
                      label: 'Minhas compras',
                    ),
                    BottomNavigationBarItem(
                      activeIcon: Icon(CupertinoIcons.person_crop_circle_fill),
                      icon: Icon(CupertinoIcons.person_crop_circle),
                      label: 'Minha conta',
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future createProduct() async {
    var product = Product(
      photo: "photo",
      name: "produto x",
      description: "esse é o produto x",
      category: "vestimenta",
      price: 99.99,
      height: 500,
      width: 20,
      lenght: 20,
      weight: 20,
      stock: 20,
      discountPercentage: 5,
    );

    var jsonProduct = product.toMap();

    final docProduct = FirebaseFirestore.instance.collection('products').doc();

    await docProduct.set(jsonProduct);
  }
}
