import 'package:firebase/colors.dart';
import 'package:firebase/navBar.dart';
import 'package:flutter/material.dart';

class OnboardContainer extends StatelessWidget {
  OnboardContainer(
      {super.key,
      required this.icon,
      required this.text,
      required this.initialTabIndex});
  final Icon icon;
  final String text;
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BottomNavBar(initialTabIndex: initialTabIndex),
        ),
      ),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            Text(
              text,
              style: TextStyle(
                  color: whiteColor, fontSize: 20, fontWeight: FontWeight.w600),
            )
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width * 0.35,
        decoration: BoxDecoration(
            color: blueColor.withOpacity(0.7),
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                  blurRadius: 7,
                  spreadRadius: 4,
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(-4, 4)),
            ]),
      ),
    );
  }
}
