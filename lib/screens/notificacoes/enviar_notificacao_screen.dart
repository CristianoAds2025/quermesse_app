import 'package:flutter/material.dart';

import '../../services/notificacao_service.dart';
import '../../widgets/scaffold_comunidade.dart';

class EnviarNotificacaoScreen extends StatefulWidget {
  const EnviarNotificacaoScreen({super.key});

  @override
  State<EnviarNotificacaoScreen> createState() =>
      _EnviarNotificacaoScreenState();
}

class _EnviarNotificacaoScreenState extends State<EnviarNotificacaoScreen> {
  final tituloController = TextEditingController();
  final mensagemController = TextEditingController();

  bool enviando = false;

  Future<void> enviar() async {
    final titulo = tituloController.text.trim();
    final mensagem = mensagemController.text.trim();

    if (titulo.isEmpty || mensagem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha o título e a mensagem"),
        ),
      );
      return;
    }

    setState(() {
      enviando = true;
    });

    try {
      final resposta = await NotificacaoService().enviarNotificacao(
        titulo: titulo,
        mensagem: mensagem,
      );

      if (!mounted) return;

      setState(() {
        enviando = false;
      });

      if (resposta["sucesso"] == true) {
        tituloController.clear();
        mensagemController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Notificação enviada com sucesso"),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resposta["erro"] ?? "Erro ao enviar notificação",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        enviando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldComunidade(
      titulo: "Enviar Notificação",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Use esta tela para enviar avisos à comunidade.",
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: "Título",
                prefixIcon: Icon(Icons.title),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: mensagemController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: "Mensagem",
                prefixIcon: Icon(Icons.message),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: enviando ? null : enviar,
              icon: const Icon(
                Icons.send,
                size: 18,
              ),
              label: Text(
                enviando ? "ENVIANDO..." : "ENVIAR NOTIFICAÇÃO",
              ),
            ),
          ],
        ),
      ),
    );
  }
}