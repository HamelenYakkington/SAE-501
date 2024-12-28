<?php

namespace App\Controller;

use App\Entity\Image;
use App\Entity\ImageTag;
use App\Repository\TagRepository;
use App\Repository\UserRepository;
use App\Exception\InvalidBase64ImageException;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Routing\Annotation\Route;

class ImageController extends AbstractController
{
    public function __construct(
        private UserRepository $userRepository,
        private EntityManagerInterface $entityManager,
        private TagRepository $tagRepository // Inject the TagRepository
    ) {}
    
    #[Route('/api/upload-image', name: 'upload_image', methods: ['POST'])]
    public function uploadImage(Request $request): JsonResponse
    {
        $response = [];
        $statusCode = Response::HTTP_OK;

        try {
            $data = json_decode($request->getContent(), true);

            // Validate JWT token
            $authorizationHeader = $request->headers->get('Authorization');
            if (!$authorizationHeader || strpos($authorizationHeader, 'Bearer ') !== 0) {
                throw new \InvalidArgumentException('Invalid or missing Authorization token.');
            }

            $jwtToken = substr($authorizationHeader, 7);

            // Find user by JWT token
            $user = $this->userRepository->findUserByJwtToken($jwtToken);
            if (!$user) {
                throw new \InvalidArgumentException('Invalid or expired JWT token.');
            }

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
                throw new InvalidBase64ImageException();
            }

            // Generate file paths
            $fileName = uniqid('image_', true);
            $uploadDirImages = $this->getParameter('kernel.project_dir') . '/public/uploads/images';
            $uploadDirLabels = $this->getParameter('kernel.project_dir') . '/public/uploads/labels';

            if (!is_dir($uploadDirImages)) {
                mkdir($uploadDirImages, 0755, true);
            }

            if (!is_dir($uploadDirLabels)) {
                mkdir($uploadDirLabels, 0755, true);
            }

            // Save image
            $imagePath = $uploadDirImages . '/' . $fileName . '.png';
            file_put_contents($imagePath, $imageData);

            // Save label to file
            $labelPath = $uploadDirLabels . '/' . $fileName . '.txt';
            file_put_contents($labelPath, $data['label']);

            // Save metadata to database
            $imageEntity = new Image();
            $imageEntity->setIdUser($user);
            $imageEntity->setPath('/uploads/images/' . $fileName . '.png');
            $imageEntity->setDate(new \DateTime());
            $imageEntity->setTime(new \DateTime());

            $this->entityManager->persist($imageEntity);

            // Process tags from the label
            $labels = explode("\n", trim($data['label']));
            $tagOccurrences = [];

            foreach ($labels as $label) {
                $parts = explode(' ', trim($label));
                $tagId = (int)$parts[0];

                // Increment the tag occurrence count
                if (!isset($tagOccurrences[$tagId])) {
                    $tagOccurrences[$tagId] = 0;
                }
                $tagOccurrences[$tagId]++;
            }

            // Save tag occurrences
            foreach ($tagOccurrences as $tagId => $occurrence) {
                $tag = $this->tagRepository->find($tagId);

                if ($tag) {
                    $imageTag = new ImageTag();
                    $imageTag->setImage($imageEntity);
                    $imageTag->setTag($tag);
                    $imageTag->setOccurence($occurrence);

                    $this->entityManager->persist($imageTag);
                }
            }

            $this->entityManager->flush();

            $response['message'] = 'Image and label uploaded successfully.';
            $response['image_path'] = '/uploads/images/' . $fileName . '.png';
            $response['label_path'] = '/uploads/labels/' . $fileName . '.txt'; // Include label path in the response
        } catch (\InvalidArgumentException $e) {
            $response['error'] = $e->getMessage();
            $statusCode = Response::HTTP_BAD_REQUEST;
        } catch (InvalidBase64ImageException $e) {
            $response['error'] = $e->getMessage();
            $statusCode = Response::HTTP_BAD_REQUEST;
        } catch (\Throwable $e) {
            $response['error'] = 'An unexpected error occurred.';
            $statusCode = Response::HTTP_INTERNAL_SERVER_ERROR;
        }

        return $this->json($response, $statusCode);
    }
}
