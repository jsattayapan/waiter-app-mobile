import 'package:flutter/material.dart';
import 'package:jep_restaurant_waiter_app/screens/tables_page.dart';

import '../constants.dart';

class TableSection extends StatelessWidget {
  final String label;
  final int page;
  final pageController;

  TableSection({this.label, this.page, this.pageController});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          pageController.animateToPage(
            page,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          color: currentPage == page ? primaryTextColor : darkPrimaryColor,
          margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
          height: 40.0,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.0,
                color: currentPage == page ? Colors.black : Colors.white,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
