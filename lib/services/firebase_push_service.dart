import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'package:quermesse_app/navigation/app_navigator.dart';
import 'package:quermesse_app/services/local_notification_service.dart';

class FirebasePushService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final String baseUrl = "https://quermesse-app.onrender.com";

  Future<String?> inicializar() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();

    print("=========================");
    print("TOKEN FIREBASE:");
    print(token);
    print("=========================");

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        final titulo =
            message.notification?.title ?? "Nova notificação";

        final corpo =
            message.notification?.body ?? "";

        LocalNotificationService.mostrar(
          titulo: titulo,
          mensagem: corpo,
        );
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        print("NOTIFICAÇÃO CLICADA COM APP EM SEGUNDO PLANO");
        abrirTelaNotificacoes();
      },
    );

    final mensagemInicial =
        await FirebaseMessaging.instance.getInitialMessage();

    if (mensagemInicial != null) {
      print("APP ABERTO PELA NOTIFICAÇÃO");
      abrirTelaNotificacoes();
    }

    if (token != null) {
      await salvarTokenNoServidor(token);
    }

    return token;
  }

  Future<void> salvarTokenNoServidor(String token) async {
    final url = Uri.parse("$baseUrl/api/tokens_push");

    final resposta = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        "token": token,
        "plataforma": "android",
      }),
    );

    print("RESPOSTA SALVAR TOKEN:");
    print(resposta.body);
  }
}