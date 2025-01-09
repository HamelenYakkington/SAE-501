<?php

namespace App\Repository;

use App\Entity\Image;
use App\Entity\User;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Image>
 */
class ImageRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Image::class);
    }

    public function findByUser(User $user): array
    {
        return $this->createQueryBuilder('i')
            ->andWhere('i.user = :user')
            ->setParameter('user', $user)
            ->orderBy('i.date', 'DESC')
            ->addOrderBy('i.time', 'DESC')
            ->getQuery()
            ->getResult();
    }

    public function findLatestSearchesPerUser(int $limitPerUser): array
    {
        return $this->createQueryBuilder('i')
            ->orderBy('i.date', 'DESC')
            ->addOrderBy('i.time', 'DESC')
            ->setMaxResults($limitPerUser)
            ->getQuery()
            ->getResult();
    }
}
