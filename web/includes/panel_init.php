<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/compat.php';
require_once dirname(__DIR__) . '/src/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_auth.php';
require_once dirname(__DIR__) . '/includes/security.php';

function admin_marquee_message(): string
{
    return 'Lima, sucesso total pra você! Se quiser o melhor plano SMS do momento, alta entrega e confiança, chama no PV o Dev Neginho.!';
}
