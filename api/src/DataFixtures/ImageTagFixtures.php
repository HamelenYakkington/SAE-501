<?php

namespace App\DataFixtures;

use App\Entity\Image;
use App\Entity\Tag;
use App\Entity\ImageTag;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Doctrine\Common\DataFixtures\DependentFixtureInterface;

class ImageTagFixtures extends Fixture implements DependentFixtureInterface
{
    public function load(ObjectManager $manager): void
    {
        //Retrieve existing Image and Tag objects
        $images = $manager->getRepository(Image::class)->findAll();
        $tags = $manager->getRepository(Tag::class)->findAll();

        if (empty($images) || empty($tags)) {
            throw new \RuntimeException('No images or tags found. Please load Image and Tag fixtures first.');
        }

        //Create ImageTag relationships
        foreach ($images as $image) {
            foreach ($tags as $tag) {
                $imageTag = new ImageTag();
                $imageTag->setImage($image);
                $imageTag->setTag($tag);
                $imageTag->setOccurence(random_int(1, 5));

                $manager->persist($imageTag);
            }
        }

        $manager->flush();
    }

    public function getDependencies(): array
    {
        return [
            ImageFixtures::class,
            TagFixtures::class,
        ];
    }
}
