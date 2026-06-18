import 'package:flutter/material.dart';

import '../../models/notificacao.dart';
import '../../services/notificacao_service.dart';
import '../../widgets/scaffold_comunidade.dart';
import 'notificacao_detalhe_screen.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  bool carregando = true;
  List<Notificacao> notificacoes = [];

  @override
  void initState() {
    super.initState();
    carregarNotificacoes();
  }

  Future<void> carregarNotificacoes() async {
    try {
      final lista =
          await NotificacaoService().listarNotificacoes();

      if (!mounted) return;

      setState(() {
        notificacoes = lista;
        carregando = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erro ao carregar notificações: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldComunidade(
      titulo: "Notificações",
      body: carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : notificacoes.isEmpty
              ? const Center(
                  child: Text("Nenhuma notificação encontrada."),
                )
              : RefreshIndicator(
                  onRefresh: carregarNotificacoes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: notificacoes.length,
                    itemBuilder: (context, index) {
                      final notificacao = notificacoes[index];

                      return Card(
                        color: notificacao.lida
                            ? Colors.white
                            : const Color(0xFFFFF3CD),
                        child: ListTile(
                          leading: Icon(
                            notificacao.lida
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                            color: const Color(0xFF5A2D12),
                          ),
                          title: Text(
                            notificacao.titulo,
                            style: TextStyle(
                              fontWeight: notificacao.lida
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            notificacao.mensagem,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            notificacao.dataEnvio,
                            style: const TextStyle(fontSize: 11),
                          ),
                          onTap: () async {
                            if (!notificacao.lida) {
                              await NotificacaoService().marcarComoLida(
                                notificacao.id,
                              );
                            }

                            if (!mounted) return;

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NotificacaoDetalheScreen(
                                  notificacao: notificacao,
                                ),
                              ),
                            );

                            carregarNotificacoes();
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}