import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MovimentosManuais } from './movimentos-manuais';

describe('MovimentosManuais', () => {
  const API = 'http://localhost:8080/api';
  let fixture: ComponentFixture<MovimentosManuais>;
  let http: HttpTestingController;
  let tela: HTMLElement;

  const botao = (texto: string): HTMLButtonElement =>
    Array.from(tela.querySelectorAll('button')).find((b) => b.textContent?.trim() === texto)!;
  const campo = (id: string): HTMLInputElement => tela.querySelector(`#${id}`)!;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MovimentosManuais],
      providers: [provideHttpClient(), provideHttpClientTesting()],
    }).compileComponents();

    fixture = TestBed.createComponent(MovimentosManuais);
    http = TestBed.inject(HttpTestingController);
    tela = fixture.nativeElement as HTMLElement;
    fixture.detectChanges(); // dispara o ngOnInit

    // Ao abrir, a tela consulta produtos e movimentos automaticamente
    http.expectOne(`${API}/produtos`).flush([{ codProduto: '0001', descricao: 'CDB Pos-Fixado' }]);
    http.expectOne(`${API}/movimentos`).flush([
      {
        mes: 2,
        ano: 2019,
        codProduto: '0001',
        descricaoProduto: 'CDB Pos-Fixado',
        numeroLancamento: 1,
        codCosif: '41510000001',
        descricao: 'TESTE DESC',
        valor: 150,
        dataMovimento: '2019-02-10T10:00:00',
        codUsuario: 'TESTE',
      },
    ]);
    await fixture.whenStable();
  });

  afterEach(() => http.verify());

  it('deve carregar o grid ao abrir, com zeros a esquerda', () => {
    const celulas = Array.from(tela.querySelectorAll('tbody tr:first-child td')).map((td) =>
      td.textContent?.trim(),
    );
    expect(celulas[0]).toBe('02'); // mes
    expect(celulas[4]).toBe('001'); // NR lancamento
  });

  it('campos devem comecar desabilitados', () => {
    expect(campo('mes').disabled).toBe(true);
    expect(campo('descricao').disabled).toBe(true);
    expect(botao('Incluir').disabled).toBe(true);
  });

  it('botao Novo deve habilitar os campos', async () => {
    botao('Novo').click();
    await fixture.whenStable();

    expect(campo('mes').disabled).toBe(false);
    expect(campo('descricao').disabled).toBe(false);
    expect(botao('Incluir').disabled).toBe(false);
  });
});
