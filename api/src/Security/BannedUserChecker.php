<?php

namespace App\Security;

use Symfony\Component\Security\Core\User\UserCheckerInterface;
use Symfony\Component\Security\Core\User\UserInterface;
use Symfony\Component\Security\Core\Exception\CustomUserMessageAuthenticationException;

class BannedUserChecker implements UserCheckerInterface
{
    public function checkPreAuth(UserInterface $user): void
    {
        // Check if the user is banned before authentication
        if (method_exists($user, 'isBanned') && $user->isBanned()) {
            throw new CustomUserMessageAuthenticationException('Your account is banned. Please contact support.');
        }
    }

    public function checkPostAuth(UserInterface $user): void
    {
        // Additional checks after authentication (optional)
    }
}
