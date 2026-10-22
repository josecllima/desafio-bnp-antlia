import { DecimalPipe } from '@angular/common';
import { HttpErrorResponse } from '@angular/common/http';
import { Component, OnInit, inject, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { catchError, finalize, of, switchMap, tap } from 'rxjs';

import { MovimentoService } from '../core/services/movimento.service';
import { ProdutoService } from '../core/services/produto.service';
import { Cosif } from '../models/cosif';
import { CampoInvalido, ErroApi } from '../models/erro-api';
import { Movimento, NovoMovimento } from '../models/movimento';
import { Produto } from '../models/produto';

type NomeCampo = 'mes' | 'ano' | 'codProduto' | 'codCosif' | 'valor' | 'descricao';

@Component({
  selector: 'app-movimentos-manuais',
  imports: [ReactiveFormsModule, DecimalPipe],
  templateUrl: './movimentos-manuais.html',
  styleUrl: './movimentos-manuais.css',
})
export class MovimentosManuais implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly produtoService = inject(ProdutoService);
  private readonly movimentoService = inject(MovimentoService);

  protected readonly tamanhoMaxDescricao = 50;

  protected readonly produtos = signal<Produto[]>([]);
  protected readonly cosifs = signal<Cosif[]>([]);
  protected readonly movimentos = signal<Movimento[]>([]);
  protected readonly editando = signal(false);
  protected readonly salvando = signal(false);
  protected readonly carregandoGrid = signal(false);
  protected readonly mensagemSucesso = signal<string | null>(null);
  protected readonly mensagemErro = signal<string | null>(null);
  protected readonly camposComErro = signal<CampoInvalido[]>([]);

  protected readonly form = this.fb.group({
    mes: this.fb.control<number | null>(null, [
      Validators.required,
      Validators.min(1),
      Validators.max(12),
    ]),
    ano: this.fb.control<number | null>(null, [
      Validators.required,
      Validators.min(1000),
      Validators.max(9999),
    ]),
    codProduto: this.fb.control<string | null>(null, Validators.required),
    codCosif: this.fb.control<string | null>(null, Validators.required),
    valor: this.fb.control<number | null>(null, [Validators.required, Validators.min(0.01)]),
    descricao: this.fb.control<string | null>(null, [
      Validators.required,
      Validators.maxLength(this.tamanhoMaxDescricao),
    ]),
  });

  constructor() {
    this.form.disable();

    // cascata Produto -> Cosif; o switchMap descarta a resposta de um produto anterior
    this.form.controls.codProduto.valueChanges
      .pipe(
        tap(() => {
          this.cosifs.set([]);
          this.form.controls.codCosif.setValue(null, { emitEvent: false });
        }),
        switchMap((codProduto) =>
          codProduto
            ? this.produtoService.listarCosifs(codProduto).pipe(
                catchError((erro: HttpErrorResponse) => {
                  this.tratarErro(erro);
                  return of<Cosif[]>([]);
                }),
              )
            : of<Cosif[]>([]),
        ),
        takeUntilDestroyed(),
      )
      .subscribe((lista) => this.cosifs.set(lista));
  }

  ngOnInit(): void {
    this.carregarProdutos();
    this.carregarMovimentos();
  }

  protected novo(): void {
    this.limparMensagens();
    this.form.enable();
    this.form.reset();
    this.editando.set(true);
  }

  protected limpar(): void {
    this.limparMensagens();
    this.form.reset();
  }

  protected incluir(): void {
    if (!this.editando() || this.salvando()) {
      return;
    }
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const valores = this.form.getRawValue();
    const novoMovimento: NovoMovimento = {
      mes: valores.mes!,
      ano: valores.ano!,
      codProduto: valores.codProduto!,
      codCosif: valores.codCosif!,
      valor: valores.valor!,
      descricao: valores.descricao!.trim(),
    };

    this.limparMensagens();
    this.salvando.set(true);

    this.movimentoService
      .incluir(novoMovimento)
      .pipe(finalize(() => this.salvando.set(false)))
      .subscribe({
        next: (salvo) => {
          this.mensagemSucesso.set(
            `Lançamento ${this.zeros(salvo.numeroLancamento, 3)} incluído em ` +
              `${this.zeros(salvo.mes, 2)}/${salvo.ano}.`,
          );
          this.form.reset();
          this.form.disable();
          this.editando.set(false);
          this.carregarMovimentos();
        },
        error: (erro: HttpErrorResponse) => this.tratarErro(erro),
      });
  }

  protected invalido(campo: NomeCampo): boolean {
    const controle = this.form.controls[campo];
    return controle.invalid && (controle.touched || controle.dirty);
  }

  protected zeros(valor: number, tamanho: number): string {
    return String(valor).padStart(tamanho, '0');
  }

  protected tamanhoDescricao(): number {
    return this.form.controls.descricao.value?.length ?? 0;
  }

  private carregarProdutos(): void {
    this.produtoService.listarProdutos().subscribe({
      next: (lista) => this.produtos.set(lista),
      error: (erro: HttpErrorResponse) => this.tratarErro(erro),
    });
  }

  private carregarMovimentos(): void {
    this.carregandoGrid.set(true);
    this.movimentoService
      .listar()
      .pipe(finalize(() => this.carregandoGrid.set(false)))
      .subscribe({
        next: (lista) => this.movimentos.set(lista),
        error: (erro: HttpErrorResponse) => this.tratarErro(erro),
      });
  }

  private limparMensagens(): void {
    this.mensagemSucesso.set(null);
    this.mensagemErro.set(null);
    this.camposComErro.set([]);
  }

  private tratarErro(erro: HttpErrorResponse): void {
    const corpo = erro.error as Partial<ErroApi> | null;

    if (erro.status === 0) {
      this.mensagemErro.set(
        'Não foi possível conectar à API (http://localhost:8080). Verifique se o backend está rodando.',
      );
    } else if (corpo?.mensagem) {
      this.mensagemErro.set(corpo.mensagem);
    } else {
      this.mensagemErro.set(`Erro inesperado (HTTP ${erro.status}).`);
    }
    this.camposComErro.set(corpo?.campos ?? []);
  }
}
