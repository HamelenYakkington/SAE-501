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
            "0" => "black-bishop",
            "1" => "black-king",
            "2" => "black-knight",
            "3" => "black-pawn",
            "4" => "black-queen",
            "5" => "black-rook",
            "6" => "white-bishop",
            "7" => "white-king",
            "8" => "white-knight",
            "9" => "white-pawn",
            "10" => "white-queen",
            "11" => "white-rook"
        ];

        foreach ($chessPieces as $id => $piece) {
            $tag = new Tag();
            $tag->setId($id);
            $tag->setLabel($piece);
            $manager->persist($tag);
        }

        $manager->flush();
    }
}
