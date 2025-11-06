import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class AppRouter{
  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();
  NavigatorState get _navigator => navigationKey.currentState!;

  // ------------------ WITHOUT CONTEXT ------------------

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

  // ------------------ WITH CONTEXT ------------------

  void popWithContext<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }

  Future<T?> pushWithContext<T>(
      BuildContext context,
      Widget page, {
        bool isCupertino = true,
        bool isMinimal = false,
      }) {
    if (isMinimal) {
      return Navigator.of(context).push<T>(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (_, __, ___, child) => child,
        ),
      );
    } else if (isCupertino) {
      return Navigator.of(context).push<T>(
        CupertinoPageRoute(builder: (_) => page),
      );
    } else {
      return Navigator.of(context).push<T>(
        MaterialPageRoute(builder: (_) => page),
      );
    }
  }

  Future<T?> pushReplacementWithContext<T>(
      BuildContext context,
      Widget page,
      ) {
    return Navigator.of(context).pushReplacement<T, dynamic>(
      CupertinoPageRoute(builder: (_) => page),
    );
  }

  Future<T?> pushAndRemoveUntilWithContext<T>(
      BuildContext context,
      Widget page,
      ) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      CupertinoPageRoute(builder: (_) => page),
          (route) => false,
    );
  }

  Future<T?> pushNamedWithContext<T>(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }
}