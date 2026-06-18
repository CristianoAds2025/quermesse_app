import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../navigation/app_navigator.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> inicializar() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: android,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("CLIQUE NA NOTIFICAÇÃO LOCAL");
        abrirTelaNotificacoes();
      },
    );
  }

  static Future<void> mostrar({
    required String titulo,
    required String mensagem,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'canal_notificacoes',
      'Notificações',
      channelDescription: 'Notificações da comunidade',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      titulo,
      mensagem,
      details,
      payload: 'abrir_notificacoes',
    );
  }
}