import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/home/home_screen.dart';

class RodapeWidget extends StatelessWidget {
  const RodapeWidget({super.key});

  Future<void> abrirLink(String link) async {
    final url = Uri.parse(link);

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: const Color(0xFF5A2D12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.home,
              color: Colors.white,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              abrirLink("https://instagram.com/comsaofranciscomedici");
            },
            icon: const FaIcon(
              FontAwesomeIcons.instagram,
              color: Colors.white,
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () {
              abrirLink("https://facebook.com/comunidadesaofranciscomedici");
            },
            icon: const FaIcon(
              FontAwesomeIcons.facebook,
              color: Colors.white,
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () {
              abrirLink("https://wa.me/5569992523654");
            },
            icon: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}