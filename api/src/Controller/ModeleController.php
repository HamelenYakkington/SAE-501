<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\ResponseHeaderBag;

class ModeleController extends AbstractController
{
    #[Route('/api/modele/version', name: 'api_modele_version', methods: ['GET'])]
    public function getModeleVersion(): Response
    {
        //Define the directory the version's file is stored
        $filePath = $this->getParameter('kernel.project_dir') . '/public/modele/version.txt';

        if (!file_exists($filePath)) {
            return new JsonResponse(['error' => 'File not found'], 404);
        }

        $content = file_get_contents($filePath);

        if ($content === false) {
            return new JsonResponse(['error' => 'Unable to read the file'], 500);
        }

        return new JsonResponse(["version" => $content], 200, ['Content-Type' => 'text/plain']);
    }

    #[Route('/api/modele/download', name: 'api_modele_download', methods: ['GET'])]
    public function download(): BinaryFileResponse
    {
        $filename = "modelYolo8.tflite";

        //Define the directory where the modele is stored
        $fileDirectory = $this->getParameter('kernel.project_dir') . '/public/modele';
        $filePath = $fileDirectory . '/' . $filename;

        if (!file_exists($filePath)) {
            throw $this->createNotFoundException('File not found');
        }

        //Create a BinaryFileResponse to send the file
        $response = new BinaryFileResponse($filePath);

        //Set the content disposition to attachment to force download
        $response->setContentDisposition(ResponseHeaderBag::DISPOSITION_ATTACHMENT, $filename);

        return $response;
    }
}
