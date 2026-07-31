#!/bin/bash
# Redefine painel para usuário Lima / senha Lima
# VPS: cd /var/www/html/teste && sudo bash deploy/reset-panel-lima.sh

set -euo pipefail
APP_DIR="/var/www/html/teste"
USER="${PANEL_USER:-Lima}"
PASS="${PANEL_PASS:-Lima}"

cd "${APP_DIR}"

php <<PHPEOF
<?php
declare(strict_types=1);
\$local = __DIR__ . '/config.local.php';
\$cfg = is_file(\$local) ? require \$local : require __DIR__ . '/config.example.php';
\$cfg['panel_user'] = '${USER}';
\$cfg['panel_pass'] = '${PASS}';
\$cfg['panel_name'] = 'D3V L1m4';
\$cfg['panel_reset_key'] = \$cfg['panel_reset_key'] ?? 'lab-reset-' . bin2hex(random_bytes(8));
\$out = "<?php\ndeclare(strict_types=1);\nreturn " . var_export(\$cfg, true) . ";\n";
file_put_contents(\$local, \$out);
echo "config.local.php atualizado\n";
PHPEOF

rm -f var/data/admin_auth.json
rm -rf var/data/sessions/* 2>/dev/null || true

php <<PHPEOF
<?php
require __DIR__ . '/includes/panel_init.php';
\$config = panel_bootstrap_config();
\$dir = panel_data_dir(\$config);
admin_auth_save(\$dir, '${USER}', '${PASS}');
echo "admin_auth.json criado\n";
PHPEOF

chown -R www-data:www-data var/data config.local.php
chmod 644 config.local.php
chmod -R 775 var/data

echo ""
echo "============================================"
echo " Painel resetado"
echo " URL: http://191.252.209.28/teste/panel/login.php"
echo " Usuário: ${USER}"
echo " Senha:   ${PASS}"
echo "============================================"
