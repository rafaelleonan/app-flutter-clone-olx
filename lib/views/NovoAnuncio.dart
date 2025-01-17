import 'dart:io';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_olx/models/Anuncio.dart';
import 'package:app_olx/util/Configuracoes.dart';
import 'package:app_olx/views/widgets/BotaoCustomizado.dart';
import 'package:app_olx/views/widgets/InputCustomizado.dart';
import 'package:validadores/Validador.dart';

class NovoAnuncio extends StatefulWidget {
  @override
  _NovoAnuncioState createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {

  final List<File> _listaImagens = [];
  late List<DropdownMenuItem<String>> _listaItensDropEstados = [];
  late List<DropdownMenuItem<String>> _listaItensDropCategorias = [];
  final TextEditingController _controllerTitulo = TextEditingController();
  final TextEditingController _controllerPreco = TextEditingController();
  final TextEditingController _controllerTelefone = TextEditingController();
  final TextEditingController _controllerDescricao = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Anuncio _anuncio;
  late BuildContext _dialogContext;

  String? _itemSelecionadoEstado;
  String? _itemSelecionadoCategoria;


  _selecionarImagemGaleria() async {
    final ImagePicker img = ImagePicker();
    XFile? imagemSelecionada;

    imagemSelecionada = await img.pickImage(source: ImageSource.gallery);

    if( imagemSelecionada != null ){
      setState(() {
        _listaImagens.add(File(imagemSelecionada!.path));
      });
    }
  }

  _abrirDialog(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 20,),
              Text("Salvando anúncio...")
            ],),
          );
        }
    );
  }

  _salvarAnuncio() async {
    _abrirDialog( _dialogContext );

    //Upload imagens no Storage
    await _uploadImagens();

    //Salvar anuncio no Firestore
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    String idUsuarioLogado = usuarioLogado!.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("meus_anuncios")
      .doc( idUsuarioLogado )
      .collection("anuncios")
      .doc( _anuncio.id )
      .set( _anuncio.toMap() ).then((_){
        //salvar anúncio público
        db.collection("anuncios")
          .doc( _anuncio.id )
          .set( _anuncio.toMap() ).then((_){
            Navigator.pop(_dialogContext);
            Navigator.pop(context);
        });
    });
  }

  Future _uploadImagens() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();

    for (var imagem in _listaImagens) {
      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      Reference arquivo = pastaRaiz
          .child("meus_anuncios")
          .child(_anuncio.id)
          .child(nomeImagem);

      // Fazendo o upload da imagem
      UploadTask uploadTask = arquivo.putFile(File(imagem.path));
      TaskSnapshot taskSnapshot = await uploadTask;

      // Obtendo a URL de download da imagem
      String url = await taskSnapshot.ref.getDownloadURL();
      _anuncio.fotos.add(url);
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropdown();
    _anuncio = Anuncio.gerarId();
  }

  _carregarItensDropdown(){
    //Categorias
    _listaItensDropCategorias = Configuracoes.getCategorias();

    //Estados
    _listaItensDropEstados = Configuracoes.getEstados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Novo anúncio"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
              FormField<List>(
                initialValue: _listaImagens,
                validator: ( imagens ){
                  if( imagens == null || imagens.isEmpty ){
                    return "Necessário selecionar uma imagem!";
                  }
                  return null;
                },
                builder: (state){
                  return Column(children: <Widget>[
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _listaImagens.length + 1, //3
                          itemBuilder: (context, indice){
                            if( indice == _listaImagens.length ){
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap: (){
                                    _selecionarImagemGaleria();
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey[400],
                                    radius: 50,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: Colors.grey[100],
                                      ),
                                      Text(
                                        "Adicionar",
                                        style: TextStyle(
                                          color: Colors.grey[100]
                                        ),
                                      )
                                    ],),
                                  ),
                                ),
                              );
                            }

                            if( _listaImagens.isNotEmpty ){
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap: (){
                                    showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                            Image.file( _listaImagens[indice] ),
                                            TextButton(
                                              style: const ButtonStyle(
                                                textStyle: WidgetStatePropertyAll(TextStyle(color: Colors.red,))
                                              ),
                                              onPressed: (){
                                                setState(() {
                                                  _listaImagens.removeAt(indice);
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                              child: const Text("Excluir"),
                                            )
                                          ],),
                                        )
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: FileImage( _listaImagens[indice] ),
                                    child: Container(
                                      color: const Color.fromRGBO(255, 255, 255, 0.4),
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.delete, color: Colors.red,),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Container();
                          }
                      ),
                    ),
                    if( state.hasError )
                      SizedBox(
                        child: Text(
                          "[${state.errorText}]",
                          style: const TextStyle(
                            color: Colors.red, fontSize: 14
                          ),
                        ),
                      )
                  ],);
                },
              ),

              Row(children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: DropdownButtonFormField(
                      value: _itemSelecionadoEstado,
                      hint: const Text("Estados"),
                      onSaved: (estado){
                        _anuncio.estado = estado ?? "";
                      },
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20
                      ),
                      items: _listaItensDropEstados,
                      validator: (valor){
                        return Validador()
                            .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                            .valido(valor);
                      },
                      onChanged: (valor){
                        setState(() {
                          _itemSelecionadoEstado = valor;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: DropdownButtonFormField(
                      value: _itemSelecionadoCategoria,
                      hint: const Text("Categorias"),
                      onSaved: (categoria){
                        _anuncio.categoria = categoria ?? "";
                      },
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20
                      ),
                      items: _listaItensDropCategorias,
                      validator: (valor){
                        return Validador()
                            .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                            .valido(valor);
                      },
                      onChanged: (valor){
                        setState(() {
                          _itemSelecionadoCategoria = valor;
                        });
                      },
                    ),
                  ),
                ),
              ],),

              Padding(
                padding: const EdgeInsets.only(bottom: 15, top: 15),
                child: InputCustomizado(
                  hint: "Título",
                  onSaved: (titulo){
                    _anuncio.titulo = titulo ?? "";
                  },
                  validator: (valor){
                    return Validador()
                        .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                        .valido(valor);
                  }, controller: _controllerTitulo,
                ),
              ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    hint: "Preço",
                    onSaved: (preco){
                      _anuncio.preco = preco ?? "";
                    },
                    type: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RealInputFormatter(moeda: true)
                    ],
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                          .valido(valor);
                    }, controller: _controllerPreco,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    hint: "Telefone",
                    onSaved: (telefone){
                      _anuncio.telefone = telefone ?? "";
                    },
                    type: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter()
                    ],
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                          .valido(valor);
                    }, controller: _controllerTelefone,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    hint: "Descrição (200 caracteres)",
                    onSaved: (descricao){
                      _anuncio.descricao = descricao ?? "";
                    },
                    maxLines: 5,
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                          .maxLength(200, msg: "Máximo de 200 caracteres")
                          .valido(valor);
                    }, controller: _controllerDescricao,
                  ),
                ),

              BotaoCustomizado(
                texto: "Cadastrar anúncio",
                onPressed: (){
                  if(_formKey.currentState!.validate()){
                    //salva campos
                    _formKey.currentState!.save();
                    //Configura dialog context
                    _dialogContext = context;
                    //salvar anuncio
                    _salvarAnuncio();
                  }
                },
              ),
            ],),
          ),
        ),
      ),
    );
  }
}
