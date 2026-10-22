/** Linha do grid (GET /api/movimentos). */
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

/**
 * Corpo do POST /api/movimentos.
 * NUM_LANCAMENTO, DAT_MOVIMENTO e COD_USUARIO sao gerados no back.
 */
export interface NovoMovimento {
  mes: number;
  ano: number;
  codProduto: string;
  codCosif: string;
  valor: number;
  descricao: string;
}
