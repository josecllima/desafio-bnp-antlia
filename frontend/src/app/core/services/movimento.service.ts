import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { Movimento, NovoMovimento } from '../../models/movimento';
import { API_URL } from '../api.config';

@Injectable({ providedIn: 'root' })
export class MovimentoService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = inject(API_URL);

  listar(mes?: number, ano?: number): Observable<Movimento[]> {
    let params = new HttpParams();
    if (mes != null) {
      params = params.set('mes', mes);
    }
    if (ano != null) {
      params = params.set('ano', ano);
    }
    return this.http.get<Movimento[]>(`${this.apiUrl}/movimentos`, { params });
  }

  incluir(movimento: NovoMovimento): Observable<Movimento> {
    return this.http.post<Movimento>(`${this.apiUrl}/movimentos`, movimento);
  }
}
