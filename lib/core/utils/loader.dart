import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget loader({Color? color}) {
  return Center(
    child: Lottie.asset(
      'assets/lottie/loading.json',
      width: 190,
      height: 190,
      fit: BoxFit.contain,
      repeat: true,
    ),
  );
}