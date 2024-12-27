<?php

namespace App\Controller;

use App\Entity\Image;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Routing\Annotation\Route;
use App\Exception\InvalidBase64ImageException;

class ImageController extends AbstractController
{
    #[Route('/api/upload-image', name: 'upload_image', methods: ['POST'])]
    public function uploadImage(Request $request, EntityManagerInterface $entityManager): JsonResponse
    {
        $response = [];
        $statusCode = Response::HTTP_OK;

        try {
            $data = json_decode($request->getContent(), true);

            // Validate 'image' key
            if (!isset($data['image'])) {
                throw new \InvalidArgumentException('No image data provided.');
            }

            // Validate 'label' key
            if (!isset($data['label']) || !is_string($data['label'])) {
                throw new \InvalidArgumentException('No label data provided or invalid format. Expected a string.');
            }

            // Extract and validate Base64 string
            $base64Image = $data['image'];
            if (strpos($base64Image, 'data:image/') === 0) {
                $base64Image = explode(',', $base64Image)[1];
            }

            $imageData = base64_decode($base64Image, true);
            if ($imageData === false) {
                throw new \InvalidArgumentException('Invalid Base64 image data.');
            }

            // Generate file paths
            $fileName = uniqid('image_', true);
            $uploadDirImages = $this->getParameter('kernel.project_dir') . '/public/uploads/images';

            if (!is_dir($uploadDirImages)) {
                mkdir($uploadDirImages, 0755, true);
            }

            // Save image
            $imagePath = $uploadDirImages . '/' . $fileName . '.png';
            file_put_contents($imagePath, $imageData);

            // Retrieve the authenticated user from the JWT token
            $user = $this->getUser();
            if (!$user) {
                throw new \LogicException('No authenticated user found.');
            }

            // Create and persist the Image entity
            $imageEntity = new Image();
            $imageEntity->setIdUser($user);  // The user will be set based on the JWT token
            $imageEntity->setPath('/uploads/images/' . $fileName . '.png');
            $imageEntity->setDate(new \DateTime());
            $imageEntity->setTime(new \DateTime());
            $entityManager->persist($imageEntity);
            $entityManager->flush();

            $response['message'] = 'Image uploaded and entity created successfully.';
            $response['image_path'] = $imageEntity->getPath();
            $response['entity_id'] = $imageEntity->getId();
        } catch (\InvalidArgumentException $e) {
            $response['error'] = $e->getMessage();
            $statusCode = Response::HTTP_BAD_REQUEST;
        } catch (\Throwable $e) {
            $response['error'] = 'An unexpected error occurred.';
            $statusCode = Response::HTTP_INTERNAL_SERVER_ERROR;
        }

        return $this->json($response, $statusCode);
    }
}
