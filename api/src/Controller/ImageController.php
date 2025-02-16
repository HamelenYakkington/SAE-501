<?php

namespace App\Controller;

use App\Entity\Image;
use App\Entity\ImageTag;
use App\Repository\TagRepository;
use App\Repository\UserRepository;
use App\Repository\ImageRepository;
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
        private TagRepository $tagRepository,
        private ImageRepository $imageRepository,
    ) {}
    
    #[Route('/api/upload-image', name: 'upload_image', methods: ['POST'])]
    public function uploadImage(Request $request): JsonResponse
    {
        $response = [];
        $statusCode = Response::HTTP_OK;

        try {
            $data = json_decode($request->getContent(), true);

            //Validate JWT token
            $authorizationHeader = $request->headers->get('Authorization');
            if (!$authorizationHeader || strpos($authorizationHeader, 'Bearer ') !== 0) {
                throw new \InvalidArgumentException('Invalid or missing Authorization token.');
            }

            $jwtToken = substr($authorizationHeader, 7);

            //Find user by JWT token
            $user = $this->userRepository->findUserByJwtToken($jwtToken);
            if (!$user) {
                throw new \InvalidArgumentException('Invalid or expired JWT token.');
            }

            //Validate 'image' key
            if (!isset($data['image'])) {
                throw new \InvalidArgumentException('No image data provided.');
            }

            //Validate 'label' key
            if (!isset($data['label']) || !is_string($data['label'])) {
                throw new \InvalidArgumentException('No label data provided or invalid format. Expected a string.');
            }

            //Extract and validate Base64 string
            $base64Image = $data['image'];
            if (strpos($base64Image, 'data:image/') === 0) {
                $base64Image = explode(',', $base64Image)[1];
            }

            $imageData = base64_decode($base64Image, true);
            if ($imageData === false) {
                throw new InvalidBase64ImageException();
            }

            //Generate file paths
            $fileName = uniqid('image_', true);
            $uploadDirImages = $this->getParameter('kernel.project_dir') . '/public/uploads/images';
            $uploadDirLabels = $this->getParameter('kernel.project_dir') . '/public/uploads/labels';

            if (!is_dir($uploadDirImages)) {
                mkdir($uploadDirImages, 0755, true);
            }

            if (!is_dir($uploadDirLabels)) {
                mkdir($uploadDirLabels, 0755, true);
            }

            //Save image
            $imagePath = $uploadDirImages . '/' . $fileName . '.png';
            file_put_contents($imagePath, $imageData);

            //Process and validate label file
            $labels = explode("\n", trim($data['label']));
            $processedLabels = [];
            $tagOccurrences = [];

            foreach ($labels as $label) {
                $row = explode(' ', trim($label));
                $firstWord = strtolower($row[0]);

                //Check if the tag exists
                $tag = $this->tagRepository->findOneBy(['label' => $firstWord]);

                if ($tag) {
                    //Replace label with tag ID
                    $processedLabels[] = $tag->getId() . ' ' . implode(' ', array_slice($row, 1));

                    //Increment the tag occurrence count
                    if (!isset($tagOccurrences[$tag->getId()])) {
                        $tagOccurrences[$tag->getId()] = 0;
                    }
                    $tagOccurrences[$tag->getId()]++;
                }
            }

            if (!empty($processedLabels)) {
                //Save processed label to file
                $labelPath = $uploadDirLabels . '/' . $fileName . '.txt';
                file_put_contents($labelPath, implode("\n", $processedLabels));

                //Save metadata to database
                $imageEntity = new Image();
                $imageEntity->setUser($user);
                $imageEntity->setPathImage('/uploads/images/' . $fileName . '.png');
                $imageEntity->setPathLabel('/uploads/labels/' . $fileName . '.txt');
                $imageEntity->setDate(new \DateTime());
                $imageEntity->setTime(new \DateTime());

                

                //Save tag occurrences
                foreach ($tagOccurrences as $tagId => $occurrence) {
                    $tag = $this->tagRepository->find($tagId);

                    if ($tag) {
                        $imageTag = new ImageTag();
                        $imageTag->setImage($imageEntity);
                        $imageTag->setTag($tag);
                        $imageTag->setOccurence($occurrence);
                        $imageEntity->addTag($imageTag);

                        $this->entityManager->persist($imageTag);
                    }
                }

                $this->entityManager->persist($imageEntity);

                $this->entityManager->flush();

                $response['message'] = 'Image and label uploaded successfully.';
                $response['image_path'] = '/uploads/images/' . $fileName . '.png';
                $response['label_path'] = '/uploads/labels/' . $fileName . '.txt';
            } else {
                throw new \InvalidArgumentException('Processed label file is empty. No valid tags found.');
            }
        } catch (\InvalidArgumentException $e) {
            $response['error'] = $e->getMessage();
            $statusCode = Response::HTTP_BAD_REQUEST;
        } catch (InvalidBase64ImageException $e) {
            $response['error'] = $e->getMessage();
            $statusCode = Response::HTTP_BAD_REQUEST;
        } catch (\Throwable $e) {
            $response['error'] = 'An unexpected error occurred. ' . $e->getMessage();
            $response['trace'] = $e->getTraceAsString();
            $statusCode = Response::HTTP_INTERNAL_SERVER_ERROR;
        }

        return $this->json($response, $statusCode);
    }

    #[Route('/api/images/latest-history/{nbr}', name: 'latest_history', methods: ['GET'])]
    public function getLatestSearchesPerUser(
        int $nbr,
        ImageRepository $imageRepository,
        Request $request
    ): JsonResponse {
        if ($nbr > 100) {
            $nbr = 100;
        }
        $limit = $request->query->getInt('limit', default: $nbr);

        $latestSearches = $imageRepository->findLatestSearchesPerUser($limit);

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
        }, $latestSearches);

        return new JsonResponse($imageData);
    }

    #[Route('/api/image/delete/{id}', name: 'delete_image', methods: ['DELETE'])]
    public function deleteImage(int $id, Request $request): JsonResponse
    {
        // Get the Authorization header
        $authorizationHeader = $request->headers->get('Authorization');
        if (!$authorizationHeader || strpos($authorizationHeader, 'Bearer ') !== 0) {
            return new JsonResponse(['error' => 'Invalid or missing Authorization token.'], 401);
        }

        $jwtToken = substr($authorizationHeader, 7);

        // Find the user by the JWT token
        $adminUser = $this->userRepository->findUserByJwtToken($jwtToken);
        if (!$adminUser) {
            return new JsonResponse(['error' => 'Invalid or expired JWT token.'], 401);
        }

        $image = $this->imageRepository->find($id);
        if (!$image) {
            return new JsonResponse(['error' => 'Image not found.'], 404);
        }

        if (!in_array('ROLE_ADMIN', $adminUser->getRoles()) && $adminUser !== $image->getUser()) {
            return new JsonResponse(['error' => 'Access denied.'], 403);
        }

        $projectDir = $this->getParameter('kernel.project_dir') . '/public';
        $imagePath = $projectDir . $image->getPathImage();
        $labelPath = $projectDir . $image->getPathLabel();

        // Delete the image file if it exists
        if (file_exists($imagePath) && is_file($imagePath)) {
            unlink($imagePath);
        }

        // Delete the label file if it exists
        if (file_exists($labelPath) && is_file($labelPath)) {
            unlink($labelPath);
        }
        
        $this->entityManager->remove($image);
        $this->entityManager->flush();

        return new JsonResponse(['success' => 'Image deleted successfully.'], 200);
    }
}
