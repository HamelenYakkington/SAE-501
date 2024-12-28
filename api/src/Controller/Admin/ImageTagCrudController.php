<?php

namespace App\Controller\Admin;

use App\Entity\ImageTag;
use Doctrine\ORM\EntityManagerInterface;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractCrudController;
use EasyCorp\Bundle\EasyAdminBundle\Field\AssociationField;
use EasyCorp\Bundle\EasyAdminBundle\Field\IntegerField;

class ImageTagCrudController extends AbstractCrudController
{
    private EntityManagerInterface $entityManager;

    public function __construct(EntityManagerInterface $entityManager)
    {
        $this->entityManager = $entityManager;
    }

    public static function getEntityFqcn(): string
    {
        return ImageTag::class;
    }

    public function configureFields(string $pageName): iterable
    {
        yield AssociationField::new('image')
            ->setRequired(true)
            ->setLabel('Image');

        yield AssociationField::new('tag')
            ->setRequired(true)
            ->setLabel('Tag');

        yield IntegerField::new('occurence')
            ->setLabel('Occurrence')
            ->setRequired(true);
    }

    public function createEntity(string $entityFqcn)
    {
        $imageTag = new $entityFqcn();

        $image = $this->getContext()->getRequest()->get('image');
        $tag = $this->getContext()->getRequest()->get('tag');

        $existingImageTag = $this->entityManager
            ->getRepository(ImageTag::class)
            ->findOneBy(['image' => $image, 'tag' => $tag]);

        if ($existingImageTag) {
            throw new \RuntimeException('The combination of this Image and Tag already exists.');
        }

        return $imageTag;
    }

    public function updateEntity(EntityManagerInterface $entityManager, $entityInstance): void
    {
        $image = $entityInstance->getImage();
        $tag = $entityInstance->getTag();

        $existingImageTag = $this->entityManager
            ->getRepository(ImageTag::class)
            ->findOneBy(['image' => $image, 'tag' => $tag]);

        if ($existingImageTag && $existingImageTag !== $entityInstance) {
            throw new \RuntimeException('The combination of this Image and Tag already exists.');
        }

        parent::updateEntity($entityManager, $entityInstance);
    }

    public function deleteEntity(EntityManagerInterface $entityManager, $entityInstance): void
    {
        if (!$entityInstance) {
            throw new \RuntimeException('The entity you are trying to delete no longer exists.');
        }

        parent::deleteEntity($entityManager, $entityInstance);
    }
}
