<?php

namespace App\DataFixtures;

use App\Entity\Image;
use App\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Common\DataFixtures\DependentFixtureInterface;
use Doctrine\Persistence\ObjectManager;

class ImageFixtures extends Fixture implements DependentFixtureInterface
{
    public function load(ObjectManager $manager): void
    {
        for ($i = 1; $i <= 30; $i++) {
            $image = new Image();

            $image->setPath('/images/image-' . $i . '.jpg');

            $date = new \DateTimeImmutable(sprintf('2024-%02d-%02d', rand(1, 12), rand(1, 28))); // Somewhat random date in 2024
            $time = new \DateTimeImmutable(sprintf('%02d:%02d:%02d', rand(0, 23), rand(0, 59), rand(0, 59))); // Random time

            $image->setDate($date);
            $image->setTime($time);

            $userReference = $this->getReference('user' . rand(0, 25), User::class); // Random user from UserFixtures
            $image->setIdUser($userReference);

            $manager->persist($image);
        }

        $manager->flush();
    }

    public function getDependencies(): array
    {
        return [
            UserFixtures::class,
        ];
    }
}
