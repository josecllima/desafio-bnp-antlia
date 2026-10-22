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
