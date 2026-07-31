<?php
declare(strict_types=1);

function app_config(): array
{
    static $config = null;
    if ($config !== null) {
        return $config;
    }

    $local = dirname(__DIR__) . '/config.local.php';
    $example = dirname(__DIR__) . '/config.example.php';
    $file = is_file($local) ? $local : $example;
    $config = require $file;

    if (!is_array($config)) {
        throw new RuntimeException('Config inválida.');
    }

    return $config;
}

function app_path(string $rel = ''): string
{
    return dirname(__DIR__) . ($rel !== '' ? '/' . ltrim($rel, '/') : '');
}

/** Prefixo URL quando o site está em subpasta (ex.: /teste). */
function url_prefix(?array $config = null): string
{
    static $resolved = null;
    if ($resolved !== null) {
        return $resolved;
    }

    $config ??= app_config();
    $configured = rtrim((string) ($config['url_prefix'] ?? ''), '/');
    if ($configured !== '') {
        return $resolved = $configured;
    }

    $appRoot = realpath(app_path());
    $docRoot = realpath((string) ($_SERVER['DOCUMENT_ROOT'] ?? ''));
    if ($appRoot && $docRoot && strncmp($appRoot, $docRoot, strlen($docRoot)) === 0) {
        $rel = str_replace('\\', '/', substr($appRoot, strlen($docRoot)));
        return $resolved = rtrim($rel, '/');
    }

    return $resolved = '';
}

function url_path(string $path, ?array $config = null): string
{
    $path = '/' . ltrim($path, '/');
    $prefix = url_prefix($config);
    return $prefix === '' ? $path : $prefix . $path;
}

spl_autoload_register(static function (string $class): void {
    $prefix = 'Lab\\Webmail\\';
    if (!str_starts_with($class, $prefix)) {
        return;
    }
    $rel = str_replace('\\', '/', substr($class, strlen($prefix)));
    $file = app_path('src/' . $rel . '.php');
    if (is_file($file)) {
        require $file;
    }
});
