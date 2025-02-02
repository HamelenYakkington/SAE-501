<?php

namespace App\EventListener;

use Symfony\Component\HttpKernel\Event\RequestEvent;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Psr\Log\LoggerInterface;

class AppTokenListener
{
    private string $appSecretToken;
    private LoggerInterface $logger;

    public function __construct(string $appSecretToken, LoggerInterface $logger)
    {
        $this->appSecretToken = $appSecretToken;
        $this->logger = $logger;
    }

    public function onKernelRequest(RequestEvent $event)
    {
        $request = $event->getRequest();
        $path = $request->getPathInfo();

        if (in_array($path, ['/app-request/login_token', '/app-request/register'], true)) {
            $authHeader = $request->headers->get('Authorization');

            $this->logger->debug('Authorization Header: ' . $authHeader);

            if (!$authHeader || !str_starts_with($authHeader, 'Bearer ')) {
                throw new AccessDeniedHttpException('Access Denied: Missing Bearer Token');
            }

            $token = trim(substr($authHeader, 7));

            $this->logger->debug('Extracted Token: ' . $token);

            if ($token !== $this->appSecretToken) {
                throw new AccessDeniedHttpException('Access Denied: Invalid Bearer Token');
            }
        }
    }
}
