import 'package:flutter/material.dart';

import '../../models/usuario.dart';
import '../../services/usuario_service.dart';
import 'usuario_form_screen.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  late Future<List<Usuario>> usuariosFuture;

  @override
  void initState() {
    super.initState();
    usuariosFuture = UsuarioService().listarUsuarios();
  }

  Future<void> carregarUsuarios() async {
    setState(() {
      usuariosFuture = UsuarioService().listarUsuarios();
    });
  }

  Future<void> abrirFormulario({Usuario? usuario}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UsuarioFormScreen(
          usuario: usuario,
        ),
      ),
    );

    if (resultado == true) {
      carregarUsuarios();
    }
  }

  Future<void> confirmarExclusao(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Excluir usuário"),
          content: Text(
            "Deseja realmente excluir ${usuario.nomeUsuario}?",
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
              child: const Text("EXCLUIR"),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      final resposta = await UsuarioService().excluirUsuario(usuario.id);

      if (resposta["sucesso"] == true) {
        carregarUsuarios();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Usuário excluído com sucesso"),
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resposta["erro"] ?? "Erro ao excluir usuário"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuários"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          abrirFormulario();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Usuario>>(
        future: usuariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Erro: ${snapshot.error}"),
            );
          }

          final usuarios = snapshot.data ?? [];

          if (usuarios.isEmpty) {
            return const Center(
              child: Text("Nenhum usuário cadastrado"),
            );
          }

          return RefreshIndicator(
            onRefresh: carregarUsuarios,
            child: ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      usuario.nomeUsuario,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Usuário: ${usuario.usuario}\n"
                      "Perfil: ${usuario.perfil}",
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (opcao) {
                        if (opcao == "editar") {
                          abrirFormulario(usuario: usuario);
                        }

                        if (opcao == "excluir") {
                          confirmarExclusao(usuario);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: "editar",
                          child: Text("Editar"),
                        ),
                        PopupMenuItem(
                          value: "excluir",
                          child: Text("Excluir"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}