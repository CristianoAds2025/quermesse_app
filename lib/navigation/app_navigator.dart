import 'package:flutter/material.dart';

import '../screens/notificacoes/notificacoes_screen.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

void abrirTelaNotificacoes({int tentativa = 1}) {
  print("PEDIDO PARA ABRIR TELA DE NOTIFICAÇÕES - tentativa $tentativa");

  final navigator = navigatorKey.currentState;

  if (navigator == null) {
    print("Navigator ainda está NULL");

    if (tentativa <= 10) {
      Future.delayed(
        const Duration(seconds: 1),
        () {
          abrirTelaNotificacoes(tentativa: tentativa + 1);
        },
      );
    }

    return;
  }

  print("ABRINDO TELA DE NOTIFICAÇÕES");

  navigator.push(
    MaterialPageRoute(
      builder: (_) => const NotificacoesScreen(),
    ),
  );
}