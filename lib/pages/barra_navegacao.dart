import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viva_store/components/blurred_container.dart';
import 'package:viva_store/controllers/auth_controller.dart';
import 'package:viva_store/dev_pack.dart';
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
  final _authController = Get.put(AuthController());
  final _devPack = const DevPack();
  Pages _currentPage = Pages.homePage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildPage(_currentPage),
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
                  currentIndex: _currentPage.index,
                  onTap: (value) {
                    if (!_authController.logado()) {
                      if (value == 1) {
                        _devPack.notificaoErro(mensagem: 'Você precisa estar logado para ver seus produtos favoritos');
                        return;
                      }
                      if (value == 2) {
                        _devPack.notificaoErro(mensagem: 'Você precisa estar logado para ver suas compras');
                        return;
                      }
                    }
                    setState(() => _currentPage = Pages.values[value]);
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

  void irParaTela(Pages page) {
    setState(() => _currentPage = page);
  }

  Widget buildPage(Pages page) {
    switch (page) {
      case Pages.homePage:
        return HomePage(irParaTelaDeLogin: () => setState(() => _currentPage = Pages.loginPage));
      case Pages.favoritesPage:
        return const FavoritesPage();
      case Pages.purchasesPage:
        return const PurchasesPage();
      case Pages.authPage:
        return const AuthPage();
      default:
        return const SizedBox();
    }
  }
}

enum Pages {
  homePage,
  favoritesPage,
  purchasesPage,
  authPage,
  loginPage,
}
