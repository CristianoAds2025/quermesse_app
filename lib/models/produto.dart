class Produto {
  final int id;
  final String descricao;
  final double valor;
  final int estoqueAtual;
  final int estoqueInicial;
  final bool imprimirCupom;

  Produto({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.estoqueAtual,
    required this.estoqueInicial,
    required this.imprimirCupom,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json["id"],
      descricao: json["descricao"],
      valor: double.parse(json["valor"].toString()),
      estoqueAtual: json["estoque_atual"] ?? 0,
      estoqueInicial: json["estoque_inicial"] ?? 0,
      imprimirCupom: json["imprimir_cupom"] ?? false,
    );
  }
}