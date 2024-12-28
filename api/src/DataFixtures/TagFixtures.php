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
            "0" => "bishop",
            "1" => "black-bishop",
            "2" => "black-king",
            "3" => "black-knight",
            "4" => "black-pawn",
            "5" => "black-queen",
            "6" => "black-rook",
            "7" => "white-bishop",
            "8" => "white-king",
            "9" => "white-knight",
            "10" => "white-pawn",
            "11" => "white-queen",
            "12" => "white-rook"
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
