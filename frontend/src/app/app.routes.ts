import { Routes } from '@angular/router';

import { MovimentosManuais } from './movimentos-manuais/movimentos-manuais';

export const routes: Routes = [
  { path: '', component: MovimentosManuais, title: 'Movimentos Manuais' },
  { path: '**', redirectTo: '' },
];
