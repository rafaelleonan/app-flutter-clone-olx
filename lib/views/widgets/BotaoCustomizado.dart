import 'package:flutter/material.dart';

class BotaoCustomizado extends StatelessWidget {

  final String texto;
  final Color corTexto;
  final VoidCallback? onPressed;

  BotaoCustomizado({
    required this.texto,
    this.corTexto = Colors.white,
    this.onPressed
});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6)
        )),
        backgroundColor: const WidgetStatePropertyAll(Color(0xff9c27b0)),
        padding: const WidgetStatePropertyAll(EdgeInsets.fromLTRB(32, 16, 32, 16)),
      ),
      onPressed: onPressed,
      child: Text(
        texto,
        style: TextStyle(
            color: corTexto, fontSize: 20
        ),
      ),
    );
  }
}
