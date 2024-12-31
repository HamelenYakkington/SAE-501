<?php

namespace App\Controller\Admin;

use App\Entity\Image;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractCrudController;
use EasyCorp\Bundle\EasyAdminBundle\Field\IdField;
use EasyCorp\Bundle\EasyAdminBundle\Field\TextField;
use EasyCorp\Bundle\EasyAdminBundle\Config\Actions;
use EasyCorp\Bundle\EasyAdminBundle\Config\Action;

class ImageCrudController extends AbstractCrudController
{
    public static function getEntityFqcn(): string
    {
        return Image::class;
    }

    public function configureFields(string $pageName): iterable
    {
        yield IdField::new('id')->hideOnForm();

        yield TextField::new('pathImage')
            ->setLabel('Image Path')
            ->setRequired(true);

        yield TextField::new('pathLabel')
            ->setLabel('Label Path')
            ->setRequired(true);

        yield TextField::new('dateTime')
            ->setLabel('Date Created')
            ->setFormTypeOption('disabled', true)
            ->setHelp('This field is automatically set and cannot be modified.');
    }

    public function createEntity(string $entityFqcn)
    {
        throw new \RuntimeException('La création d\'une nouvelle image est interdite.');
    }

    public function configureActions(Actions $actions): Actions
    {
        return $actions
            ->disable(Action::NEW);
    }
}
