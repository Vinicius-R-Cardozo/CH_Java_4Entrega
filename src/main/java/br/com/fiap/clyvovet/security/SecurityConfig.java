package br.com.fiap.clyvovet.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.configurers.HeadersConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;

import static br.com.fiap.clyvovet.model.Perfil.TUTOR;
import static br.com.fiap.clyvovet.model.Perfil.VETERINARIO;

@Configuration
public class SecurityConfig {

    /**
     * Console do H2, usado para mostrar os SELECTs no vídeo. Só o veterinário entra; aqui o HTTP Basic
     * mantém o padrão (o navegador abre a janela de login) e o console precisa de frames da mesma origem.
     */
    @Bean
    @Order(1)
    SecurityFilterChain consoleH2(HttpSecurity http) throws Exception {
        return http
                .securityMatcher("/h2-console/**")
                .authorizeHttpRequests(auth -> auth.anyRequest().hasRole(VETERINARIO.name()))
                .httpBasic(Customizer.withDefaults())
                .csrf(AbstractHttpConfigurer::disable)
                .headers(headers -> headers.frameOptions(HeadersConfigurer.FrameOptionsConfig::sameOrigin))
                .build();
    }

    @Bean
    @Order(2)
    SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/", "/*.html", "/css/**", "/js/**", "/img/**", "/error").permitAll()
                        .requestMatchers(HttpMethod.POST, "/cadastro").permitAll()
                        .requestMatchers(HttpMethod.GET, "/agendamentos").hasRole(TUTOR.name())
                        .requestMatchers(HttpMethod.POST, "/agendamentos").hasRole(TUTOR.name())
                        .requestMatchers("/pets/**").hasRole(TUTOR.name())
                        .requestMatchers("/agendamentos/**", "/pacientes/**", "/tutores/**", "/medicamentos/**",
                                "/exames/**", "/campanhas/**", "/relatorios/**", "/auditoria/**")
                        .hasRole(VETERINARIO.name())
                        .anyRequest().authenticated()
                )
                .httpBasic(basic -> basic.authenticationEntryPoint(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED)))
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .build();
    }

    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
