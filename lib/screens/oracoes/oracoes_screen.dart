import 'package:flutter/material.dart';

import '../../models/oracao.dart';
import '../../services/oracao_service.dart';
import 'oracao_detalhe_screen.dart';
import '../../widgets/scaffold_comunidade.dart';

class OracoesScreen extends StatefulWidget {
  const OracoesScreen({super.key});

  @override
  State<OracoesScreen> createState() => _OracoesScreenState();
}

class _OracoesScreenState extends State<OracoesScreen> {
  String categoriaSelecionada = "Todas";
  final buscaController = TextEditingController();

  bool carregando = true;
  List<Oracao> oracoes = [];

  final List<String> categorias = [
    "Todas",
    "Oração",
    "Ladainha",
    "Jaculatória",
    "Novena",
  ];

  @override
  void initState() {
    super.initState();
    carregarOracoes();
  }

  Future<void> carregarOracoes() async {
    try {
      final lista = await OracaoService().carregarOracoes();

      setState(() {
        oracoes = lista;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao carregar orações: $e"),
        ),
      );
    }
  }

  List<Oracao> get oracoesFiltradas {
    final busca = buscaController.text.toLowerCase();

    return oracoes.where((oracao) {
      final correspondeCategoria =
          categoriaSelecionada == "Todas" ||
          oracao.categoria == categoriaSelecionada;

      final correspondeBusca =
          oracao.titulo.toLowerCase().contains(busca) ||
          oracao.texto.toLowerCase().contains(busca);

      return correspondeCategoria && correspondeBusca;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lista = oracoesFiltradas;

    return ScaffoldComunidade(
      titulo: "Orações",
      body: carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: buscaController,
                    decoration: const InputDecoration(
                      labelText: "Buscar oração",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),

                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: categorias.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final categoria = categorias[index];
                      final selecionada = categoria == categoriaSelecionada;

                      return ChoiceChip(
                        label: Text(categoria),
                        selected: selecionada,
                        onSelected: (_) {
                          setState(() {
                            categoriaSelecionada = categoria;
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: lista.isEmpty
                      ? const Center(
                          child: Text("Nenhuma oração encontrada."),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: lista.length,
                          itemBuilder: (context, index) {
                            final oracao = lista[index];

                            return Card(
                              child: ListTile(
                                title: Text(
                                  oracao.titulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(oracao.categoria),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OracaoDetalheScreen(
                                        oracao: oracao,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}