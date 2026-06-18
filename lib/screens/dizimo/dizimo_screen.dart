import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'cadastro_dizimista_screen.dart';

import '../../widgets/scaffold_comunidade.dart';

class DizimoScreen extends StatelessWidget {
  const DizimoScreen({super.key});

  static const Color marrom = Color(0xFF5A2D12);

  final String chavePix = "comsaofrancisco@paroquiasjb.org.br";
  final String whatsapp = "5569992523654";

  Future<void> copiarPix(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: chavePix),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Chave PIX copiada com sucesso"),
      ),
    );
  }

  Future<void> abrirWhatsapp() async {
    final mensagem = Uri.encodeComponent(
      "Olá! Gostaria de enviar o comprovante do dízimo/oferta.",
    );

    final url = Uri.parse(
      "https://wa.me/$whatsapp?text=$mensagem",
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  void mostrarQrCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Center(
            child: Text(
              "PIX da Comunidade",
              textAlign: TextAlign.center,
            ),
          ),
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: QrImageView(
                    data: chavePix,
                  ),
                ),

                const SizedBox(height: 12),

                SelectableText(
                  chavePix,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("FECHAR"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldComunidade(
      titulo: "Dízimo e Oferta",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),

            Center(
              child: Image.asset(
                'assets/images/logo_dizimo.png',
                height: 120,
                fit: BoxFit.contain,
              ),
            ),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "O dízimo e oferta são gestos de gratidão, fé e compromisso com a missão evangelizadora da Igreja.\n\n"
                  "Sua contribuição ajuda na manutenção da comunidade, nas celebrações, pastorais, obras sociais e ações missionárias.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CadastroDizimistaScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.person_add,
                size: 18,
              ),
              label: const Text("QUERO SER DIZIMISTA"),
            ),

            const SizedBox(height: 18),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Text(
                      "Chave PIX",
                      style: TextStyle(
                        color: marrom,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      chavePix,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: () {
                        copiarPix(context);
                      },
                      icon: const Icon(
                        Icons.copy,
                        size: 18,
                      ),
                      label: const Text("COPIAR CHAVE PIX"),
                    ),
                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: () {
                        mostrarQrCode(context);
                      },
                      icon: const Icon(
                        Icons.qr_code,
                        size: 18,
                      ),
                      label: const Text(
                        "GERAR QR CODE PIX",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: abrirWhatsapp,
              icon: const Icon(
                Icons.chat,
                size: 18,
              ),
              label: const Text("ENVIAR COMPROVANTE"),
            ),

            const SizedBox(height: 24),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "“Deus ama quem dá com alegria.”\n2Cor 9,7",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: marrom,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}