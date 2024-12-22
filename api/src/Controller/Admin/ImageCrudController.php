<?php

namespace App\Controller\Admin;

use App\Entity\Image;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractCrudController;
use EasyCorp\Bundle\EasyAdminBundle\Field\IdField;
use EasyCorp\Bundle\EasyAdminBundle\Field\TextField;

class ImageCrudController extends AbstractCrudController
{
    public static function getEntityFqcn(): string
    {
        return Image::class;
    }

    public function configureFields(string $pageName): iterable
    {
        yield IdField::new('id')->hideOnForm();

        yield TextField::new('path')
            ->setLabel('Image Path')
            ->setRequired(true);

        yield TextField::new('dateTime')
            ->setLabel('Date Created')
            ->setFormTypeOption('disabled', true)
            ->setHelp('This field is automatically set and cannot be modified.');
    }

    public function createEntity(string $entityFqcn)
    {
        $image = new $entityFqcn();

        // Automatically set the current date and time during creation
        $currentDate = new \DateTimeImmutable();
        $image->setDate($currentDate);
        $image->setTime($currentDate);

        $user = $this->getUser();
        if (!$user) {
            throw new \RuntimeException('No user is logged in. Cannot assign user to the image.');
        }
    
        $image->setIdUser($user);

        return $image;
    }
}
