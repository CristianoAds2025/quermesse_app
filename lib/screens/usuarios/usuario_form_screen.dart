import 'package:flutter/material.dart';

import '../../models/usuario.dart';
import '../../services/usuario_service.dart';

class UsuarioFormScreen extends StatefulWidget {
  final Usuario? usuario;

  const UsuarioFormScreen({
    super.key,
    this.usuario,
  });

  @override
  State<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final nomeController = TextEditingController();
  final usuarioController = TextEditingController();
  final senhaController = TextEditingController();

  String perfil = "usuario";
  bool salvando = false;

  bool get editando => widget.usuario != null;

  @override
  void initState() {
    super.initState();

    if (editando) {
      nomeController.text = widget.usuario!.nomeUsuario;
      usuarioController.text = widget.usuario!.usuario;
      perfil = widget.usuario!.perfil;
    }
  }

  Future<void> salvar() async {
    final nome = nomeController.text.trim();
    final usuario = usuarioController.text.trim();
    final senha = senhaController.text.trim();

    if (nome.isEmpty || usuario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha nome e usuário"),
        ),
      );
      return;
    }

    if (!editando && senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Informe a senha"),
        ),
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      Map<String, dynamic> resposta;

      if (editando) {
        resposta = await UsuarioService().editarUsuario(
          id: widget.usuario!.id,
          nomeUsuario: nome,
          usuario: usuario,
          senha: senha,
          perfil: perfil,
        );
      } else {
        resposta = await UsuarioService().cadastrarUsuario(
          nomeUsuario: nome,
          usuario: usuario,
          senha: senha,
          perfil: perfil,
        );
      }

      if (resposta["sucesso"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              editando
                  ? "Alteração salva com sucesso"
                  : "Usuário cadastrado com sucesso",
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resposta["erro"] ?? "Erro ao salvar usuário"),
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

    setState(() {
      salvando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? "Editar Usuário" : "Novo Usuário"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(
              labelText: "Nome",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: usuarioController,
            decoration: const InputDecoration(
              labelText: "Usuário",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: senhaController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: editando
                  ? "Nova senha (deixe em branco para manter)"
                  : "Senha",
              border: const OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: perfil,
            decoration: const InputDecoration(
              labelText: "Perfil",
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: "administrador",
                child: Text("Administrador"),
              ),
              DropdownMenuItem(
                value: "usuario",
                child: Text("Usuário"),
              ),
            ],
            onChanged: (valor) {
              setState(() {
                perfil = valor!;
              });
            },
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: salvando ? null : salvar,
            child: salvando
                ? const CircularProgressIndicator()
                : Text(editando ? "SALVAR ALTERAÇÕES" : "CADASTRAR"),
          ),
        ],
      ),
    );
  }
}