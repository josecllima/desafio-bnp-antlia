package br.com.desafio.movimentos.infrastructure.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Clock;

/**
 * Fornece o relogio do sistema como dependencia injetavel.
 * Assim o service nao chama LocalDateTime.now() direto e os testes
 * podem usar um relogio fixo (Clock.fixed) para verificar DAT_MOVIMENTO.
 */
@Configuration
public class ClockConfig {

    @Bean
    public Clock clock() {
        return Clock.systemDefaultZone();
    }
}
