import { InjectionToken } from '@angular/core';

/**
 * URL base da API Spring Boot.
 * Fica num token injetavel para poder ser trocada (ex.: em testes ou outro ambiente)
 * sem alterar os services.
 */
export const API_URL = new InjectionToken<string>('API_URL', {
  providedIn: 'root',
  factory: () => 'http://localhost:8080/api',
});
