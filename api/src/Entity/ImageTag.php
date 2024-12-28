<?php

namespace App\Entity;

use App\Repository\ImageTagRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: ImageTagRepository::class)]
class ImageTag
{
    #[ORM\Id]
    #[ORM\ManyToOne(inversedBy: 'tag')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Image $image = null;

    #[ORM\Id]
    #[ORM\ManyToOne]
    #[ORM\JoinColumn(nullable: false)]
    private ?Tag $tag = null;

    #[ORM\Column]
    private ?int $occurence = null;

    public function getImage(): ?Image
    {
        return $this->image;
    }

    public function setImage(?Image $image): static
    {
        $this->image = $image;

        return $this;
    }

    public function getTag(): ?Tag
    {
        return $this->tag;
    }

    public function setTag(?Tag $tag): static
    {
        $this->tag = $tag;

        return $this;
    }

    public function getOccurence(): ?int
    {
        return $this->occurence;
    }

    public function setOccurence(int $occurence): static
    {
        $this->occurence = $occurence;

        return $this;
    }
}
