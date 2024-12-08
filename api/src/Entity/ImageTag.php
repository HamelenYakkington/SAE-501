<?php

namespace App\Entity;

use App\Repository\ImageTagRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: ImageTagRepository::class)]
class ImageTag
{
    #[ORM\Id]
    #[ORM\ManyToOne(targetEntity: Image::class)]
    #[ORM\JoinColumn(nullable: false)]
    private ?Image $image = null;

    #[ORM\Id]
    #[ORM\ManyToOne(targetEntity: Tag::class)]
    #[ORM\JoinColumn(nullable: false)]
    private ?Tag $tag = null;

    #[ORM\Column(type: 'integer')]
    private int $occurence;

    public function getImage(): ?Image
    {
        return $this->image;
    }

    public function setImage(?Image $image): self
    {
        $this->image = $image;

        return $this;
    }

    public function getTag(): ?Tag
    {
        return $this->tag;
    }

    public function setTag(?Tag $tag): self
    {
        $this->tag = $tag;

        return $this;
    }

    public function getOccurence(): int
    {
        return $this->occurence;
    }

    public function setOccurence(int $occurence): self
    {
        $this->occurence = $occurence;

        return $this;
    }
}
