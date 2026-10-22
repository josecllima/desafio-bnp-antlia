/** Item do combo Cosif (GET /api/produtos/{cod}/cosifs). */
export interface Cosif {
  codCosif: string;
  codClassificacao: string;
  /** Ja formatado pela API: "COD_COSIF - (COD_CLASSIFICACAO)". */
  exibicao: string;
}
