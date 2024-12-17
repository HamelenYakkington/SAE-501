<?php

namespace App\Controller\Admin;

use App\Entity\Image;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractCrudController;
use EasyCorp\Bundle\EasyAdminBundle\Field\IdField;
use EasyCorp\Bundle\EasyAdminBundle\Field\TextField;
use EasyCorp\Bundle\EasyAdminBundle\Config\Actions;
use EasyCorp\Bundle\EasyAdminBundle\Config\Action;
use EasyCorp\Bundle\EasyAdminBundle\Config\Crud;
use EasyCorp\Bundle\EasyAdminBundle\Router\AdminUrlGenerator;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Doctrine\ORM\EntityManagerInterface;

class ImageCrudController extends AbstractCrudController
{
    private EntityManagerInterface $entityManager;
    private AdminUrlGenerator $adminUrlGenerator;

    public function __construct(EntityManagerInterface $entityManager, AdminUrlGenerator $adminUrlGenerator)
    {
        $this->entityManager = $entityManager;
        $this->adminUrlGenerator = $adminUrlGenerator;
    }

    public static function getEntityFqcn(): string
    {
        return Image::class;
    }

    public function configureFields(string $pageName): iterable
    {
        return [
            IdField::new('id')->hideOnForm(),

            TextField::new('path')
                ->setLabel('File Path')
                ->setRequired(true),

            TextField::new('dateTime', 'Created At')
                ->formatValue(function ($value, $entity) {
                    return $entity->getDateTime();
                })
            ->setSortable(false),
        ];
    }

    public function configureActions(Actions $actions): Actions
    {
        // Action for "Export" (Download Image)
        $exportAction = Action::new('exportImage', 'Export')
            ->linkToCrudAction('exportImage')
            ->addCssClass('btn btn-primary');

        // Action for "Delete Image"
        $deleteAction = Action::new('deleteImage', 'Delete')
            ->linkToCrudAction('deleteImage')
            ->addCssClass('btn btn-danger');

        return $actions
            ->add(Crud::PAGE_INDEX, $exportAction)
            ->add(Crud::PAGE_INDEX, $deleteAction);
    }

    // Export Image Action
    public function exportImage(AdminUrlGenerator $adminUrlGenerator, Request $request): BinaryFileResponse
    {
        $imageId = $request->get('entityId');
        $image = $this->entityManager->getRepository(Image::class)->find($imageId);

        if (!$image) {
            $this->addFlash('error', 'Image not found.');
            return $this->redirect($this->getAdminUrl());
        }

        $filePath = $this->getParameter('kernel.project_dir') . '/public/' . $image->getPath();

        if (!file_exists($filePath)) {
            $this->addFlash('error', 'File not found on the server.');
            return $this->redirect($this->getAdminUrl());
        }

        return $this->file($filePath, basename($image->getPath()));
    }

    // Delete Image Action
    public function deleteImage(AdminUrlGenerator $adminUrlGenerator, Request $request): RedirectResponse
    {
        $imageId = $request->get('entityId');
        $image = $this->entityManager->getRepository(Image::class)->find($imageId);

        if (!$image) {
            $this->addFlash('error', 'Image not found.');
            return $this->redirect($this->getAdminUrl());
        }

        $filePath = $this->getParameter('kernel.project_dir') . '/public/' . $image->getPath();

        // Delete the file from the server
        if (file_exists($filePath)) {
            unlink($filePath);
        }

        // Remove the image entity from the database
        $this->entityManager->remove($image);
        $this->entityManager->flush();

        $this->addFlash('success', 'Image successfully deleted.');

        return $this->redirect($this->getAdminUrl());
    }

    private function getAdminUrl(): string
    {
        return $this->adminUrlGenerator
        ->setController(self::class)
        ->setAction(Crud::PAGE_INDEX)
        ->generateUrl();
    }
}
