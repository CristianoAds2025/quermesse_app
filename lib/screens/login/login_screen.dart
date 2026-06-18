import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/scaffold_comunidade.dart';
import '../administracao/administracao_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usuarioController = TextEditingController();
  final senhaController = TextEditingController();

  bool carregando = false;

  Future<void> fazerLogin() async {
    final usuario = usuarioController.text.trim();
    final senha = senhaController.text.trim();

    if (usuario.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Informe usuário e senha"),
        ),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final resposta = await AuthService().login(usuario, senha);

      if (resposta["sucesso"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdministracaoScreen(
              usuarioId: resposta["usuario_id"],
              nomeUsuario: resposta["nome_usuario"],
              perfil: resposta["perfil"],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resposta["mensagem"] ?? "Login inválido",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao conectar: $e"),
        ),
      );
    }

    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldComunidade(
    titulo: "Login",
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usuarioController,
              decoration: const InputDecoration(
                labelText: "Usuário",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Senha",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: carregando ? null : fazerLogin,
                child: carregando
                    ? const CircularProgressIndicator()
                    : const Text("Entrar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}