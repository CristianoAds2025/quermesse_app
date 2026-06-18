import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../login/login_screen.dart';
import '../oracoes/oracoes_screen.dart';
import '../horarios/horarios_screen.dart';
import '../dizimo/dizimo_screen.dart';
import '../notificacoes/notificacoes_screen.dart';
import '../../services/notificacao_service.dart';
import '../../services/firebase_push_service.dart';
import '../../navigation/app_navigator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  static const Color marrom = Color(0xFF5A2D12);
  static const Color creme = Color(0xFFF7EFE2);

  int quantidadeNotificacoes = 0;

  @override
    void initState() {
      super.initState();

      carregarQuantidadeNotificacoes();
      FirebasePushService().inicializar();
    }

  Future<void> carregarQuantidadeNotificacoes() async {
    try {
      final lista = await NotificacaoService().listarNotificacoes();

      setState(() {
        quantidadeNotificacoes =
            lista.where((notificacao) => notificacao.lida == false).length;
      });
    } catch (e) {
      setState(() {
        quantidadeNotificacoes = 0;
      });
    }
  }

  Widget botaoHome({
    required Widget icone,
    required String texto,
    required VoidCallback onTap,
  }) {
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
            icone,
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: marrom,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void abrirPaginaEmBreve(BuildContext context, String titulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$titulo em breve"),
      ),
    );
  }

  Future<void> abrirInstagram() async {
    final url = Uri.parse(
      "https://instagram.com/comsaofranciscomedici",
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> abrirFacebook() async {
    final url = Uri.parse(
      "https://facebook.com/comunidadesaofranciscomedici",
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> abrirWhatsapp() async {
    final url = Uri.parse(
      "https://wa.me/5569992523654",
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final botoes = [
      botaoHome(
        icone: const FaIcon(
          FontAwesomeIcons.userTie,
          color: marrom,
          size: 30,
        ),
        texto: "GESTÃO",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        },
      ),
      botaoHome(
        icone: const Icon(
          Icons.groups,
          color: marrom,
          size: 32,
        ),
        texto: "A COMUNIDADE",
        onTap: () {
          abrirPaginaEmBreve(context, "A Comunidade");
        },
      ),

      botaoHome(
        icone: const Icon(
          Icons.article,
          color: marrom,
          size: 32,
        ),
        texto: "NOTÍCIAS",
        onTap: () {
          abrirPaginaEmBreve(context, "Notícias");
        },
      ),

      botaoHome(
        icone: const Icon(
          Icons.menu_book,
          color: marrom,
          size: 32,
        ),
        texto: "LITURGIA DIÁRIA",
        onTap: () {
          abrirPaginaEmBreve(context, "Liturgia Diária");
        },
      ),

      botaoHome(
        icone: const Icon(
          Icons.person,
          color: marrom,
          size: 32,
        ),
        texto: "SANTO DO DIA",
        onTap: () {
          abrirPaginaEmBreve(context, "Santo do Dia");
        },
      ),

      botaoHome(
        icone: const FaIcon(
          FontAwesomeIcons.personPraying,
          color: marrom,
          size: 30,
        ),
        texto: "ORAÇÕES",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OracoesScreen(),
            ),
          );
        },
      ),

      botaoHome(
        icone: const Icon(
          Icons.volunteer_activism,
          color: marrom,
          size: 32,
        ),
        texto: "DÍZIMO E OFERTA",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DizimoScreen(),
            ),
          );
        },
      ),

      botaoHome(
        icone: const Icon(
          Icons.access_time,
          color: marrom,
          size: 32,
        ),
        texto: "HORÁRIOS",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HorariosScreen(),
            ),
          );
        },
      ),

      botaoHome(
        icone: const Icon(
          Icons.school,
          color: marrom,
          size: 32,
        ),
        texto: "FORMAÇÃO",
        onTap: () {
          abrirPaginaEmBreve(context, "Formação");
        },
      ),

      botaoHome(
        icone: const Icon(
          Icons.diversity_3,
          color: marrom,
          size: 32,
        ),
        texto: "PEDIDO DE ORAÇÃO",
        onTap: () {
          abrirPaginaEmBreve(context, "Pedido de Oração");
        },
      ),
    ];

    return Scaffold(
      backgroundColor: creme,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 85,
              width: double.infinity,
              color: marrom,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  const Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 30,
                  ),

                  const SizedBox(width: 12),

                  Image.asset(
                    "assets/images/logo_igreja.png",
                    height: 55,
                    width: 55,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "COMUNIDADE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          "SÃO FRANCISCO DE ASSIS",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificacoesScreen(),
                        ),
                      );

                      if (!mounted) return;

                      carregarQuantidadeNotificacoes();
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 34,
                        ),

                        if (quantidadeNotificacoes > 0)
                          Positioned(
                            right: -6,
                            top: -8,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                quantidadeNotificacoes.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.90,
                      children: botoes,
                    ),
                  ),                 
                ],
              ),
            ),

            Container(
              height: 50,
              width: double.infinity,
              color: marrom,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  IconButton(
                    onPressed: () {
                      // Já está na Home
                    },
                    icon: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  IconButton(
                    onPressed: abrirInstagram,
                    icon: const FaIcon(
                      FontAwesomeIcons.instagram,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),

                  IconButton(
                    onPressed: abrirFacebook,
                    icon: const FaIcon(
                      FontAwesomeIcons.facebook,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),

                  IconButton(
                    onPressed: abrirWhatsapp,
                    icon: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}