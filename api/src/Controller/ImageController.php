<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Routing\Annotation\Route;
use App\Exception\InvalidBase64ImageException;

class ImageController extends AbstractController
{
    #[Route('/api/upload-image', name: 'upload_image', methods: ['POST'])]
    public function uploadImage(Request $request): JsonResponse
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

            // Save label
            $labelPath = $uploadDirLabels . '/' . $fileName . '.txt';
            $label = $data['label'];
            file_put_contents($labelPath, $label);

            $response['message'] = 'Image and label uploaded successfully.';
            $response['image_path'] = '/uploads/images/' . $fileName . '.png';
            $response['label_path'] = '/uploads/labels/' . $fileName . '.txt';
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

        // Single return statement at the end
        return $this->json($response, $statusCode);
    }
}
