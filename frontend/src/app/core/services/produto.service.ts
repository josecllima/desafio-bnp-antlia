import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { Cosif } from '../../models/cosif';
import { Produto } from '../../models/produto';
import { API_URL } from '../api.config';

/** Acesso aos endpoints de Produto e Cosif (combos da tela). */
@Injectable({ providedIn: 'root' })
export class ProdutoService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = inject(API_URL);

  listarProdutos(): Observable<Produto[]> {
    return this.http.get<Produto[]>(`${this.apiUrl}/produtos`);
  }

  /** Combo em cascata: Cosifs do produto escolhido. */
  listarCosifs(codProduto: string): Observable<Cosif[]> {
    return this.http.get<Cosif[]>(
      `${this.apiUrl}/produtos/${encodeURIComponent(codProduto)}/cosifs`,
    );
  }
}
