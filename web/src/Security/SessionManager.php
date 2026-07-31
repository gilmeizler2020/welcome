<?php
declare(strict_types=1);

namespace Lab\Webmail\Security;

final class SessionManager
{
    public static function start(array $config): void
    {
        if (session_status() === PHP_SESSION_ACTIVE) {
            return;
        }

        $name = (string) ($config['session_name'] ?? 'lab_webmail_sid');
        session_name($name);

        $cookiePath = '/';
        if (function_exists('url_prefix')) {
            $prefix = url_prefix($config);
            $cookiePath = $prefix === '' ? '/' : $prefix . '/';
        }

        session_set_cookie_params([
            'lifetime' => 0,
            'path'     => $cookiePath,
            'domain'   => '',
            'secure'   => (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off'),
            'httponly' => true,
            'samesite' => 'Strict',
        ]);

        ini_set('session.use_strict_mode', '1');
        ini_set('session.use_only_cookies', '1');
        session_start();
    }

    public static function regenerate(): void
    {
        if (session_status() === PHP_SESSION_ACTIVE) {
            session_regenerate_id(true);
        }
    }
}
