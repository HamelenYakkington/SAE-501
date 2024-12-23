<?php

namespace App\Controller;

use App\Entity\User;
use App\Repository\ImageRepository;
use Doctrine\Persistence\ManagerRegistry;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Annotation\Route;
use Doctrine\ORM\EntityManagerInterface;

class UserController extends AbstractController
{
    private EntityManagerInterface $entityManager;

    public function __construct(EntityManagerInterface $entityManager)
    {
        $this->entityManager = $entityManager;
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

    #[Route('/api/user/{id}/history', name: 'user_history', methods: ['GET'])]
    public function getUserHistory(
        int $id,
        ImageRepository $imageRepository,
        ManagerRegistry $doctrine
    ): JsonResponse {
        $user = $doctrine->getRepository(User::class)->find($id);

        if (!$user) {
            return new JsonResponse(['error' => 'User not found'], 404);
        }

        $images = $imageRepository->findByUser($user);

        $imageData = array_map(function ($image) {
            return [
                'id' => $image->getId(),
                'path' => $image->getPath(),
                'date' => $image->getDate()->format('Y-m-d'),
                'time' => $image->getTime()->format('H:i:s'),
            ];
        }, $images);

        return new JsonResponse($imageData);
    }
}
