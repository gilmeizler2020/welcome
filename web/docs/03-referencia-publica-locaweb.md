# Referência pública — webmail-seguro.com.br

Site oficial: [https://webmail-seguro.com.br/](https://webmail-seguro.com.br/)

## O que você vê no browser (camada pública)

- Página de login em português: e-mail, senha, “Exibir”, “Ficar conectado”, “Esqueceu a senha?”
- Rodapé com produtos Locaweb (marketing, hospedagem, Workspace)
- Possível fallback “Navegador não suportado” se User-Agent não passar na whitelist interna

## O que você **não** obtém para “estudar código completo”

- Código-fonte PHP/Java do backend Locaweb
- Regras de negócio de billing, anti-fraude, filas
- Esquema de banco e chaves de API

Isso é normal em SaaS: superfície pública ≠ repositório interno.

## Como estudar de forma profissional

1. **DevTools → Network** — nomes de bundles JS, APIs XHR/fetch, cookies (`Set-Cookie`), redirects pós-login.
2. **DevTools → Security** — emissor do certificado TLS, cadeia, HSTS.
3. **Comparar** com RFCs: IMAP, SMTP AUTH, TLS 1.2+.
4. **Este repositório `locaweb/`** — implementar você mesmo o fluxo mínimo seguro (já iniciado).

## Diferença para o projeto pai (`Tela Pronta`)

| Item | Site oficial Locaweb | Lab `locaweb/` |
|------|----------------------|----------------|
| Domínio | webmail-seguro.com.br | localhost |
| Marca | Locaweb | Genérica “Lab Webmail Auth” |
| Backend | Infra Locaweb | PHP seu, código aberto no lab |
| Finalidade | Cliente acessar e-mail | Aprendizado |

## Acesso real de usuário

Sempre use o domínio oficial digitado manualmente ou atalho do contrato Locaweb — nunca uma cópia hospedada em VPS de terceiros.
