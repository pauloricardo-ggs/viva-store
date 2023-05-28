import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viva_store/components/blurred_container.dart';
import 'package:viva_store/pages/auth_page.dart';
import 'package:viva_store/pages/favoritos_page.dart';
import 'package:viva_store/pages/home_page.dart';
import 'package:viva_store/pages/minhas_compras_page.dart';

class BarraNavegacao extends StatefulWidget {
  const BarraNavegacao({super.key});

  @override
  State<BarraNavegacao> createState() => _BarraNavegacaoState();
}

class _BarraNavegacaoState extends State<BarraNavegacao> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const FavoritesPage(),
      const PurchasesPage(),
      const AuthPage(),
    ];
    return Scaffold(
      body: Stack(
        children: [
          pages[_currentPage],
          Align(
            alignment: Alignment.bottomCenter,
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
}
