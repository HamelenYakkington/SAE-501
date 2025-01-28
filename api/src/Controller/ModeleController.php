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
