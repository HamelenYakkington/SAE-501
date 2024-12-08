<?php

namespace App\Repository;

use App\Entity\ImageTag;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<ImageTag>
 */
class ImageTagRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, ImageTag::class);
    }

    //    /**
    //     * @return ImageTag[] Returns an array of ImageTag objects
    //     */
    //    public function findBySomeField($value): array
    //    {
    //        return $this->createQueryBuilder('i')
    //            ->andWhere('i.someField = :val')
    //            ->setParameter('val', $value)
    //            ->orderBy('i.id', 'ASC')
    //            ->setMaxResults(10)
    //            ->getQuery()
    //            ->getResult()
    //        ;
    //    }

    //    public function findByImageAndTag(int $imageId, int $tagId): ?ImageTag
    //    {
    //        return $this->createQueryBuilder('it')
    //            ->andWhere('it.image = :imageId')
    //            ->andWhere('it.tag = :tagId')
    //            ->setParameter('imageId', $imageId)
    //            ->setParameter('tagId', $tagId)
    //            ->getQuery()
    //            ->getOneOrNullResult();
    //    }
}
