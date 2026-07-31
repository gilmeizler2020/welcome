# Arquitetura de webmail em produção

Referência técnica para estudo. O [Webmail Seguro Locaweb](https://webmail-seguro.com.br/) é produto fechado; o que segue são padrões da indústria observáveis em stacks similares (cPanel Webmail, Roundcube, SOGo, Zimbra, Exchange OWA).

## Camadas

```
[Browser]
    │ HTTPS
    ▼
[CDN / WAF / Load Balancer]  ← rate limit, bot, geo opcional
    ▼
[Reverse proxy — Nginx/Apache]
    ▼
[App webmail — PHP/Node/Java ou bundle estático + API]
    ▼
[Serviço de autenticação]    ← IMAP/LDAP/SAML/OAuth2 contra mail stack
    ▼
[Storage de mensagens]       ← IMAP/Dovecot, Exchange, etc.
```

## Frontend

1. **Detecção de navegador** — bloqueia engines sem APIs necessárias (WebSocket, crypto subtle, modules). Reduz suporte e superfície de ataque em IE antigo.
2. **SPA ou híbrido** — login pode ser HTML server-side; pós-login carrega app JS pesado (lista de pastas, composer).
3. **Assets versionados** — `/cPanel_magic_revision_<hash>/...` ou `main.[contenthash].js`: cache longo + invalidação por hash.
4. **CSP** — restringe scripts inline em produção madura.

## Backend de login

| Abordagem | Uso |
|-----------|-----|
| **IMAP AUTH** | Valida usuário/senha no servidor de correio (comum em hospedagem compartilhada) |
| **LDAP/AD** | Corporativo |
| **OAuth2 / OIDC** | Google Workspace, integrações modernas |
| **Sessão server-side** | Cookie `HttpOnly` + `Secure` + `SameSite`; ID de sessão no Redis/DB |

O PHP do seu lab (`public/api/login.php`) modela só a **borda**: recebe POST, valida CSRF, rate limit, delega autenticação — não implementa leitor de e-mail.

## Por que você não “baixa o código” da Locaweb

- Código roda nos servidores deles (proprietário + minificado).
- O que o navegador recebe é HTML/JS/CSS públicos, não o backend PHP/Java completo.
- Estudo correto: padrões + lab local + documentação de protocolos (IMAP RFC 3501, TLS).

## Escalabilidade

- **Stateless** na borda (várias instâncias PHP-FPM atrás do LB).
- **Sessão centralizada** (Redis) se houver múltiplos nós.
- **IMAP** é stateful por conexão — pools e timeouts curtos evitam esgotar o mail server.

## Relação com seu `source.html` antigo

O arquivo `source.html` na raiz do projeto pai é template **cPanel Webmail** (login genérico de hospedagem), não necessariamente o bundle atual da Locaweb. Locaweb pode customizar skin, textos e endpoints.
