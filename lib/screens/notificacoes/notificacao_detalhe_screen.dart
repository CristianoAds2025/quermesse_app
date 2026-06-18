import 'package:flutter/material.dart';

import '../../models/notificacao.dart';
import '../../widgets/scaffold_comunidade.dart';

class NotificacaoDetalheScreen extends StatelessWidget {
  final Notificacao notificacao;

  const NotificacaoDetalheScreen({
    super.key,
    required this.notificacao,
  });

  @override
  Widget build(BuildContext context) {
    return ScaffoldComunidade(
      titulo: "Notificação",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notificacao.titulo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A2D12),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  notificacao.dataEnvio,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),

                const Divider(height: 28),

                Text(
                  notificacao.mensagem,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}