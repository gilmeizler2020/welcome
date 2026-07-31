# Deploy Ubuntu 24 — `/var/www/html/teste`

## 1. No seu PC (enviar arquivos para a VPS)

```bash
# Ajuste IP e usuário
rsync -avz --exclude 'var/data/*' --exclude '.git' \
  "./locaweb/" root@SEU_IP:/var/www/html/teste/
```

Ou ZIP + SFTP para `/var/www/html/teste/`.

## 2. Na VPS Ubuntu 24 (instalar tudo)

```bash
ssh root@SEU_IP

# Garantir pasta
mkdir -p /var/www/html/teste
cd /var/www/html/teste

# Instalar Apache, PHP 8.3, configurar permissões e Apache /teste
chmod +x deploy/install-ubuntu-24.sh
sudo bash deploy/install-ubuntu-24.sh
```

**Com senha do painel definida por você:**

```bash
sudo PANEL_USER=admin PANEL_PASS='SuaSenhaForte123!' bash deploy/install-ubuntu-24.sh
```

## 3. URLs

| O quê | URL |
|--------|-----|
| Login lab | `http://SEU_IP/teste/` |
| Painel admin | `http://SEU_IP/teste/panel/login.php` |

## 4. Firewall (se UFW ativo)

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

## 5. HTTPS (opcional, Let's Encrypt)

```bash
sudo apt install -y certbot python3-certbot-apache
sudo certbot --apache -d seu-dominio.com
```

Depois edite `config.local.php` → `base_url` com `https://`.

## 6. Comandos úteis

```bash
# Log Apache
sudo tail -f /var/log/apache2/error.log

# Reiniciar
sudo systemctl restart apache2

# Permissões se der erro ao gravar auditoria
sudo chown -R www-data:www-data /var/www/html/teste/var
```

## Estrutura esperada na VPS

```
/var/www/html/teste/
  public/
  panel/
  includes/
  src/
  deploy/
  config.local.php
  var/data/
```
