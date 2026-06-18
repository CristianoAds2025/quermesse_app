import 'package:flutter/material.dart';
import '../produtos/produtos_screen.dart';
import '../vendas/vendas_screen.dart';
import '../fechamento/fechamento_screen.dart';
import '../relatorios/relatorios_screen.dart';
import '../usuarios/usuarios_screen.dart';
import 'dashboard_avancado_screen.dart';
import '../../services/admin_service.dart';
import '../../widgets/scaffold_comunidade.dart';
import '../notificacoes/enviar_notificacao_screen.dart';
import '../home/home_screen.dart';


class DashboardScreen extends StatelessWidget {
  final int usuarioId;
  final String nomeUsuario;
  final String perfil;

  const DashboardScreen({
    super.key,
    required this.usuarioId,
    required this.nomeUsuario,
    required this.perfil,
  });

  Future<void> confirmarResetarQuermesse(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Resetar Quermesse"),
          content: const Text(
            "Deseja realmente resetar a quermesse?\n\n"
            "Todas as vendas serão apagadas e o estoque será restaurado.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("CANCELAR"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("RESETAR"),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      final resposta = await AdminService().resetarQuermesse();

      if (resposta["sucesso"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Quermesse resetada com sucesso"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resposta["erro"] ?? "Erro ao resetar quermesse",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: $e"),
        ),
      );
    }
  }

  Widget botaoDashboard({
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
              size: 32,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: marrom,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
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

    final botoes = <Widget>[
      botaoDashboard(
        icone: Icons.point_of_sale,
        texto: "Vendas",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VendasScreen(
                usuarioId: usuarioId,
              ),
            ),
          );
        },
      ),

      if (administrador)
        botaoDashboard(
          icone: Icons.inventory_2,
          texto: "Produtos",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProdutosScreen(),
              ),
            );
          },
        ),

      if (administrador)
        botaoDashboard(
          icone: Icons.people,
          texto: "Usuários",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UsuariosScreen(),
              ),
            );
          },
        ),

      if (administrador)
        botaoDashboard(
          icone: Icons.receipt_long,
          texto: "Relatório de Vendas",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RelatoriosScreen(),
              ),
            );
          },
        ),

      if (administrador)
        botaoDashboard(
          icone: Icons.bar_chart,
          texto: "Relatório Geral",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DashboardAvancadoScreen(),
              ),
            );
          },
        ),

      if (administrador)
        botaoDashboard(
          icone: Icons.payments,
          texto: "Fechamento de Caixa",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FechamentoScreen(),
              ),
            );
          },
        ),

      if (administrador)
        botaoDashboard(
          icone: Icons.restart_alt,
          texto: "Resetar Quermesse",
          onTap: () {
            confirmarResetarQuermesse(context);
          },
        ),  
    ];

    return ScaffoldComunidade(
      titulo: "Quermesse Online",
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                      fontSize: 24,
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

            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
                children: botoes,
              ),
            ),
          ],
        ),
      ),
    );
  }
}