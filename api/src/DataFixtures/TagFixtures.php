<?php

namespace App\DataFixtures;

use App\Entity\Tag;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;

class TagFixtures extends Fixture
{
    public function load(ObjectManager $manager): void
    {
        // List of chess pieces names
        $chessPieces = [
            'King',
            'Queen',
            'Rook',
            'Bishop',
            'Knight',
            'Pawn',
        ];

        foreach ($chessPieces as $piece) {
            $tag = new Tag();
            $tag->setLabel($piece);
            $manager->persist($tag);
        }

        $manager->flush();
    }
}
