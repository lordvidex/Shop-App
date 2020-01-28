import 'package:flutter/material.dart';

class CustomPageRoute<T> extends MaterialPageRoute<T> {
  CustomPageRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if(settings.isInitialRoute){
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
    //return super.buildTransitions(context, animation, secondaryAnimation, child);
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder{
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if(route.settings.isInitialRoute){
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
