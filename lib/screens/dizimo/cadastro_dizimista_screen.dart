import 'package:flutter/material.dart';

import '../../widgets/scaffold_comunidade.dart';
import '../../services/dizimista_service.dart';

class CadastroDizimistaScreen extends StatefulWidget {
  const CadastroDizimistaScreen({super.key});

  @override
  State<CadastroDizimistaScreen> createState() =>
      _CadastroDizimistaScreenState();
}

class _CadastroDizimistaScreenState extends State<CadastroDizimistaScreen> {
  final formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final nascimentoController = TextEditingController();
  final whatsappController = TextEditingController();

  final nomeConjugeController = TextEditingController();
  final nascimentoConjugeController = TextEditingController();

  final ruaController = TextEditingController();
  final numeroController = TextEditingController();
  final cpfController = TextEditingController();

  bool enviando = false;

  bool? casado;

  static const Color marrom = Color(0xFF5A2D12);

  Future<void> selecionarData(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (data != null) {
      controller.text =
          "${data.day.toString().padLeft(2, '0')}/"
          "${data.month.toString().padLeft(2, '0')}/"
          "${data.year}";
    }
  }

  String? validarObrigatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return "Campo obrigatório";
    }
    return null;
  }

  Future<void> enviarCadastro() async {
    if (casado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Informe se é casado ou não"),
        ),
      );
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      enviando = true;
    });

    try {
      final resposta = await DizimistaService().cadastrarDizimista(
        cpf: cpfController.text.trim(),
        nome: nomeController.text.trim(),
        email: emailController.text.trim(),
        dataNascimento: nascimentoController.text.trim(),
        whatsapp: whatsappController.text.trim(),
        casado: casado!,
        nomeConjuge: nomeConjugeController.text.trim(),
        dataNascimentoConjuge: nascimentoConjugeController.text.trim(),
        ruaAvenida: ruaController.text.trim(),
        numero: numeroController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        enviando = false;
      });

      if (resposta["sucesso"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cadastro enviado com sucesso"),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resposta["erro"] ?? "Erro ao enviar cadastro",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        enviando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: $e"),
        ),
      );
    }
  }

  Widget campoTexto({
    required String label,
    required TextEditingController controller,
    bool obrigatorio = false,
    TextInputType teclado = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: teclado,
        validator: obrigatorio ? validarObrigatorio : null,
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }

  Widget campoCpf() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: cpfController,
        keyboardType: TextInputType.number,
        maxLength: 11,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "CPF obrigatório";
          }

          if (value.length != 11) {
            return "Informe os 11 números do CPF";
          }

          return null;
        },
        decoration: const InputDecoration(
          labelText: "CPF",
          counterText: "",
        ),
      ),
    );
  }

  Widget campoData({
    required String label,
    required TextEditingController controller,
    bool obrigatorio = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        validator: obrigatorio ? validarObrigatorio : null,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month),
        ),
        onTap: () {
          selecionarData(context, controller);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldComunidade(
      titulo: "Cadastro de Dizimista",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Preencha os dados abaixo para realizar seu cadastro como dizimista.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              campoTexto(
                label: "Nome",
                controller: nomeController,
                obrigatorio: true,
              ),

              campoCpf(),

              campoTexto(
                label: "E-mail",
                controller: emailController,
                teclado: TextInputType.emailAddress,
              ),

              campoData(
                label: "Data de nascimento",
                controller: nascimentoController,
                obrigatorio: true,
              ),

              campoTexto(
                label: "WhatsApp",
                controller: whatsappController,
                obrigatorio: true,
                teclado: TextInputType.phone,
              ),

              const SizedBox(height: 8),

              const Text(
                "Casado?",
                style: TextStyle(
                  color: marrom,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text("Sim"),
                      value: true,
                      groupValue: casado,
                      onChanged: (valor) {
                        setState(() {
                          casado = valor;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text("Não"),
                      value: false,
                      groupValue: casado,
                      onChanged: (valor) {
                        setState(() {
                          casado = valor;
                          nomeConjugeController.clear();
                          nascimentoConjugeController.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),

              if (casado == true) ...[
                campoTexto(
                  label: "Nome do cônjuge",
                  controller: nomeConjugeController,
                  obrigatorio: true,
                ),

                campoData(
                  label: "Data de nascimento do cônjuge",
                  controller: nascimentoConjugeController,
                  obrigatorio: true,
                ),
              ],

              const SizedBox(height: 8),

              campoTexto(
                label: "Rua/Avenida",
                controller: ruaController,
                obrigatorio: true,
              ),

              campoTexto(
                label: "Número",
                controller: numeroController,
                obrigatorio: true,
                teclado: TextInputType.number,
              ),

              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: enviando ? null : enviarCadastro,
                icon: const Icon(Icons.send, size: 18),
                label: Text(enviando ? "ENVIANDO..." : "ENVIAR"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}