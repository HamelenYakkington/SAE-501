<?php

namespace App\Entity;

use App\Repository\UserRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: UserRepository::class)]
#[ORM\Table(name: '`user`')]
class User
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 100)]
    private ?string $lastName = null;

    #[ORM\Column(length: 100)]
    private ?string $firstName = null;

    #[ORM\Column(length: 180)]
    private ?string $email = null;

    #[ORM\Column(length: 255)]
    private ?string $mdp = null;

    #[ORM\Column(length: 32)]
    private ?string $salt = null;

    #[ORM\Column(length: 20, nullable: true)]
    private ?string $role = null;

    /**
     * @var Collection<int, images>
     */
    #[ORM\OneToMany(targetEntity: images::class, mappedBy: 'idUser', orphanRemoval: true)]
    private Collection $images;

    public function __construct()
    {
        $this->images = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getlastName(): ?string
    {
        return $this->lastName;
    }

    public function setlastName(string $lastName): static
    {
        $this->lastName = $lastName;

        return $this;
    }

    public function getfirstName(): ?string
    {
        return $this->firstName;
    }

    public function setfirstName(string $firstName): static
    {
        $this->firstName = $firstName;

        return $this;
    }

    public function getEmail(): ?string
    {
        return $this->email;
    }

    public function setEmail(string $email): static
    {
        $this->email = $email;

        return $this;
    }

    public function getMdp(): ?string
    {
        return $this->mdp;
    }

    public function setMdp(string $mdp): static
    {
        $this->mdp = $mdp;

        return $this;
    }

    public function getSalt(): ?string
    {
        return $this->salt;
    }

    public function setSalt(string $salt): static
    {
        $this->salt = $salt;

        return $this;
    }

    public function getRole(): ?string
    {
        return $this->role ?? 'ROLE_USER';
    }

    public function setRole(?string $role): static
    {
        $this->role = $role;

        return $this;
    }

    /**
     * @return Collection<int, images>
     */
    public function getimages(): Collection
    {
        return $this->images;
    }

    public function addimages(images $images): static
    {
        if (!$this->images->contains($images)) {
            $this->images->add($images);
            $images->setIdUser($this);
        }

        return $this;
    }

    public function removeimages(images $images): static
    {
        if ($this->images->removeElement($images)) {
            // set the owning side to null (unless already changed)
            if ($images->getIdUser() === $this) {
                $images->setIdUser(null);
            }
        }

        return $this;
    }
}
