<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class TestController extends AbstractController
{
    #[Route('/test-upload', name: 'test_upload')]
    public function showTestUploadPage(): Response
    {
        return $this->render('test/test_upload_image.html.twig');
    }
}
