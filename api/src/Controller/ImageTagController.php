<?php

namespace App\Controller;

use App\Entity\Tag;
use App\Entity\ImageTag;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Annotation\Route;

class ImageTagController extends AbstractController
{
    private EntityManagerInterface $entityManager;

    public function __construct(EntityManagerInterface $entityManager)
    {
        $this->entityManager = $entityManager;
    }

    #[Route('/api/image-tags/{imageId}', name: 'api_image_tags', methods: ['GET'])]
    public function getImageTags(int $imageId): JsonResponse
    {
        $imageTags = $this->entityManager->getRepository(ImageTag::class)->findBy(['image' => $imageId]);

        if (!$imageTags) {
            return new JsonResponse(['error' => 'No tags found for this image'], 404);
        }

        $tagsInfo = array_map(function (ImageTag $imageTag) {
            $tag = $imageTag->getTag();
            return [
                'id' => $tag->getId(),
                'label' => $tag->getLabel(),
                'occurrence' => $imageTag->getOccurence(),
            ];
        }, $imageTags);

        return new JsonResponse($tagsInfo);
    }

    #[Route('/api/image-labels/{imageId}', name: 'api_image_labels', methods: ['GET'])]
    public function getImageLabels(int $imageId): JsonResponse
    {
        $imageTags = $this->entityManager->getRepository(ImageTag::class)->findBy(['image' => $imageId]);

        if (!$imageTags) {
            return new JsonResponse(['error' => 'No labels found for this image'], 404);
        }

        $labelsInfo = array_map(function (ImageTag $imageTag) {
            $tag = $imageTag->getTag();
            return $tag->getLabel();
        }, $imageTags);

        return new JsonResponse($labelsInfo);
    }
}
