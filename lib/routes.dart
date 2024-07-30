
import 'package:app_olx/models/Anuncio.dart';
import 'package:flutter/material.dart';
import 'package:app_olx/views/Anuncios.dart';
import 'package:app_olx/views/DetalhesAnuncio.dart';
import 'package:app_olx/views/Login.dart';
import 'package:app_olx/views/MeusAnuncios.dart';
import 'package:app_olx/views/NovoAnuncio.dart';

class Routes {

  static Route<dynamic> generateRoute(RouteSettings settings){

    final args = settings.arguments;

    switch( settings.name ){
      case "/" :
        return MaterialPageRoute(
          builder: (_) => Anuncios()
        );
      case "/login" :
        return MaterialPageRoute(
            builder: (_) => Login()
        );
      case "/meus-anuncios" :
        return MaterialPageRoute(
            builder: (_) => MeusAnuncios()
        );
      case "/novo-anuncio" :
        return MaterialPageRoute(
            builder: (_) => NovoAnuncio()
        );
      case "/detalhes-anuncio" :
        Anuncio arg = args as Anuncio;
        return MaterialPageRoute(
            builder: (_) => DetalhesAnuncio(arg)
        );
      default:
        return _erroRota();
    }

  }

  static Route<dynamic> _erroRota(){

    return MaterialPageRoute(
      builder: (_){
        return Scaffold(
          appBar: AppBar(
            title: const Text("Tela não encontrada!"),
          ),
          body: const Center(
            child: Text("Tela não encontrada!"),
          ),
        );
      }
    );

  }

}