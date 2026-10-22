export interface Movimento {
  mes: number;
  ano: number;
  codProduto: string;
  descricaoProduto: string;
  numeroLancamento: number;
  codCosif: string;
  descricao: string;
  valor: number;
  dataMovimento: string;
  codUsuario: string;
}

export interface NovoMovimento {
  mes: number;
  ano: number;
  codProduto: string;
  codCosif: string;
  valor: number;
  descricao: string;
}
