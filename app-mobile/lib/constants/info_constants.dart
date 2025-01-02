import 'package:sae_501/entity/info.dart';

class InfoConstant {
  static final List<Info> infos = [
  Info("KnightSight", "Cette application est un projet étudiant BUT3 du Saulcy de Metz en France."),
  Info("Principe", "Cette application utilise un modèle IA (Yolo8) afin de détecter des objets sur un flux vidéo ou une image statique."
  "Elle permet également l'envoi de ces reconnaissances à un serveur en utilisant une API, ainsi d'autres utilisateurs pourront consulter les"
  " détections."),
  Info("API", "L'API est dockérisée et donc peut être facilement et rapidement hébergée. Elle utilise le framework PHP Symfony qui possède une"
  " communauté large et solide, des dépendances existantes et leurs documentations permettent l'implémentation facile de solutions."),
  Info("Groupe", "Le groupe d'élèves est composé de 4 étudiants, tous en développement informatique, en 3ème année.")];
}
