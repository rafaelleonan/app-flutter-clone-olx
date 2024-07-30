import 'package:app_olx/routes.dart';
import 'package:app_olx/views/Anuncios.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final ThemeData temaPadrao = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color(0xff9c27b0),
    secondary: const Color(0xff7b1fa2),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    title: "OLX",
    home: Anuncios(),
    theme: temaPadrao,
    initialRoute: "/",
    onGenerateRoute: Routes.generateRoute,
    debugShowCheckedModeBanner: false,
  ));
}
