import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_olx/main.dart';
import 'package:app_olx/models/Anuncio.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalhesAnuncio extends StatefulWidget {

  Anuncio anuncio;
  DetalhesAnuncio(this.anuncio);

  @override
  _DetalhesAnuncioState createState() => _DetalhesAnuncioState();
}

class _DetalhesAnuncioState extends State<DetalhesAnuncio> {

  late Anuncio _anuncio;

  List<Widget> _getListaImagens(){
    List<String> listaUrlImagens = _anuncio.fotos;
    return listaUrlImagens.map((url){
      return Container(
        height: 250,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.fitWidth
          )
        ),
      );
    }).toList();
  }

  _ligarTelefone(String telefone) async {
    if( await canLaunch("tel:$telefone") ){
      await launch("tel:$telefone");
    }else{
      print("Não pode fazer a ligação");
    }
  }

  @override
  void initState() {
    super.initState();
    _anuncio = widget.anuncio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anúncio"),
      ),
      body: Stack(children: <Widget>[
        ListView(children: <Widget>[
          SizedBox(
            height: 250,
            child: AnotherCarousel(
              images: _getListaImagens(),
              dotSize: 8,
              dotBgColor: Colors.transparent,
              dotColor: Colors.white,
              autoplay: false,
              dotIncreasedColor: temaPadrao.primaryColor,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text(
                "${_anuncio.preco}",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: temaPadrao.primaryColor
                ),
              ),
              Text(
                "${_anuncio.titulo}",
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),
              const Text(
                "Descrição",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                "${_anuncio.descricao}",
                style: const TextStyle(
                    fontSize: 18
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),
              const Text(
                "Contato",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 66),
                child: Text(
                  "${_anuncio.telefone}",
                  style: const TextStyle(
                      fontSize: 18
                  ),
                ),
              ),
            ],),
          )
        ],),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: GestureDetector(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: temaPadrao.primaryColor,
                borderRadius: BorderRadius.circular(30)
              ),
              child: const Text(
                "Ligar",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                ),
              ),
            ),
            onTap: (){
              _ligarTelefone( _anuncio.telefone );
            },
          ),
        )
      ],),
    );
  }
}
