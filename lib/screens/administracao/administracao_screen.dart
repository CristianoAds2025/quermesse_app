import 'package:flutter/material.dart';

import '../../widgets/scaffold_comunidade.dart';
import '../dashboard/dashboard_screen.dart';
import '../notificacoes/enviar_notificacao_screen.dart';
import '../home/home_screen.dart';

class AdministracaoScreen extends StatelessWidget {
  final int usuarioId;
  final String nomeUsuario;
  final String perfil;

  const AdministracaoScreen({
    super.key,
    required this.usuarioId,
    required this.nomeUsuario,
    required this.perfil,
  });

  Widget botaoAdmin({
    required IconData icone,
    required String texto,
    required VoidCallback onTap,
  }) {
    const Color marrom = Color(0xFF5A2D12);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: marrom.withOpacity(0.65),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 5,
              offset: const Offset(1, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              color: marrom,
              size: 38,
            ),
            const SizedBox(height: 10),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: marrom,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool administrador = perfil == "administrador";

    return ScaffoldComunidade(
      titulo: "Administração",
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Expanded(
                  child: Text(
                    "Olá, $nomeUsuario",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                IconButton(
                  tooltip: "Sair",
                  icon: const Icon(
                    Icons.logout,
                    color: Color(0xFF5A2D12),
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.05,
                children: [
                  botaoAdmin(
                    icone: Icons.storefront,
                    texto: "Quermesse",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DashboardScreen(
                            usuarioId: usuarioId,
                            nomeUsuario: nomeUsuario,
                            perfil: perfil,
                          ),
                        ),
                      );
                    },
                  ),

                  if (administrador)
                    botaoAdmin(
                      icone: Icons.notifications_active,
                      texto: "Enviar Notificações",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const EnviarNotificacaoScreen(),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}