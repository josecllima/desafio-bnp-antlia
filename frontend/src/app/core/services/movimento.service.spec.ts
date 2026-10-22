import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';

import { NovoMovimento } from '../../models/movimento';
import { MovimentoService } from './movimento.service';

describe('MovimentoService', () => {
  const URL = 'http://localhost:8080/api/movimentos';
  let service: MovimentoService;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    service = TestBed.inject(MovimentoService);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('deve listar sem filtros', () => {
    service.listar().subscribe();

    const req = http.expectOne(URL);
    expect(req.request.method).toBe('GET');
    expect(req.request.params.keys().length).toBe(0);
    req.flush([]);
  });

  it('deve enviar mes e ano como filtros', () => {
    service.listar(10, 2026).subscribe();

    const req = http.expectOne((r) => r.url === URL);
    expect(req.request.params.get('mes')).toBe('10');
    expect(req.request.params.get('ano')).toBe('2026');
    req.flush([]);
  });

  it('deve incluir via POST com o corpo informado', () => {
    const novo: NovoMovimento = {
      mes: 10,
      ano: 2026,
      codProduto: '0001',
      codCosif: '41510000001',
      valor: 150.75,
      descricao: 'Ajuste manual',
    };

    service.incluir(novo).subscribe();

    const req = http.expectOne(URL);
    expect(req.request.method).toBe('POST');
    expect(req.request.body).toEqual(novo);
    req.flush({});
  });
});
