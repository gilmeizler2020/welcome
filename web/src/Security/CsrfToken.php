<?php
declare(strict_types=1);

namespace Lab\Webmail\Security;

final class CsrfToken
{
    public static function issue(int $ttlSeconds): string
    {
        $token = bin2hex(random_bytes(32));
        $_SESSION['_csrf'] = [
            'value' => $token,
            'exp'   => time() + $ttlSeconds,
        ];
        return $token;
    }

    public static function validate(?string $submitted): bool
    {
        $stored = $_SESSION['_csrf'] ?? null;
        if (!is_array($stored) || empty($stored['value']) || empty($stored['exp'])) {
            return false;
        }
        if (time() > (int) $stored['exp']) {
            unset($_SESSION['_csrf']);
            return false;
        }
        return is_string($submitted)
            && hash_equals((string) $stored['value'], $submitted);
    }
}
