<?php

namespace App\Controller;

use App\Entity\Tag;
use App\Repository\TagRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class TagController extends AbstractController
{
    private EntityManagerInterface $entityManager;

    public function __construct(EntityManagerInterface $entityManager)
    {
        $this->entityManager = $entityManager;
    }

    #[Route('/api/tags', name: 'api_get_tags', methods: ['GET'])]
    public function getTags(TagRepository $tagRepository): JsonResponse
    {
        $tags = $tagRepository->findAll();

        $data = array_map(function ($tag) {
            return [
                'id' => $tag->getId(),
                'label' => $tag->getLabel(),
            ];
        }, $tags);

        return $this->json($data, Response::HTTP_OK);
    }

    #[Route('/api/tag/{id}', name: 'api_tag_info', methods: ['GET'])]
    public function getTagInfo(int $id): JsonResponse
    {
        $tag = $this->entityManager->getRepository(Tag::class)->find($id);

        if (!$tag) {
            return new JsonResponse(['error' => 'Tag not found'], 404);
        }

        $tagInfo = [
            'id' => $tag->getId(),
            'label' => $tag->getLabel(),
        ];

        return new JsonResponse($tagInfo);
    }
}
