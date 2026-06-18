import 'package:flutter/material.dart';

import '../../models/dia_horario.dart';
import '../../services/horario_service.dart';
import '../../widgets/scaffold_comunidade.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  static const Color marrom = Color(0xFF5A2D12);
  static const Color creme = Color(0xFFF7EFE2);

  bool carregando = true;
  List<DiaHorario> dias = [];

  @override
  void initState() {
    super.initState();
    carregarHorarios();
  }

  Future<void> carregarHorarios() async {
    try {
      final lista = await HorarioService().carregarHorarios();

      setState(() {
        dias = lista;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao carregar horários: $e"),
        ),
      );
    }
  }

  Widget tituloDia(String dia) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 18,
        bottom: 8,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: marrom,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        dia,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: marrom,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget linhaHorario({
    required String hora,
    required String local,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: marrom.withOpacity(0.35),
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 35,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: marrom.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(9),
                  bottomLeft: Radius.circular(9),
                ),
              ),
              child: Text(
                hora,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: marrom,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 65,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              child: Text(
                local,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: marrom,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget blocoDia(DiaHorario dia) {
    return Column(
      children: [
        tituloDia(dia.dia),

        ...dia.horarios.map((horario) {
          return linhaHorario(
            hora: horario.hora,
            local: horario.atividade,
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldComunidade(
      titulo: "Horários",

      body: carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              children: [
                const SizedBox(height: 8),

                if (dias.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text("Nenhum horário cadastrado."),
                    ),
                  ),

                ...dias.map((dia) {
                  return blocoDia(dia);
                }),
              ],
            ),
    );
  }
}