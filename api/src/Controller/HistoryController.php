<?php

namespace App\Controller;

use App\Entity\Image;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class HistoryController extends AbstractController
{

    #[Route("/history", name: "history")]
    public function index(EntityManagerInterface $em): Response
    {
        $user = $this->getUser();
        if (!$user) {
            throw $this->createAccessDeniedException('You must be logged in to view your history.');
        }

        $images = $em->getRepository(Image::class)->findBy(['user' => $user]);

        $uploads = [];

        foreach ($images as $image) {
            $imageFile = $image->getPathImage();
            $labelFile = $this->getParameter('kernel.project_dir') . '/public/' . $image->getPathLabel();
            $boxes = [];

            if (file_exists($labelFile)) {
                $lines = file($labelFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
                foreach ($lines as $line) {
                    $parts = explode(' ', $line);
                    if (count($parts) === 5) {
                        list($class, $xCenter, $yCenter, $width, $height) = $parts;
                        $boxes[] = [
                            'class'    => $class,
                            'x_center' => (float)$xCenter,
                            'y_center' => (float)$yCenter,
                            'width'    => (float)$width,
                            'height'   => (float)$height,
                        ];
                    }
                }
            }

            $uploads[] = [
                'image' => $imageFile,
                'boxes' => $boxes,
            ];
        }

        return $this->render('history/index.html.twig', [
            'uploads' => $uploads,
        ]);
    }
}
