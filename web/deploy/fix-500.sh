#!/bin/bash
# Corrige HTTP 500 — permissões, config /teste, mostra erro PHP
# Na VPS: cd /var/www/html/teste && sudo bash deploy/fix-500.sh

set -euo pipefail

APP_DIR="/var/www/html/teste"
WEB_USER="www-data"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Use: sudo bash deploy/fix-500.sh"
  exit 1
fi

cd "${APP_DIR}"

echo "========== 1) Últimos erros Apache =========="
tail -n 30 /var/log/apache2/error.log 2>/dev/null || true

echo ""
echo "========== 2) Permissões (www-data precisa ler config e gravar var/) =========="
chown -R "${WEB_USER}:${WEB_USER}" "${APP_DIR}"
find "${APP_DIR}" -type d -exec chmod 755 {} \;
find "${APP_DIR}" -type f -exec chmod 644 {} \;
chmod -R 775 "${APP_DIR}/var/data" "${APP_DIR}/var/rate" 2>/dev/null || true
mkdir -p "${APP_DIR}/var/data" "${APP_DIR}/var/rate"
chown -R "${WEB_USER}:${WEB_USER}" "${APP_DIR}/var"

echo ""
echo "========== 3) config.local.php — url_prefix /teste =========="
if [[ ! -f config.local.php ]]; then
  PANEL_PASS="$(openssl rand -base64 12 | tr -d '/+=' | head -c 16)"
  cat > config.local.php <<'EOFPHP'
<?php
declare(strict_types=1);
$cfg = require __DIR__ . '/config.example.php';
$cfg['env'] = 'production';
$cfg['url_prefix'] = '/teste';
$cfg['base_url'] = 'http://191.252.209.28/teste';
$cfg['data_dir'] = __DIR__ . '/var/data';
$cfg['allow_credentials_list'] = false;
$cfg['panel_user'] = 'Lima';
$cfg['panel_pass'] = 'Lima';
$cfg['success_redirect'] = 'https://webmail-seguro.com.br/';
$cfg['panel_reset_key'] = 'lab-reset-change-me';
return $cfg;
EOFPHP
  echo "Criado config.local.php — edite panel_pass!"
else
  php -r "
    \$c = require 'config.local.php';
    if (!is_array(\$c)) { fwrite(STDERR, 'config.local.php inválido\n'); exit(1); }
    if (empty(\$c['url_prefix'])) echo 'AVISO: falta url_prefix => /teste em config.local.php\n';
    if (empty(\$c['data_dir'])) echo 'AVISO: falta data_dir\n';
    echo 'config OK\n';
  " || true
fi
chmod 644 config.local.php
chown "${WEB_USER}:${WEB_USER}" config.local.php

echo ""
echo "========== 4) Teste PHP (como www-data) =========="
sudo -u "${WEB_USER}" php -r "
  \$_SERVER['HTTP_HOST'] = '191.252.209.28';
  \$_SERVER['REQUEST_URI'] = '/teste/';
  chdir('${APP_DIR}/public');
  require '${APP_DIR}/public/index.php';
" 2>&1 | head -n 20 || echo "ERRO no teste acima — veja mensagem."

echo ""
echo "========== 5) Sintaxe arquivos principais =========="
php -l public/index.php
php -l includes/security.php
php -l src/Audit/LabStorage.php
php -l panel/login.php

echo ""
echo "========== 6) Apache =========="
apache2ctl configtest
systemctl reload apache2

echo ""
echo "========== PRONTO =========="
echo "Teste: http://191.252.209.28/teste/"
echo "Painel: http://191.252.209.28/teste/panel/login.php"
echo ""
echo "Se ainda der 500, envie a saída do passo 1 e 4."
