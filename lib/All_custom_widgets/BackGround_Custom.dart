import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Colors/App_Colors.dart';

class CustomScaffoldForLogin extends StatelessWidget {
  final double height;
  final double width;

  const CustomScaffoldForLogin({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: ColorConst.verticalGradient, // Fixed gradient
      ),
      child: Align(
          alignment: Alignment.bottomCenter,
      ),);
  }
}

class CustomGradientContaienrtwo extends StatelessWidget {
  final double height;
  final double width;
  const CustomGradientContaienrtwo({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: ColorConst.horizontalGradient, // Fixed gradient
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
      ),
    );
  }
}
