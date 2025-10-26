import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class AppRouter{
  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => navigationKey.currentState!;

  void pop<T>([T? result]){
    return _navigator.pop(result);
  }

  Future<T?> push<T>(Widget page, {bool isCupertino = true, bool isMinimal = false}){
    if(isMinimal){
      return _navigator.push<T>(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: Duration(milliseconds: 0),
          reverseTransitionDuration: Duration(milliseconds: 0),
          transitionsBuilder: (_, __, ___, child) => child, // no animation
        ),
      );
    } else if(isCupertino){
      return _navigator.push<T>(
        CupertinoPageRoute(builder: (_) => page),
      );
    }else{
      return _navigator.push<T>(
        MaterialPageRoute(builder: (_) => page),
      );
    }
  }

  Future<T?> pushReplacement<T>(Widget page){
    return _navigator.pushReplacement<T, dynamic>(
        CupertinoPageRoute(builder: (_) => page)
    );
  }

  Future<T?> pushAndRemoveUntil<T>(Widget page){
    return _navigator.pushAndRemoveUntil<T>(
      CupertinoPageRoute(builder: (_) => page),
        (route) => false,
    );
  }

  Future<T?> pushNamed<T>(String routeName, {Object? arguments}){
    return _navigator.pushNamed<T>(
      routeName,
      arguments: arguments
    );
  }
}