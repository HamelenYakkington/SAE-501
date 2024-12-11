<?php

namespace App\DataFixtures;

use App\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

class UserFixtures extends Fixture
{
    private UserPasswordHasherInterface $passwordHasher;

    public function __construct(UserPasswordHasherInterface $passwordHasher)
    {
        $this->passwordHasher = $passwordHasher;
    }

    public function load(ObjectManager $manager): void
    {
        $faker = Factory::create();

        // Create an admin user
        $admin = new User();
        $admin->setFirstName('Admin')
            ->setLastName('User')
            ->setEmail('admin@admin.admin')
            ->setRoles(['ROLE_ADMIN']);
        $admin->setPassword($this->passwordHasher->hashPassword($admin, 'adminpassword'));
        $manager->persist($admin);

        // Create regular users with Faker
        for ($i = 1; $i <= 25; $i++) {
            $userFirstName = $faker->firstName();
            $userLastName = $faker->lastName();

            $user = new User();
            $user->setFirstName($userFirstName)
                ->setLastName($userLastName)
                ->setEmail($userFirstName . '.' . $userLastName . '@example.com')
                ->setRoles(['ROLE_USER']);
            $user->setPassword($this->passwordHasher->hashPassword($user, 'password'));
            $manager->persist($user);
        }

        $manager->flush();
    }
}
