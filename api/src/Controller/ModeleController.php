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

    #[Route('/api/modele/metadata', name: 'api_modele_metadata', methods: ['GET'])]
    public function metadata(): Response
    {
        $modeleFileName = "modelYolo8.tflite";
        $versionFileName = "version.txt";

        // Define the directory where the version's file and model are stored
        $fileDirectoryHeavy = $this->getParameter('kernel.project_dir') . '/public/modele/heavy';
        $fileDirectoryLight = $this->getParameter('kernel.project_dir') . '/public/modele/light';

        // File paths for "heavy" directory
        $modelePathHeavy = $fileDirectoryHeavy . '/' . $modeleFileName;
        $versionPathHeavy = $fileDirectoryHeavy . '/' . $versionFileName;

        // File paths for "light" directory
        $modelePathLight = $fileDirectoryLight . '/' . $modeleFileName;
        $versionPathLight = $fileDirectoryLight . '/' . $versionFileName;

        $metadata = [
            'heavy' => [
                'model' => file_exists($modelePathHeavy) ? '/modele/heavy/' . $modeleFileName : null,
                'version' => file_exists($versionPathHeavy) ? trim(file_get_contents($versionPathHeavy)) : null,
            ],
            'light' => [
                'model' => file_exists($modelePathLight) ? '/modele/light/' . $modeleFileName : null,
                'version' => file_exists($versionPathLight) ? trim(file_get_contents($versionPathLight)) : null,
            ],
        ];

        // Check for missing files
        if (!$metadata['heavy']['model'] && !$metadata['light']['model']) {
            return new JsonResponse(['error' => 'No model files found'], 404);
        }
        if (!$metadata['heavy']['version'] && !$metadata['light']['version']) {
            return new JsonResponse(['error' => 'No version files found'], 404);
        }

        return new JsonResponse($metadata, 200, ['Content-Type' => 'application/json']);
    }
}
