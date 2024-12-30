<?php

namespace App\Controller;

use App\Repository\TagRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class TagController extends AbstractController
{
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
}
