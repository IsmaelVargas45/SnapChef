import 'package:flutter/material.dart';

import '../pages/historial_page.dart';

import '../pages/welcome_page.dart';
import '../pages/home_page.dart';


Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    "/": (BuildContext context) => const WelcomePage(),
    "/home": (BuildContext context) => const MyHomePage(),
    
    "/historial":(BuildContext context )=> const HistorialPage(),
    
  };
}
