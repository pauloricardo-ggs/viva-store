import 'package:flutter/material.dart';

class PageViewIndicators extends StatelessWidget {
  const PageViewIndicators({
    super.key,
    required this.numberOfPages,
    required this.selectedPage,
  });

  final int numberOfPages;
  final int selectedPage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: numberOfPages,
        itemBuilder: (context, index) => _indicator(
          isActive: selectedPage == index,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _indicator({required bool isActive, required Color color}) {
    return SizedBox(
      height: 6,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: isActive ? 6 : 5.0,
        width: isActive ? 7 : 5.0,
        decoration: BoxDecoration(
          boxShadow: [
            isActive
                ? BoxShadow(
                    color: const Color(0XFF2FB7B2).withOpacity(0.72),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: const Offset(
                      0.0,
                      0.0,
                    ),
                  )
                : const BoxShadow(
                    color: Colors.transparent,
                  )
          ],
          shape: BoxShape.circle,
          color: isActive ? color : const Color.fromARGB(255, 202, 202, 202),
        ),
      ),
    );
  }
}
