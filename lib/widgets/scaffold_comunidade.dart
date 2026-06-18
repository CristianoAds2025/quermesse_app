import 'package:flutter/material.dart';

import 'rodape_widget.dart';

class ScaffoldComunidade extends StatelessWidget {
  final String titulo;
  final Widget body;

  const ScaffoldComunidade({
    super.key,
    required this.titulo,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EFE2),
      appBar: AppBar(
        title: Text(titulo),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: body,
            ),
            const RodapeWidget(),
          ],
        ),
      ),
    );
  }
}