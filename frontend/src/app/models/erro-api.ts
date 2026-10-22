/** Formato padronizado de erro devolvido pela API (GlobalExceptionHandler). */
export interface ErroApi {
  status: number;
  erro: string;
  mensagem: string;
  campos: CampoInvalido[];
}

export interface CampoInvalido {
  campo: string;
  mensagem: string;
}
