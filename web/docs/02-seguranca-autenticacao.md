# Segurança em login webmail (produção)

Implementações correspondentes neste lab: `src/Security/*`, `public/api/login.php`.

## 1. HTTPS obrigatório

- Cookie `Secure`, HSTS no proxy.
- Sem login em HTTP claro.

## 2. CSRF

- Token por sessão, expiração (TTL).
- Form POST inclui campo oculto; API rejeita sem token válido.
- **Lab:** `CsrfToken::issue()` / `validate()`.

## 3. Sessão

- `session.use_strict_mode = 1`
- `HttpOnly`, `SameSite=Strict` (ou Lax se houver redirect OAuth)
- `session_regenerate_id(true)` após login bem-sucedido (fixation).

## 4. Rate limiting

- Por IP + opcionalmente por usuário.
- Janela deslizante ou fixed window em Redis/arquivo.
- Resposta `429`, mensagem genérica.

## 5. Respostas de erro genéricas

- Sempre `"E-mail ou senha incorretos"` — não revelar se o usuário existe.
- Não diferenciar timeout IMAP de senha errada no cliente.

## 6. Senha

- Nunca logar, nunca gravar em JSON/planilha.
- Não enviar senha por GET.
- `autocomplete` correto no HTML.

## 7. Headers

```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Content-Security-Policy: ...
Referrer-Policy: strict-origin-when-cross-origin
```

## 8. IMAP em laboratório

- `validate-cert` em produção (não `novalidate-cert`).
- Timeout curto (5–10s).
- Conta de teste isolada.

## 9. O que phishing quebra (e você não deve replicar)

- Gravar credenciais em `data/*.json`
- Painel admin para exportar logins
- Anti-bot para bloquear pesquisadores
- Clonar marca/domínio de terceiros

## 10. Checklist antes de deploy real

- [ ] `config.local.php` fora do git
- [ ] Permissões `var/` 0700
- [ ] PHP `display_errors=Off` em produção
- [ ] Logs sem PII/senha
- [ ] 2FA no provedor de e-mail quando disponível
