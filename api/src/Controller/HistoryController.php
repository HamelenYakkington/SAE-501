<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;

class HistoryController extends AbstractController
{
    #[Route("/history", name:"history")]
    public function index()
    {
        $uploadDir = $this->getParameter('kernel.project_dir').'/public/uploads';
        $files = scandir($uploadDir);
        $uploads = [];

        foreach ($files as $file) {
            if (preg_match('/\.(png|jpg|jpeg)$/i', $file)) {
                $annotationFile = preg_replace('/\.(png|jpg|jpeg)$/i', '.txt', $file);
                $boxes = [];
                if (file_exists($uploadDir.'/'.$annotationFile)) {
                    $lines = file($uploadDir.'/'.$annotationFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
                    foreach ($lines as $line) {
                        list($class, $xCenter, $yCenter, $width, $height) = explode(' ', $line);
                        $boxes[] = [
                            'class' => $class,
                            'x_center' => (float)$xCenter,
                            'y_center' => (float)$yCenter,
                            'width'    => (float)$width,
                            'height'   => (float)$height,
                        ];
                    }
                }
                $uploads[] = [
                    'image' => '/uploads/'.$file,
                    'boxes' => $boxes,
                ];
            }
        }

        return $this->render('history/index.html.twig', [
            'uploads' => $uploads,
        ]);
    }
}
