<?php

namespace App\Controller;

use App\Entity\User;
use App\Repository\UserRepository;
use Doctrine\ORM\EntityManagerInterface;
use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTTokenManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Security\Http\Authentication\AuthenticationUtils;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Routing\Annotation\Route;

class SecurityController extends AbstractController
{
    private JWTTokenManagerInterface $jwtManager;
    private UserPasswordHasherInterface $passwordHasher;
    private EntityManagerInterface $entityManager;
    private UserRepository $userRepository;

    public function __construct(JWTTokenManagerInterface $jwtManager, UserPasswordHasherInterface $passwordHasher, EntityManagerInterface $entityManager, UserRepository $userRepository)
    {
        $this->jwtManager = $jwtManager;
        $this->passwordHasher = $passwordHasher;
        $this->entityManager = $entityManager;
        $this->userRepository = $userRepository;
    }

    /*
    / API to login, return an auth token if success
    */
    #[Route("/app-request/login_token", name:"api_login", methods: ["POST"])]
    public function loginToken(Request $request): JsonResponse
    {
        //Get the JSON data from the request body
        $data = json_decode($request->getContent(), true);
        
        $email = $data['email'] ?? null;
        $password = $data['password'] ?? null;
        $user = $this->entityManager->getRepository(User::class)->findOneBy(['email' => $email]);

        if (!$user || !$this->passwordHasher->isPasswordValid($user, $password)) {
            return new JsonResponse(['error' => 'Invalid credentials'], JsonResponse::HTTP_UNAUTHORIZED);
        }

        if ($user->isBanned()) {
            return new JsonResponse(['error' => "Your account is banned. Please contact support."], JsonResponse::HTTP_UNAUTHORIZED);
        }

        //Generate JWT token for the authenticated user
        $token = $this->jwtManager->create($user);

        //Store the generated JWT token in the User entity
        $user->setJwtToken($token);
        $this->entityManager->flush();

        return new JsonResponse(['token' => $token]);
    }

    /*
    / API to register a new user
    */
    #[Route("/app-request/register", name:"api_register", methods: ["POST"])]
    public function register(Request $request, UserPasswordHasherInterface $passwordHasher): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        //Validate the input
        if (!isset($data['email'], $data['password'], $data['firstName'], $data['lastName'])) {
            return new JsonResponse(['error' => 'Missing required fields'], JsonResponse::HTTP_BAD_REQUEST);
        }

        //Get the user data from the request
        $email = $data['email'];
        $plainPassword = $data['password'];
        $firstName = $data['firstName'];
        $lastName = $data['lastName'];

        //Create a new user object
        $user = new User();
        $user->setEmail($email);
        $user->setFirstName($firstName);
        $user->setLastName($lastName);

        $user->setRoles(['ROLE_USER']);

        //Hash the password
        $hashedPassword = $passwordHasher->hashPassword($user, $plainPassword);
        $user->setPassword($hashedPassword);

        $this->entityManager->persist($user);
        $this->entityManager->flush();

        return new JsonResponse(['message' => 'User registered successfully'], JsonResponse::HTTP_CREATED);
    }

    #[Route("/login", name:"login")]
    public function login(AuthenticationUtils $authenticationUtils): Response
    {
        $error = $authenticationUtils->getLastAuthenticationError();
        $lastEmail = $authenticationUtils->getLastUsername();

        return $this->render('security/login.html.twig', [
            'last_username' => $lastEmail,
            'error' => $error,
        ]);
    }

    #[Route("/logout", name:"logout")]
    public function logout()
    {
        //Logging out function is directly handled by symfony
    }

    #[Route('/api/token/validate', name: 'api_token_validate', methods: ['POST'])]
    public function validateToken(Request $request): JsonResponse
    {
        $error = null;
        $data = null;
        //Get the token from the Authorization header
        $authorizationHeader = $request->headers->get('Authorization');
        
        //Check if the header is valid and contains a token
        if (!$authorizationHeader || strpos($authorizationHeader, 'Bearer ') !== 0) {
            $error = JsonResponse::HTTP_BAD_REQUEST;
            $data = ['valid' => false, 'user' => null, 'error' => 'Invalid header or token.'];
        }

        $token = substr($authorizationHeader, 7);
        $user = $this->userRepository->findUserByJwtToken($token);

        if (!$user) {
            $error = JsonResponse::HTTP_UNAUTHORIZED;
            $data = ['valid' => false, 'user' => null, 'error' => 'No user found.'];
        }

        if ($user->isBanned()) {
            $error = JsonResponse::HTTP_UNAUTHORIZED;
            $data = ['valid' => false, 'user' => null, 'error' => "Your account is banned. Please contact support."];
        }

        if ($error) {
            return new JsonResponse($data, $error);
        }

        //Return the user data if the token is valid
        return new JsonResponse([
            'valid' => true,
            'user' => [
                'id' => $user->getId(),
                'firstname' => $user->getFirstName(),
                'lastname' => $user->getLastName(),
                'email' => $user->getEmail(),
            ]
        ]);
    }

    #[Route('/api/isadmin', name: 'api_isadmin', methods: ['POST'])]
    public function isadmin(Request $request): JsonResponse
    {
        $error = null;
        $data = null;
        //Get the token from the Authorization header
        $authorizationHeader = $request->headers->get('Authorization');
        
        //Check if the header is valid and contains a token
        if (!$authorizationHeader || strpos($authorizationHeader, 'Bearer ') !== 0) {
            $error = JsonResponse::HTTP_BAD_REQUEST;
            $data = ['valid' => false, 'user' => null, 'error' => 'Invalid header or token.'];
        }

        $token = substr($authorizationHeader, 7);
        $user = $this->userRepository->findUserByJwtToken($token);

        if (!$user) {
            $error = JsonResponse::HTTP_UNAUTHORIZED;
            $data = ['valid' => false, 'user' => null, 'error' => 'No user found.'];
        }

        if ($user->isBanned()) {
            $error = JsonResponse::HTTP_UNAUTHORIZED;
            $data = ['valid' => false, 'user' => null, 'error' => "Your account is banned. Please contact support."];
        }

        if ($error) {
            return new JsonResponse($data, $error);
        }

        //Return if the user is admin or not
        return new JsonResponse([
            'isadmin' => in_array('ROLE_ADMIN', $this->getUser()->getRoles(), true),
        ]);
    }
}
