<?php

namespace App\Controller\Admin;

use App\Entity\User;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractCrudController;
use EasyCorp\Bundle\EasyAdminBundle\Field\IdField;
use EasyCorp\Bundle\EasyAdminBundle\Field\TextField;
use EasyCorp\Bundle\EasyAdminBundle\Field\ArrayField;
use EasyCorp\Bundle\EasyAdminBundle\Field\BooleanField;
use EasyCorp\Bundle\EasyAdminBundle\Config\Actions;
use EasyCorp\Bundle\EasyAdminBundle\Config\Action;
use EasyCorp\Bundle\EasyAdminBundle\Config\Crud;
use EasyCorp\Bundle\EasyAdminBundle\Router\AdminUrlGenerator;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Doctrine\ORM\EntityManagerInterface;

class UserCrudController extends AbstractCrudController
{
    private EntityManagerInterface $entityManager;

    // Inject EntityManagerInterface
    public function __construct(EntityManagerInterface $entityManager)
    {
        $this->entityManager = $entityManager;
    }

    public static function getEntityFqcn(): string
    {
        return User::class;
    }

    public function configureFields(string $pageName): iterable
    {
        return [
            IdField::new('id')->hideOnForm(),
            
            TextField::new('firstName')
                ->setLabel('First Name')
                ->setRequired(true),

            TextField::new('lastName')
                ->setLabel('Last Name')
                ->setRequired(true),

            ArrayField::new('roles')
                ->setLabel('Roles')
                ->hideOnForm(),

            BooleanField::new('isBanned')
                ->setLabel('Banned')
                ->renderAsSwitch(false)
                ->hideOnForm(),
        ];
    }

    public function configureActions(Actions $actions): Actions
    {
        // Create the Ban/Unban action
        $banAction = Action::new('toggleBan', 'Ban/Unban')
            ->linkToCrudAction('toggleBanStatus')
            ->addCssClass('btn btn-secondary');

        $actions = $actions->add(Crud::PAGE_INDEX, $banAction);
        
        return $actions;
    }

    public function toggleBanStatus(AdminUrlGenerator $adminUrlGenerator, Request $request): RedirectResponse
    {
        $userId = $request->get('entityId');
        $user = $this->entityManager->getRepository(User::class)->find($userId);

        // If user not found, redirect back with an error
        if (!$user) {
            $this->addFlash('error', 'User not found.');
            return $this->redirectToRoute('easyadmin', ['action' => 'index']);
        }

        // Prevent banning users with the 'ROLE_ADMIN'
        if (in_array('ROLE_ADMIN', $user->getRoles())) {
            $this->addFlash('error', 'You cannot ban an admin user.');
            return $this->redirectToRoute('easyadmin', ['action' => 'index']);
        }

        $user->setIsBanned(!$user->isBanned());
        $this->entityManager->flush();

        $this->addFlash('success', sprintf(
            'User %s has been %s.',
            $user->getEmail(),
            $user->isBanned() ? 'banned' : 'unbanned'
        ));

        $url = $adminUrlGenerator->setController(UserCrudController::class)
            ->setAction(Crud::PAGE_INDEX)
            ->generateUrl();

        return $this->redirect($url);
    }
}

