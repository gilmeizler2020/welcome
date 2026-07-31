#!/bin/bash
# Corrige 404 em /teste/panel — rode na VPS como root
set -euo pipefail
APP_DIR="/var/www/html/teste"
install -m 644 "${APP_DIR}/deploy/apache-teste.conf" /etc/apache2/conf-available/locaweb-teste.conf
a2enconf locaweb-teste 2>/dev/null || true
apache2ctl configtest
systemctl reload apache2
echo "OK:"
echo "  http://191.252.209.28/teste/panel/login.php"
echo "  http://191.252.209.28/teste/panel  (redireciona)"
