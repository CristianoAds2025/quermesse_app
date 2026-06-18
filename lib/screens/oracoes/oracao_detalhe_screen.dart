import 'package:flutter/material.dart';

import '../../models/oracao.dart';

class OracaoDetalheScreen extends StatelessWidget {
  final Oracao oracao;

  const OracaoDetalheScreen({
    super.key,
    required this.oracao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(oracao.titulo),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Text(
          oracao.texto,
          style: const TextStyle(
            fontSize: 18,
            height: 1.7,
          ),
        ),
      ),
    );
  }
}