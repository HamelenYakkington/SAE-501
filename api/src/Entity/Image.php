<?php

namespace App\Entity;

use App\Repository\ImageRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: ImageRepository::class)]
class Image
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\ManyToOne(inversedBy: 'images')]
    #[ORM\JoinColumn(nullable: false)]
    private ?User $idUser = null;

    #[ORM\Column(type: 'string', length: 255)]
    private $pathImage;

    #[ORM\Column(type: 'string', length: 255)]
    private $pathLabel;

    #[ORM\Column(type: Types::DATE_MUTABLE)] // Stocke la date (jour, mois, année)
    private ?\DateTimeInterface $date = null;

    #[ORM\Column(type: Types::TIME_MUTABLE)] // Stocke l'heure (heure, minute, seconde)
    private ?\DateTimeInterface $time = null;

    /**
     * @var Collection<int, ImageTag>
     */
    #[ORM\OneToMany(targetEntity: ImageTag::class, mappedBy: 'Image')]
    private Collection $tag;

    public function __construct()
    {
        $this->tag = new ArrayCollection();
        $this->date = new \DateTime();
        $this->time = new \DateTime();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getUser(): ?User
    {
        return $this->idUser;
    }

    public function getIdUser(): ?User
    {
        return $this->idUser->getId();
    }

    public function setUser(?User $idUser): static
    {
        $this->idUser = $idUser;

        return $this;
    }

    public function getPathImage(): ?string
    {
        return $this->pathImage;
    }

    public function setPathImage(?string $pathImage): static
    {
        $this->pathImage = $pathImage;

        return $this;
    }

    public function getPathLabel(): ?string
    {
        return $this->pathLabel;
    }

    public function setPathLabel(?string $pathLabel): static
    {
        $this->pathLabel = $pathLabel;

        return $this;
    }

    public function getDate(): ?\DateTimeInterface
    {
        return $this->date;
    }

    public function setDate(\DateTimeInterface $date): static
    {
        $this->date = $date;

        return $this;
    }

    public function getTime(): ?\DateTimeInterface
    {
        return $this->time;
    }

    public function setTime(\DateTimeInterface $time): static
    {
        $this->time = $time;

        return $this;
    }

    public function getDateTime(): string
    {
        $date = $this->date ? $this->date->format('Y-m-d') : '0000-00-00';
        $time = $this->time ? $this->time->format('H:i:s') : '00:00:00';

        return $date . ' ' . $time;
    }

    public function setDateTime(\DateTimeInterface $dateTime): static
    {
        $this->date = \DateTime::createFromFormat('Y-m-d', $dateTime->format('Y-m-d'));
        $this->time = \DateTime::createFromFormat('H:i:s', $dateTime->format('H:i:s'));

        return $this;
    }

    /**
     * @return Collection<int, ImageTag>
     */
    public function getTag(): Collection
    {
        return $this->tag;
    }

    public function addTag(ImageTag $tag): static
    {
        if (!$this->tag->contains($tag)) {
            $this->tag->add($tag);
            $tag->setImage($this);
        }

        return $this;
    }

    public function removeTag(ImageTag $tag): static
    {
        if ($this->tag->removeElement($tag)) {
            // set the owning side to null (unless already changed)
            if ($tag->getImage() === $this) {
                $tag->setImage(null);
            }
        }

        return $this;
    }

    public function __toString(): string
    {
        return $this->pathImage ?? 'Image #' . $this->id;
    }
}
