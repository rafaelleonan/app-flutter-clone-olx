import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_olx/models/Anuncio.dart';
import 'package:app_olx/views/widgets/ItemAnuncio.dart';

class MeusAnuncios extends StatefulWidget {
  @override
  _MeusAnunciosState createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {
  
  final _controller = StreamController<QuerySnapshot>.broadcast();
  String? _idUsuarioLogado;

  _recuperaDadosUsuarioLogado() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    _idUsuarioLogado = usuarioLogado!.uid;
  }
  
  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {
    await _recuperaDadosUsuarioLogado();

    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_anuncios")
        .doc( _idUsuarioLogado )
        .collection("anuncios")
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
    });

    return stream;
  }

  _removerAnuncio(String idAnuncio){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("meus_anuncios")
      .doc( _idUsuarioLogado )
      .collection("anuncios")
      .doc( idAnuncio )
      .delete().then((_){
        db.collection("anuncios")
        .doc(idAnuncio)
        .delete();
    });
  }
  
  @override
  void initState() {
    super.initState();
    _adicionarListenerAnuncios();
  }
  
  @override
  Widget build(BuildContext context) {
    
    var carregandoDados = const Center(
      child: Column(children: <Widget>[
        Text("Carregando anúncios"),
        CircularProgressIndicator()
      ],),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Anúncios"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Adicionar"),
        //child: Icon(Icons.add),
        onPressed: (){
          Navigator.pushNamed(context, "/novo-anuncio");
        },
      ),
      body: StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot){
          switch( snapshot.connectionState ){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return carregandoDados;
            case ConnectionState.active:
            case ConnectionState.done:
              
              //Exibe mensagem de erro
              if(snapshot.hasError) {
                return const Text("Erro ao carregar os dados!");
              }
              
              QuerySnapshot? querySnapshot = snapshot.data;

              if(querySnapshot == null) {
                return const Text("Nenhum anúncio disponível!");
              }

              return ListView.builder(
                  itemCount: querySnapshot.docs.length,
                  itemBuilder: (_, indice){
                    
                    List<DocumentSnapshot> anuncios = querySnapshot.docs.toList();
                    DocumentSnapshot documentSnapshot = anuncios[indice];
                    Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);
                    
                    return ItemAnuncio(
                      anuncio: anuncio,
                      onPressedRemover: (){
                        showDialog(
                            context: context,
                          builder: (context){
                              return AlertDialog(
                                title: Text("Confirmar"),
                                content: Text("Deseja realmente excluir o anúncio?"),
                                actions: <Widget>[

                                  TextButton(
                                    child: const Text(
                                        "Cancelar",
                                      style: TextStyle(
                                          color: Colors.grey
                                      ),
                                    ),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  ),

                                  TextButton(
                                    style: const ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(Colors.red),
                                    ),
                                    child: const Text(
                                      "Remover",
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                    onPressed: (){
                                      _removerAnuncio( anuncio.id );
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                          }
                        );
                      },
                    );
                  }
              );
              
          }
        },
      ),
    );
  }
}
