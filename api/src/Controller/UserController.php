<?php

namespace App\Controller;

use App\Entity\User;
use App\Repository\ImageRepository;
use App\Repository\UserRepository;
use Doctrine\Persistence\ManagerRegistry;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Annotation\Route;
use Doctrine\ORM\EntityManagerInterface;

class UserController extends AbstractController
{
    private EntityManagerInterface $entityManager;
    private UserRepository $userRepository;

    public function __construct(EntityManagerInterface $entityManager, UserRepository $userRepository)
    {
        $this->entityManager = $entityManager;
        $this->userRepository = $userRepository;
    }

    #[Route('/api/users', name: 'api_users', methods: ['GET'])]
    public function getAllUsers(): JsonResponse
    {
        $users = $this->entityManager->getRepository(User::class)->findAll();

        $userData = array_map(function (User $user) {
            return [
                'id' => $user->getId(),
                'email' => $user->getEmail(),
                'roles' => $user->getRoles(),
                'name' => $user->getLastName(),
                'surname' => $user->getFirstName(),
            ];
        }, $users);

        // Return users as a JSON response
        return new JsonResponse($userData);
    }

    #[Route('/api/user/{id}/history', name: 'user_history_admin', methods: ['GET'])]
    public function getUserHistoryAdmin(
        int $id,
        ImageRepository $imageRepository,
        ManagerRegistry $doctrine,
        Request $request
    ): JsonResponse {
        // Valider le token JWT
        $authorizationHeader = $request->headers->get('Authorization');
        if (!$authorizationHeader || strpos($authorizationHeader, 'Bearer ') !== 0) {
            return new JsonResponse(['error' => 'Invalid or missing Authorization token.'], 401);
        }

        $jwtToken = substr($authorizationHeader, 7);

        // Trouver l'utilisateur par le token JWT
        $adminUser = $this->userRepository->findUserByJwtToken($jwtToken);
        if (!$adminUser) {
            return new JsonResponse(['error' => 'Invalid or expired JWT token.'], 401);
        }

        // Vérifier si l'utilisateur connecté a le rôle d'admin
        if (!in_array('ROLE_ADMIN', $adminUser->getRoles())) {
            return new JsonResponse(['error' => 'Access denied.'], 403);
        }

        // Récupérer l'utilisateur dont l'historique est demandé
        $user = $doctrine->getRepository(User::class)->find($id);
        if (!$user) {
            return new JsonResponse(['error' => 'User not found.'], 404);
        }

        // Récupérer les images associées à cet utilisateur
        $images = $imageRepository->findByUser($user);

        $imageData = array_map(function ($image) {
            $tags = $image->getTags()->map(function ($imageTag) {
                return $imageTag->getTag()->getLabel();
            })->toArray();
        
            return [
                'id' => $image->getId(),
                'pathImage' => $image->getPathImage(),
                'pathLabel' => $image->getPathLabel(),
                'date' => $image->getDate()->format('Y-m-d'),
                'time' => $image->getTime()->format('H:i:s'),
                'labels' => $tags,
            ];
        }, $images);

        return new JsonResponse($imageData);
    }

    #[Route('/api/user/history', name: 'user_history', methods: ['GET'])]
    public function getUserHistory(
        ImageRepository $imageRepository,
        Request $request
    ): JsonResponse {
        // Validate JWT token
        $authorizationHeader = $request->headers->get('Authorization');
        if (!$authorizationHeader || strpos($authorizationHeader, 'Bearer ') !== 0) {
            return new JsonResponse(['error' => 'Invalid or missing Authorization token.'], 401);
        }
    
        $jwtToken = substr($authorizationHeader, 7);
    
        // Find user by JWT token
        $user = $this->userRepository->findUserByJwtToken($jwtToken);
        if (!$user) {
            return new JsonResponse(['error' => 'Invalid or expired JWT token.'], 401);
        }
    
        // Get images associated with the token's user
        $images = $imageRepository->findByUser($user);
    
        $imageData = array_map(function ($image) {
            $tags = $image->getTags()->map(function ($imageTag) {
                return $imageTag->getTag()->getLabel();
            })->toArray();
        
            return [
                'id' => $image->getId(),
                'pathImage' => $image->getPathImage(),
                'pathLabel' => $image->getPathLabel(),
                'date' => $image->getDate()->format('Y-m-d'),
                'time' => $image->getTime()->format('H:i:s'),
                'labels' => $tags,
            ];
        }, $images);
    
        return new JsonResponse($imageData);
    }

    #[Route('/api/user/info/{id}', name: 'user_info', methods: ['GET'])]
    public function getUserInfo(int $id): JsonResponse
    {
        $user = $this->entityManager->getRepository(User::class)->find($id);

        if (!$user) {
            return new JsonResponse(['error' => 'User not found'], 404);
        }

        // Extract non-sensitive information
        $userInfo = [
            'id' => $user->getId(),
            'firstName' => $user->getFirstName(),
            'lastName' => $user->getLastName(),
            'role' => $user->getRoles(),
        ];

        return new JsonResponse($userInfo);
    }
}
