# PROJECT_PROGRESS_AND_TASKS.md

## 1. Résumé du projet

DEVMOB est une application mobile Flutter d'agregateur d'evenements culturels et sportifs. L'objectif est de permettre a des organisateurs de publier des evenements, et a des utilisateurs de consulter ces evenements, reserver des places, commenter et noter leur experience.

Le projet utilise actuellement :
- Flutter pour l'interface mobile.
- Firebase Core pour l'initialisation Firebase.
- Firebase Authentication pour l'inscription, la connexion et la deconnexion.
- Cloud Firestore pour stocker les profils utilisateurs et les evenements.
- Geolocator pour recuperer une position GPS lors de la creation d'un evenement.

Les roles principaux sont :
- Utilisateur : consulte les evenements, reserve des places, consulte ses reservations, commente et note.
- Organisateur : cree des evenements, consulte ses evenements, gere les informations et les places disponibles.

Etat global actuel : le projet contient une base correcte pour l'authentification, les roles et la creation d'evenements, mais il manque encore une grande partie des fonctionnalites demandees par le cahier des charges. Avant de continuer les fonctionnalites, le design des pages existantes doit etre harmonise pour obtenir une application coherente, propre et presentable.

## 2. Priorité 1 — Harmonisation du design existant

Cette etape doit etre faite avant toute nouvelle fonctionnalite. Actuellement, les vues existantes fonctionnent de maniere simple, mais elles n'utilisent pas une identite visuelle commune. Les boutons, formulaires, espacements, titres et AppBar sont geres directement dans chaque page. Cela rend l'application moins professionnelle et plus difficile a maintenir.

Harmoniser le design en premier permet de construire toutes les nouvelles pages avec les memes composants et le meme style. Cela evite de devoir refaire plusieurs fois les memes corrections UI a la fin du projet.

### Etat du design actuel

- Les pages utilisent surtout les widgets Material par defaut.
- Il n'existe pas encore de theme global dans `lib/theme/app_theme.dart` ou `lib/core/theme/app_theme.dart`.
- Il n'existe pas encore de widgets reutilisables pour les boutons, champs de formulaire, cartes ou titres de section.
- Les AppBar ne sont pas harmonisees.
- Les pages `LoginView`, `SignupView`, `OrganizerHome`, `CreateEventView` et `UserHome` ont des styles differents ou tres simples.
- Certains textes affichent des problemes d'encodage, par exemple `CrÃ©er`, `Ã©vÃ©nement`, `DÃ©connexion`.
- Les pages vides ou quasi vides ne sont pas assez soignees.

### Views existantes a modifier

- `lib/views/auth/auth_wrapper.dart`
- `lib/views/auth/login_view.dart`
- `lib/views/auth/signup_view.dart`
- `lib/views/home/role_debug_home.dart`
- `lib/views/organizer/organizer_home.dart`
- `lib/views/organizer/create_event_view.dart`
- `lib/views/user/user_home.dart`

### Composants UI communs a creer

- `lib/theme/app_theme.dart` : couleurs, typographie, AppBar, boutons, champs de formulaire.
- `lib/widgets/custom_button.dart` : bouton principal reutilisable avec etat loading.
- `lib/widgets/custom_text_field.dart` : champ de formulaire commun.
- `lib/widgets/app_scaffold.dart` : structure simple pour pages avec fond, AppBar et padding.
- `lib/widgets/section_title.dart` : titres de sections coherents.
- `lib/widgets/event_card.dart` : carte evenement reutilisable pour les listes.

### Couleurs proposees

Palette simple, moderne et realiste pour un projet etudiant :
- Couleur principale : bleu petrole `#0F766E`
- Couleur secondaire : bleu doux `#2563EB`
- Accent : orange culturel/sportif `#F97316`
- Fond application : gris tres clair `#F8FAFC`
- Texte principal : gris fonce `#111827`
- Texte secondaire : gris `#6B7280`
- Erreur : rouge `#DC2626`
- Succes : vert `#16A34A`

Cette palette evite un style trop charge et reste facile a appliquer rapidement.

### Typographie proposee

- Utiliser la typographie Material par defaut pour rester simple.
- Titres principaux : `titleLarge` ou `headlineSmall`, gras.
- Titres de sections : `titleMedium`, gras.
- Texte normal : `bodyMedium`.
- Informations secondaires : `bodySmall`, couleur grise.
- Ne pas multiplier les tailles de texte.

### Style des boutons

- Boutons principaux avec fond `#0F766E`, texte blanc, coins arrondis raisonnables.
- Boutons secondaires en `OutlinedButton`.
- Boutons d'action avec icone quand c'est utile : creation, deconnexion, localisation, reservation.
- Hauteur conseillee : 48 px minimum.
- Etat loading integre pour eviter les clics multiples.

### Style des champs de formulaire

- Champs avec bordure arrondie simple.
- Labels clairs : Email, Mot de passe, Titre, Description, Nombre de places.
- Icônes utiles : email, lock, calendar, location, event.
- Messages d'erreur courts et comprehensibles.
- Espacement vertical regulier entre les champs.

### Style des cartes

- Cartes blanches sur fond gris clair.
- Border radius simple : 8 a 12 px maximum.
- Ombre tres legere ou bordure fine.
- Carte evenement avec titre, categorie, date, lieu, places disponibles, prix et action.
- Ne pas surcharger les cartes.

### Fichiers a creer

- `lib/theme/app_theme.dart`
- `lib/widgets/custom_button.dart`
- `lib/widgets/custom_text_field.dart`
- `lib/widgets/app_scaffold.dart`
- `lib/widgets/section_title.dart`
- `lib/widgets/event_card.dart`

### Fichiers a modifier

- `lib/main.dart`
- `lib/views/auth/auth_wrapper.dart`
- `lib/views/auth/login_view.dart`
- `lib/views/auth/signup_view.dart`
- `lib/views/home/role_debug_home.dart`
- `lib/views/organizer/organizer_home.dart`
- `lib/views/organizer/create_event_view.dart`
- `lib/views/user/user_home.dart`

### Tests a faire apres modification

- Lancer `flutter pub get`.
- Lancer `flutter analyze`.
- Lancer `flutter run`.
- Tester l'inscription utilisateur.
- Tester l'inscription organisateur.
- Tester la connexion.
- Verifier la redirection selon le role.
- Ouvrir chaque page existante.
- Verifier que les boutons, champs, cartes, AppBar et espacements sont coherents.
- Verifier que les textes accentues s'affichent correctement.
- Verifier que les fonctionnalites existantes ne sont pas cassees.

### Premier commit obligatoire

#### Commit 01 — Harmoniser le design des views existantes

Objectif :
Ameliorer l'interface actuelle pour que toutes les pages existantes utilisent le meme style visuel avant d'ajouter de nouvelles fonctionnalites.

Taches :
- Creer un theme global avec couleurs, typographie, AppBar, boutons et formulaires.
- Ameliorer `LoginView`.
- Ameliorer `SignupView`.
- Ameliorer `OrganizerHome`.
- Ameliorer `CreateEventView`.
- Ameliorer `UserHome`.
- Harmoniser `AuthWrapper` et `RoleDebugHome`.
- Remplacer les styles disperses par des widgets reutilisables.
- Corriger les problemes d'encodage visibles.
- Verifier que la navigation fonctionne toujours.

Fichiers a creer :
- `lib/theme/app_theme.dart`
- `lib/widgets/custom_button.dart`
- `lib/widgets/custom_text_field.dart`
- `lib/widgets/app_scaffold.dart`
- `lib/widgets/section_title.dart`

Fichiers a modifier :
- `lib/main.dart`
- `lib/views/auth/auth_wrapper.dart`
- `lib/views/auth/login_view.dart`
- `lib/views/auth/signup_view.dart`
- `lib/views/home/role_debug_home.dart`
- `lib/views/organizer/organizer_home.dart`
- `lib/views/organizer/create_event_view.dart`
- `lib/views/user/user_home.dart`

Test :
- `flutter analyze`
- `flutter run`
- Tester inscription, connexion, redirection par role et deconnexion.
- Ouvrir chaque page existante.

Commandes Git :

```bash
git status
git add .
git commit -m "style: harmonize existing views design"
```

Critere de validation :
Toutes les views existantes ont une interface coherente et l'application fonctionne comme avant.

## 3. État actuel du projet

| Fonctionnalite | Statut | Fichiers concernes | Commentaire |
|---|---|---|---|
| Initialisation Flutter | [x] Termine | `lib/main.dart` | L'application demarre avec `Firebase.initializeApp`. |
| Configuration Firebase | [x] Termine | `lib/firebase_options.dart`, `firebase.json`, `android/app/google-services.json` | Le projet Firebase `devmob-events` est configure. |
| Firebase Auth | [x] Termine | `lib/controllers/auth_controller.dart`, `lib/models/user_model.dart` | Connexion, inscription, deconnexion, erreurs propres, profil courant et verification de role sont geres. |
| Creation du profil utilisateur | [~] Partiellement termine | `lib/controllers/auth_controller.dart`, `lib/models/user_model.dart` | Le document `users/{uid}` est cree avec email, displayName, role et createdAt. Il manque encore telephone si souhaite. |
| Gestion des roles | [x] Termine | `auth_wrapper.dart`, `auth_controller.dart`, `signup_view.dart` | Les roles `user` et `organizer` sont centralises, verifies et rediriges vers le bon espace. |
| LoginView | [~] Partiellement termine | `login_view.dart` | Fonctionnelle mais design a refaire et textes a corriger. |
| SignupView | [~] Partiellement termine | `signup_view.dart` | Fonctionnelle avec champ nom complet et creation de profil via `UserModel`. |
| AuthWrapper | [x] Termine | `auth_wrapper.dart` | Redirection par role, chargement, profil introuvable, erreur de profil et role invalide sont geres proprement. |
| OrganizerHome | [~] Partiellement termine | `organizer_home.dart` | Page basique avec creation evenement et deconnexion. Il manque la liste des evenements de l'organisateur. |
| UserHome | [~] Partiellement termine | `user_home.dart` | Affiche les evenements a venir avec loading, erreur et etat vide. Details, filtres et reservations restent a ajouter. |
| Modele Event | [x] Termine | `event_model.dart` | Champs principaux conserves, `imageUrl`, `isActive`, `updatedAt` et getters d'affichage ajoutes. |
| Creation evenement | [~] Partiellement termine | `create_event_view.dart`, `event_controller.dart` | Creation Firestore presente avec GPS, date, places et prix. Il manque design, validations avancees et gestion organisateur stricte. |
| Liste des evenements | [x] Termine | `user_home.dart`, `event_controller.dart`, `event_card.dart` | Les evenements a venir sont affiches dans l'espace utilisateur avec `EventCard`. |
| Details evenement | [x] Termine | `event_detail_view.dart`, `user_home.dart` | Page detail accessible depuis la liste avec infos, places, statut, bouton reservation placeholder et avis placeholder. |
| Reservations | [ ] Non commence | A creer | Aucun modele, controleur ou page de reservation. |
| Gestion des places disponibles | [~] Partiellement termine | `event_model.dart`, `create_event_view.dart` | Les champs existent, mais la diminution atomique lors d'une reservation manque. |
| Commentaires et avis | [ ] Non commence | A creer | Aucun modele Review ni interface de notes/commentaires. |
| Filtres | [ ] Non commence | A creer | Aucun filtre categorie/date/lieu/prix. |
| Calendrier | [ ] Non commence | A creer | Aucun affichage calendrier. |
| Securite Firestore | [ ] Non commence | Firebase Console | Les regles ne sont pas documentees dans le projet. |
| Tests adaptes | [ ] Non commence | `test/widget_test.dart` | Le test actuel est le test compteur par defaut. |
| Design global | [x] Termine | `lib/theme/app_theme.dart`, `lib/widgets/`, views existantes | Theme global et widgets UI communs crees, puis appliques aux pages existantes. |
| Structure et imports | [x] Termine | `lib/`, `test/widget_test.dart` | Arborescence verifiee, imports controles et `flutter analyze` sans erreur. |

## 4. Fonctionnalités obligatoires du cahier des charges

### Authentification

Statut actuel : [~] Partiellement termine

Deja fait :
- Inscription par email/mot de passe.
- Connexion par email/mot de passe.
- Deconnexion.
- Utilisation de Firebase Authentication.

Ce qui manque :
- Correction des textes accentues.
- Messages d'erreur plus propres.
- Chargement et validation plus uniformes.
- Eventuellement champs supplementaires : nom, prenom ou telephone.
- Tests manuels documentes.

Fichiers a creer :
- `lib/models/user_model.dart`

Fichiers a modifier :
- `lib/controllers/auth_controller.dart`
- `lib/views/auth/login_view.dart`
- `lib/views/auth/signup_view.dart`
- `lib/views/auth/auth_wrapper.dart`

Travail a faire :
- Creer un modele `UserModel` simple.
- Utiliser ce modele lors de la creation du profil Firestore.
- Ameliorer les erreurs Firebase en francais clair.
- Harmoniser le design avec les widgets communs.

Test :
- Creer un compte utilisateur.
- Creer un compte organisateur.
- Se connecter avec chaque compte.
- Tester un mot de passe incorrect.
- Tester un email deja utilise.

### Gestion des roles utilisateur/organisateur

Statut actuel : [~] Partiellement termine

Deja fait :
- Le role est choisi dans `SignupView`.
- Le role est stocke dans `users/{uid}`.
- `AuthWrapper` redirige vers `OrganizerHome` ou `UserHome`.

Ce qui manque :
- Controle strict dans Firestore Security Rules.
- Gestion du cas profil introuvable avec une UI propre.
- Gestion des roles invalides.
- Eventuellement un role admin n'est pas necessaire pour ce projet.

Fichiers a creer :
- Aucun fichier obligatoire, sauf si `UserModel` est ajoute.

Fichiers a modifier :
- `auth_wrapper.dart`
- `auth_controller.dart`
- Regles Firestore dans Firebase Console.

Travail a faire :
- Centraliser les roles avec des constantes simples.
- Verifier que seul un organisateur accede aux pages organisateur.
- Verifier que seul l'utilisateur connecte accede a ses reservations.

Test :
- Se connecter comme utilisateur.
- Verifier l'arrivee sur `UserHome`.
- Se connecter comme organisateur.
- Verifier l'arrivee sur `OrganizerHome`.

### Creation d'evenements

Statut actuel : [~] Partiellement termine

Deja fait :
- Formulaire de creation.
- Champs titre, categorie, description, date/heure, adresse, GPS, places, prix.
- Creation dans Firestore via `EventController`.

Ce qui manque :
- Design harmonise.
- Validation plus propre.
- Gestion stricte du role organisateur.
- Possibilite de voir les evenements crees.
- Eventuellement ajout d'une image ou d'un champ imageUrl.

Fichiers a creer :
- Aucun obligatoire pour la base.

Fichiers a modifier :
- `event_model.dart`
- `event_controller.dart`
- `create_event_view.dart`
- `organizer_home.dart`

Travail a faire :
- Nettoyer les textes.
- Utiliser les composants UI communs.
- Verifier que `organizerId` est toujours l'utilisateur connecte.
- Ajouter les champs manquants si necessaire : `imageUrl`, `updatedAt`, `isActive`.

Test :
- Se connecter comme organisateur.
- Creer un evenement.
- Verifier le document dans Firestore.
- Verifier que `seatsAvailable = seatsTotal`.

### Affichage des evenements

Statut actuel : [ ] Non commence

Deja fait :
- `EventController.getUpcomingEvents()` existe.

Ce qui manque :
- Liste dans `UserHome`.
- Widget `EventCard`.
- Gestion chargement, erreur et liste vide.
- Navigation vers les details.

Fichiers a creer :
- `lib/widgets/event_card.dart`
- Eventuellement `lib/views/home/event_detail_view.dart`

Fichiers a modifier :
- `lib/views/user/user_home.dart`
- `lib/controllers/event_controller.dart`

Travail a faire :
- Afficher les evenements a venir avec un `StreamBuilder`.
- Presenter chaque evenement dans une carte.
- Ajouter un message si aucun evenement n'est disponible.

Test :
- Creer un evenement organisateur.
- Se connecter comme utilisateur.
- Verifier qu'il apparait dans la liste.

### Details d'un evenement

Statut actuel : [ ] Non commence

Deja fait :
- `EventController.getEventById()` existe.

Ce qui manque :
- Page detail.
- Affichage complet : titre, description, date, lieu, categorie, prix, places, organisateur.
- Bouton reserver.
- Section commentaires et note moyenne.

Fichiers a creer :
- `lib/views/home/event_detail_view.dart`

Fichiers a modifier :
- `lib/widgets/event_card.dart`
- `lib/views/user/user_home.dart`

Travail a faire :
- Creer une page detail lisible.
- Ajouter navigation depuis la liste.
- Gerer chargement, erreur et evenement introuvable.

Test :
- Cliquer sur un evenement.
- Verifier toutes les informations.
- Tester retour vers la liste.

### Reservation de places

Statut actuel : [ ] Non commence

Deja fait :
- Aucun.

Ce qui manque :
- Modele reservation.
- Controleur reservation.
- Page de reservation.
- Bouton reserver dans le detail evenement.
- Enregistrement Firestore.

Fichiers a creer :
- `lib/models/reservation_model.dart`
- `lib/controllers/reservation_controller.dart`
- `lib/views/reservation/booking_view.dart`

Fichiers a modifier :
- `lib/views/home/event_detail_view.dart`
- `lib/controllers/event_controller.dart`
- `lib/models/event_model.dart`

Travail a faire :
- Permettre a un utilisateur de choisir un nombre de places.
- Refuser une reservation si les places sont insuffisantes.
- Enregistrer `userId`, `eventId`, `quantity`, `status`, `createdAt`.
- Utiliser une transaction Firestore pour mettre a jour les places.

Test :
- Reserver 1 place.
- Verifier la reservation dans Firestore.
- Verifier la baisse de `seatsAvailable`.
- Tester une reservation superieure aux places disponibles.

### Gestion des places disponibles

Statut actuel : [~] Partiellement termine

Deja fait :
- `seatsTotal` et `seatsAvailable` existent dans `EventModel`.

Ce qui manque :
- Mise a jour atomique lors d'une reservation.
- Blocage si l'evenement est complet.
- Affichage clair du statut.

Fichiers a creer :
- `reservation_controller.dart`

Fichiers a modifier :
- `event_model.dart`
- `event_controller.dart`
- `event_detail_view.dart`
- `event_card.dart`

Travail a faire :
- Implementer la reservation avec transaction.
- Ajouter les statuts "Disponible" et "Complet".
- Afficher les places restantes.

Test :
- Reserver jusqu'a ce que l'evenement soit complet.
- Verifier que le bouton reserver est desactive.

### Espace utilisateur

Statut actuel : [ ] Non commence

Deja fait :
- `UserHome` existe mais contient seulement un texte et deconnexion.

Ce qui manque :
- Liste des evenements.
- Navigation vers details.
- Acces a mes reservations.
- Filtres.
- Calendrier.

Fichiers a creer :
- `lib/views/user/my_reservations_view.dart`

Fichiers a modifier :
- `lib/views/user/user_home.dart`

Travail a faire :
- Transformer `UserHome` en vraie page d'accueil utilisateur.
- Ajouter les sections : evenements a venir, filtres, mes reservations.

Test :
- Se connecter comme utilisateur.
- Verifier les evenements.
- Ouvrir mes reservations.

### Espace organisateur

Statut actuel : [~] Partiellement termine

Deja fait :
- `OrganizerHome` existe.
- Bouton creer un evenement.
- Bouton deconnexion.

Ce qui manque :
- Liste des evenements crees par l'organisateur.
- Statistiques simples : nombre d'evenements, places restantes.
- Acces edition/suppression si retenu.

Fichiers a creer :
- Aucun obligatoire, sauf page detail organisateur si besoin.

Fichiers a modifier :
- `organizer_home.dart`
- `event_controller.dart`
- `event_card.dart`

Travail a faire :
- Utiliser `getOrganizerEvents`.
- Afficher les evenements de l'organisateur.
- Ajouter un etat vide propre.

Test :
- Creer deux evenements comme organisateur.
- Verifier qu'ils apparaissent dans l'espace organisateur.

### Commentaires et avis

Statut actuel : [ ] Non commence

Deja fait :
- Aucun.

Ce qui manque :
- Modele Review.
- Controleur Review.
- Interface d'ajout commentaire/note.
- Affichage des avis dans le detail evenement.

Fichiers a creer :
- `lib/models/review_model.dart`
- `lib/controllers/review_controller.dart`
- `lib/widgets/review_card.dart` si necessaire.

Fichiers a modifier :
- `event_detail_view.dart`

Travail a faire :
- Permettre a un utilisateur connecte de laisser une note de 1 a 5.
- Ajouter un commentaire texte.
- Afficher les avis par evenement.
- Calculer ou afficher la moyenne si possible.

Test :
- Ajouter un avis.
- Verifier Firestore.
- Verifier l'affichage dans la page detail.

### Filtres

Statut actuel : [ ] Non commence

Deja fait :
- Le champ categorie existe dans `EventModel`.

Ce qui manque :
- UI de filtre.
- Filtre categorie/date/prix.
- Recherche par texte si possible.

Fichiers a creer :
- Eventuellement `lib/widgets/filter_bar.dart`

Fichiers a modifier :
- `user_home.dart`
- `event_controller.dart`

Travail a faire :
- Ajouter un filtre simple par categorie.
- Ajouter un filtre gratuit/payant.
- Ajouter une recherche par titre si le temps le permet.

Test :
- Creer plusieurs evenements.
- Filtrer par Culture, Sport, Autre.

### Calendrier

Statut actuel : [ ] Non commence

Deja fait :
- Les evenements ont une date.

Ce qui manque :
- Vue calendrier ou filtre par jour.
- Eventuellement package `table_calendar`.

Fichiers a creer :
- `lib/views/user/calendar_view.dart`

Fichiers a modifier :
- `pubspec.yaml` si un package calendrier est ajoute.
- `user_home.dart`

Travail a faire :
- Pour rester simple, commencer par une vue liste filtree par date.
- Ajouter un vrai calendrier uniquement si le temps le permet.

Test :
- Selectionner une date.
- Verifier que les evenements du jour s'affichent.

### Securite et droits d'acces

Statut actuel : [ ] Non commence

Deja fait :
- Aucun fichier de regles visible dans le projet.

Ce qui manque :
- Regles Firestore adaptees.
- Verification manuelle dans Firebase Console.

Fichiers a creer :
- Optionnel : `firestore.rules`

Fichiers a modifier :
- Firebase Console.

Travail a faire :
- Autoriser la lecture des evenements aux utilisateurs connectes.
- Autoriser la creation d'evenements seulement aux organisateurs.
- Autoriser la modification d'un evenement seulement a son organisateur.
- Autoriser un utilisateur a gerer ses propres reservations.
- Autoriser un utilisateur connecte a creer un avis.

Test :
- Tester avec compte utilisateur et organisateur.
- Verifier qu'un utilisateur classique ne peut pas creer d'evenement.

### Maquette visuelle

Statut actuel : [ ] Non commence

Deja fait :
- Aucune maquette specifique identifiee.

Ce qui manque :
- Captures ou maquettes des ecrans principaux.

Fichiers a creer :
- Dossier optionnel `docs/mockups/` ou captures dans un dossier de rendu.

Travail a faire :
- Capturer accueil, detail evenement, reservation, creation evenement.
- S'assurer que les captures correspondent au design final.

Test :
- Comparer les captures au cahier des charges.

### Demonstration finale

Statut actuel : [ ] Non commence

Deja fait :
- Base technique preparee.

Ce qui manque :
- Scenario de demo.
- Donnees de test.
- APK ou execution sur emulateur.

Travail a faire :
- Preparer deux comptes : utilisateur et organisateur.
- Creer quelques evenements.
- Montrer creation, consultation, reservation, avis, filtres.

Test :
- Rejouer la demo complete avant presentation.

## 5. Architecture recommandée du projet

Architecture conseillee, simple et compatible avec un bon projet etudiant :

```text
lib/
├── models/
├── controllers/
├── views/
│   ├── auth/
│   ├── home/
│   ├── organizer/
│   ├── reservation/
│   └── user/
├── widgets/
├── theme/
└── main.dart
```

Role des dossiers :
- `models/` : classes de donnees utilisees avec Firestore, comme `EventModel`, `UserModel`, `ReservationModel`, `ReviewModel`.
- `controllers/` : logique Firebase et operations principales, comme authentification, evenements, reservations et avis.
- `views/` : ecrans Flutter de l'application, separes par role ou domaine.
- `widgets/` : composants reutilisables comme boutons, champs, cartes et titres.
- `theme/` : theme global de l'application.
- `main.dart` : initialisation Firebase et lancement de l'application.

Recommandation :
- Ne pas faire une Clean Architecture trop avancee avec repositories, use cases et dependency injection. Ce serait trop lourd pour ce projet.
- Garder une separation claire entre UI, modeles et controleurs.
- Eviter de deplacer trop de fichiers existants au debut. Il vaut mieux stabiliser l'existant puis ajouter les dossiers manquants.

Fichiers a ajouter progressivement :
- `lib/theme/app_theme.dart`
- `lib/models/user_model.dart`
- `lib/models/reservation_model.dart`
- `lib/models/review_model.dart`
- `lib/controllers/reservation_controller.dart`
- `lib/controllers/review_controller.dart`
- `lib/views/home/event_detail_view.dart`
- `lib/views/reservation/booking_view.dart`
- `lib/views/user/my_reservations_view.dart`
- `lib/views/user/calendar_view.dart`

## 6. Modèle Firebase / Firestore recommandé

### Collection `users`

Chemin : `users/{uid}`

Champs :
- `uid` : string
- `email` : string
- `displayName` : string
- `role` : string, valeurs `user` ou `organizer`
- `phone` : string optionnel
- `createdAt` : timestamp

Exemple :

```json
{
  "uid": "abc123",
  "email": "user@test.com",
  "displayName": "Ala",
  "role": "user",
  "phone": "",
  "createdAt": "serverTimestamp"
}
```

Relation :
- Un utilisateur peut avoir plusieurs reservations.
- Un organisateur peut avoir plusieurs evenements.

### Collection `events`

Chemin : `events/{eventId}`

Champs :
- `organizerId` : string
- `title` : string
- `category` : string
- `description` : string
- `dateTime` : timestamp
- `address` : string
- `latitude` : number
- `longitude` : number
- `seatsTotal` : number
- `seatsAvailable` : number
- `price` : number ou null
- `imageUrl` : string optionnel
- `isActive` : boolean
- `createdAt` : timestamp
- `updatedAt` : timestamp optionnel

Exemple :

```json
{
  "organizerId": "org123",
  "title": "Concert local",
  "category": "Culture",
  "description": "Concert musical ouvert au public.",
  "dateTime": "timestamp",
  "address": "Tunis",
  "latitude": 36.8065,
  "longitude": 10.1815,
  "seatsTotal": 100,
  "seatsAvailable": 80,
  "price": 15,
  "imageUrl": "",
  "isActive": true,
  "createdAt": "serverTimestamp"
}
```

Relation :
- Un evenement appartient a un organisateur.
- Un evenement peut avoir plusieurs reservations.
- Un evenement peut avoir plusieurs avis.

### Collection `reservations`

Chemin : `reservations/{reservationId}`

Champs :
- `userId` : string
- `eventId` : string
- `organizerId` : string
- `quantity` : number
- `status` : string, par exemple `confirmed` ou `cancelled`
- `createdAt` : timestamp

Exemple :

```json
{
  "userId": "user123",
  "eventId": "event123",
  "organizerId": "org123",
  "quantity": 2,
  "status": "confirmed",
  "createdAt": "serverTimestamp"
}
```

Relation :
- Une reservation appartient a un utilisateur.
- Une reservation concerne un evenement.

### Collection `reviews`

Chemin : `reviews/{reviewId}`

Champs :
- `userId` : string
- `eventId` : string
- `rating` : number de 1 a 5
- `comment` : string
- `createdAt` : timestamp

Exemple :

```json
{
  "userId": "user123",
  "eventId": "event123",
  "rating": 5,
  "comment": "Tres bon evenement.",
  "createdAt": "serverTimestamp"
}
```

Relation :
- Un avis appartient a un utilisateur.
- Un avis concerne un evenement.

## 7. Règles de sécurité Firebase

Regles Firestore recommandees :

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }

    function userDoc() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid));
    }

    function isOrganizer() {
      return isSignedIn() && userDoc().data.role == "organizer";
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
      allow delete: if false;
    }

    match /events/{eventId} {
      allow read: if isSignedIn();
      allow create: if isOrganizer()
        && request.resource.data.organizerId == request.auth.uid;
      allow update, delete: if isOrganizer()
        && resource.data.organizerId == request.auth.uid;
    }

    match /reservations/{reservationId} {
      allow create: if isSignedIn()
        && request.resource.data.userId == request.auth.uid;
      allow read: if isSignedIn()
        && resource.data.userId == request.auth.uid;
      allow update, delete: if isSignedIn()
        && resource.data.userId == request.auth.uid;
    }

    match /reviews/{reviewId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn()
        && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isSignedIn()
        && resource.data.userId == request.auth.uid;
    }
  }
}
```

Ce qu'il faut faire manuellement dans Firebase Console :
- Ouvrir Firebase Console.
- Selectionner le projet `devmob-events`.
- Aller dans Firestore Database.
- Ouvrir l'onglet Rules.
- Coller les regles.
- Publier.
- Tester avec un compte utilisateur et un compte organisateur.

Important :
- Ces regles sont une bonne base pour un projet etudiant.
- Elles ne remplacent pas toutes les validations cote application.
- La reservation doit aussi verifier les places disponibles dans une transaction Firestore.

## 8. Liste détaillée des tâches restantes

### Tâche 1 — Harmoniser le design existant

Statut : [x] Termine

Objectif :
Donner une identite visuelle coherente a toutes les pages deja creees.

Description :
Creer un theme global et des widgets UI reutilisables, puis les appliquer aux vues existantes avant d'ajouter de nouvelles fonctionnalites.

Sous-taches :
- Creer `app_theme.dart`.
- Creer `custom_button.dart`.
- Creer `custom_text_field.dart`.
- Creer `app_scaffold.dart`.
- Creer `section_title.dart`.
- Modifier `main.dart` pour utiliser le theme.
- Refaire le style de `LoginView`.
- Refaire le style de `SignupView`.
- Refaire le style de `OrganizerHome`.
- Refaire le style de `CreateEventView`.
- Refaire le style de `UserHome`.
- Corriger les textes mal encodes.

Fichiers a creer :
- `lib/theme/app_theme.dart`
- `lib/widgets/custom_button.dart`
- `lib/widgets/custom_text_field.dart`
- `lib/widgets/app_scaffold.dart`
- `lib/widgets/section_title.dart`

Fichiers a modifier :
- `lib/main.dart`
- `lib/views/auth/auth_wrapper.dart`
- `lib/views/auth/login_view.dart`
- `lib/views/auth/signup_view.dart`
- `lib/views/home/role_debug_home.dart`
- `lib/views/organizer/organizer_home.dart`
- `lib/views/organizer/create_event_view.dart`
- `lib/views/user/user_home.dart`

Configuration manuelle :
- Aucune.

Test :
- `flutter analyze`
- `flutter run`
- Tester inscription, connexion, roles et deconnexion.

Resultat obtenu :
Les pages existantes utilisent une interface coherente avec theme global, composants communs, cartes, boutons harmonises, textes corriges et etats vides propres.

### Tâche 2 — Creer les widgets UI reutilisables

Statut : [x] Termine

Objectif :
Eviter la repetition du code UI.

Sous-taches :
- [x] Finaliser `CustomButton` avec loading, icone et largeur pleine.
- [x] Finaliser `CustomTextField` avec label, icon, validator, obscureText, readOnly et options de saisie.
- [x] Finaliser `AppScaffold` avec AppBar, fond, padding, contenu centre et support FloatingActionButton.
- [x] Finaliser `SectionTitle` avec titre, sous-titre et action optionnelle.
- [x] Ajouter `EventCard` avec titre, categorie, date/heure, lieu, places, prix et badge statut.

Fichiers a creer :
- `lib/widgets/custom_button.dart`
- `lib/widgets/custom_text_field.dart`
- `lib/widgets/app_scaffold.dart`
- `lib/widgets/section_title.dart`
- `lib/widgets/event_card.dart`

Fichiers a modifier :
- Les views existantes.

Configuration manuelle :
- Aucune.

Test :
- `flutter analyze` execute avec succes.
- Verifier visuellement chaque page.
- Verifier qu'aucun import inutile ne reste.

Resultat obtenu :
Les composants UI communs existent dans `lib/widgets/` et peuvent etre reutilises pour les prochaines pages.

### Tâche 3 — Nettoyer la structure et les imports

Statut : [x] Termine

Objectif :
Rendre l'arborescence claire avant les nouvelles fonctionnalites.

Sous-taches :
- Verifier les dossiers `models`, `controllers`, `views`, `widgets`, `theme`.
- Corriger les imports.
- Supprimer uniquement les imports inutiles.
- Ne pas supprimer du code existant sans raison.
- Remplacer le test compteur par un test adapte plus tard.

Fichiers a creer :
- Aucun obligatoire.

Fichiers a modifier :
- `lib/main.dart`
- Fichiers avec imports inutiles.

Configuration manuelle :
- Aucune.

Test :
- `flutter analyze` execute avec succes.

Resultat attendu :
Le projet reste simple, lisible et sans erreurs d'analyse.

Resultat obtenu :
Les dossiers `models`, `controllers`, `views`, `widgets` et `theme` sont en place, les imports ont ete verifies, aucun import inutile n'a ete detecte par l'analyseur et le projet passe `flutter analyze` sans erreur.

### Tâche 4 — Ameliorer le modele Event

Statut : [x] Termine

Objectif :
Completer `EventModel` pour supporter liste, detail, reservation et affichage propre.

Sous-taches :
- [x] Garder les champs existants.
- [x] Ajouter `imageUrl`, `isActive`, `updatedAt`.
- [x] Verifier conversion Firestore `Timestamp`.
- [x] Ajouter getters utiles : prix affiche, date affichee, lieu, places et statut.
- [x] Garder un modele simple.

Fichiers a creer :
- Aucun.

Fichiers a modifier :
- `lib/models/event_model.dart`
- `lib/controllers/event_controller.dart`
- `lib/widgets/event_card.dart`

Configuration manuelle :
- Verifier que les anciens documents Firestore restent compatibles.

Test :
- `flutter analyze` execute avec succes.
- Creation et lecture Firestore gardent les anciens champs compatibles.

Resultat obtenu :
Le modele Event supporte les ecrans a venir avec des champs optionnels compatibles Firestore, des getters d'affichage reutilisables et un statut clair sans casser la creation actuelle.

### Tâche 5 — Ajouter le modele User

Statut : [x] Termine

Objectif :
Centraliser les donnees utilisateur.

Sous-taches :
- [x] Creer `UserModel`.
- [x] Ajouter `uid`, `email`, `displayName`, `role`, `createdAt`.
- [x] Ajouter `fromMap` et `toMap`.
- [x] Utiliser ce modele dans `AuthController`.
- [x] Ajouter le champ nom complet dans `SignupView`.

Fichiers a creer :
- `lib/models/user_model.dart`

Fichiers a modifier :
- `lib/controllers/auth_controller.dart`
- `lib/views/auth/signup_view.dart`

Configuration manuelle :
- Aucun changement obligatoire.

Test :
- `flutter analyze` execute avec succes.
- Le document `users/{uid}` est cree avec `email`, `displayName`, `role` et `createdAt`.

Resultat obtenu :
Les profils utilisateurs sont centralises dans `UserModel`, la creation de compte utilise ce modele et l'inscription collecte maintenant le nom complet.

### Tâche 6 — Corriger et ameliorer AuthController

Statut : [x] Termine

Objectif :
Rendre l'authentification plus propre.

Sous-taches :
- [x] Corriger les messages d'erreur principaux.
- [x] Utiliser `UserModel`.
- [x] Ajouter une methode pour recuperer le profil courant.
- [x] Ajouter une methode pour verifier le role.
- [x] Garder les retours d'erreur simples.
- [x] Ajouter une gestion plus sure des erreurs Firebase et reseau.

Fichiers a creer :
- Aucun.

Fichiers a modifier :
- `lib/controllers/auth_controller.dart`

Configuration manuelle :
- Verifier Email/Password dans Firebase Authentication.

Test :
- `flutter analyze` execute avec succes.
- Login, signup, logout et erreurs Firebase restent couverts par `AuthController`.

Resultat obtenu :
`AuthController` centralise les roles, cree les profils avec `UserModel`, expose le profil courant, verifie les roles et retourne des messages d'erreur simples pour Auth, Firestore et le reseau.

### Tâche 7 — Gestion complete des roles

Statut : [x] Termine

Objectif :
Assurer une separation claire entre utilisateur et organisateur.

Sous-taches :
- [x] Centraliser les valeurs `user` et `organizer`.
- [x] Ameliorer `AuthWrapper`.
- [x] Ajouter affichage propre pendant le chargement.
- [x] Ajouter affichage propre si profil introuvable.
- [x] Gerer les roles invalides.
- [x] Prevoir les regles Firestore pour une tache ulterieure.

Fichiers a creer :
- Aucun obligatoire.

Fichiers a modifier :
- `lib/views/auth/auth_wrapper.dart`
- `lib/controllers/auth_controller.dart`

Configuration manuelle :
- Firestore Rules.

Test :
- `flutter analyze` execute avec succes.
- Redirection utilisateur et organisateur geree via `UserModel`.

Resultat obtenu :
Les roles sont centralises dans `AuthController`, `AuthWrapper` lit le profil via `UserModel`, refuse les roles invalides et envoie chaque role reconnu vers son espace.

### Tâche 8 — Ameliorer AuthWrapper

Statut : [x] Termine

Objectif :
Eviter les ecrans bruts pendant chargement ou erreur.

Sous-taches :
- [x] Utiliser `AppScaffold`.
- [x] Afficher un loader centre propre.
- [x] Afficher une page d'erreur simple si profil introuvable.
- [x] Ajouter bouton deconnexion si profil manquant.
- [x] Ajouter une page d'erreur simple si le profil ne charge pas.

Fichiers a modifier :
- `lib/views/auth/auth_wrapper.dart`

Test :
- `flutter analyze` execute avec succes.
- Connexion normale, profil manquant, erreur de chargement et role invalide ont maintenant des vues propres.

Resultat obtenu :
`AuthWrapper` n'affiche plus d'ecran brut pendant l'authentification et utilise des etats UI coherents pour chargement, profil manquant, erreur et role invalide.

### Tâche 9 — Creer EventCard

Statut : [x] Termine

Objectif :
Afficher un evenement de facon reutilisable.

Sous-taches :
- [x] Afficher titre, categorie, date, adresse, places, prix.
- [x] Ajouter un badge complet/disponible.
- [x] Ajouter un callback `onTap`.
- [x] Utiliser le theme global.
- [x] Gerer les textes longs et l'affordance de navigation.

Fichiers a creer :
- `lib/widgets/event_card.dart`

Fichiers a modifier :
- Aucun pour cette tache. L'integration dans les listes reste prevue aux taches 10 et 13.

Test :
- `flutter analyze` execute avec succes.
- La carte est prete a etre affichee dans les listes utilisateur et organisateur.

Resultat obtenu :
`EventCard` est reutilisable, affiche les informations essentielles avec badges, limite les textes longs et expose `onTap` pour la navigation future.

### Tâche 10 — Liste des evenements utilisateur

Statut : [x] Termine

Objectif :
Permettre a l'utilisateur de consulter les evenements a venir.

Sous-taches :
- [x] Utiliser `EventController.getUpcomingEvents`.
- [x] Ajouter `StreamBuilder`.
- [x] Afficher `EventCard`.
- [x] Gerer loading, erreur, liste vide.
- [x] Ajouter une action `onTap` temporaire en attendant la page detail.

Fichiers a creer :
- Aucun si `EventCard` existe.

Fichiers a modifier :
- `lib/views/user/user_home.dart`

Configuration manuelle :
- Creer quelques evenements dans l'app ou Firestore.

Test :
- `flutter analyze` execute avec succes.
- Se connecter comme utilisateur et verifier que la liste apparait.

Resultat obtenu :
`UserHome` affiche les evenements a venir avec `EventCard`, gere les etats loading/erreur/vide et prepare le clic vers la future page detail de la tache 11.

### Tâche 11 — Page details evenement

Statut : [x] Termine

Objectif :
Afficher toutes les informations d'un evenement.

Sous-taches :
- [x] Creer `event_detail_view.dart`.
- [x] Afficher titre, description, categorie, date, lieu, prix, places.
- [x] Ajouter bouton reserver placeholder.
- [x] Ajouter section avis placeholder.
- [x] Gerer evenement complet.

Fichiers a creer :
- `lib/views/home/event_detail_view.dart`

Fichiers a modifier :
- `lib/widgets/event_card.dart`
- `lib/views/user/user_home.dart`

Test :
- `flutter analyze` execute avec succes.
- Ouvrir un evenement depuis la liste et verifier les informations.

Resultat obtenu :
L'utilisateur peut ouvrir un evenement depuis `UserHome` et consulter toutes les informations principales dans une page detail propre.

### Tâche 12 — Creation evenement amelioree

Statut : [~] Partiellement termine

Objectif :
Rendre la creation evenement plus fiable et plus belle.

Sous-taches :
- Appliquer le design global.
- Corriger les textes.
- Ajouter validations plus propres.
- Ajouter message succes.
- Verifier GPS.
- Verifier dates futures uniquement.

Fichiers a modifier :
- `lib/views/organizer/create_event_view.dart`
- `lib/controllers/event_controller.dart`

Test :
- Creer un evenement complet.
- Tester formulaire vide.
- Tester nombre de places invalide.

Resultat attendu :
La creation est propre, stable et presentable.

### Tâche 13 — Mes evenements organisateur

Statut : [ ] Non commence

Objectif :
Afficher les evenements crees par l'organisateur connecte.

Sous-taches :
- Utiliser `getOrganizerEvents`.
- Ajouter une liste dans `OrganizerHome`.
- Afficher `EventCard`.
- Ajouter etat vide.

Fichiers a modifier :
- `lib/views/organizer/organizer_home.dart`
- `lib/controllers/event_controller.dart`

Test :
- Creer un evenement.
- Revenir sur l'espace organisateur.
- Verifier qu'il apparait.

Resultat attendu :
L'organisateur voit ses evenements.

### Tâche 14 — Ajouter ReservationModel

Statut : [ ] Non commence

Objectif :
Representer une reservation dans le code.

Sous-taches :
- Creer `ReservationModel`.
- Ajouter `id`, `userId`, `eventId`, `organizerId`, `quantity`, `status`, `createdAt`.
- Ajouter `fromMap` et `toMap`.

Fichiers a creer :
- `lib/models/reservation_model.dart`

Fichiers a modifier :
- Aucun obligatoire.

Test :
- Verifier compilation.

Resultat attendu :
Les reservations ont un modele clair.

### Tâche 15 — Ajouter ReservationController

Statut : [ ] Non commence

Objectif :
Gerer les reservations avec Firestore.

Sous-taches :
- Creer `ReservationController`.
- Ajouter `createReservation`.
- Utiliser transaction Firestore.
- Diminuer `seatsAvailable`.
- Ajouter `getUserReservations`.
- Refuser si places insuffisantes.

Fichiers a creer :
- `lib/controllers/reservation_controller.dart`

Fichiers a modifier :
- `lib/controllers/event_controller.dart` si necessaire.

Configuration manuelle :
- Verifier collection `reservations`.
- Verifier regles Firestore.

Test :
- Reserver.
- Verifier Firestore.
- Verifier places disponibles.

Resultat attendu :
La reservation fonctionne sans incoherence de places.

### Tâche 16 — Page reservation

Statut : [ ] Non commence

Objectif :
Permettre a l'utilisateur de choisir le nombre de places.

Sous-taches :
- Creer `BookingView`.
- Afficher resume evenement.
- Ajouter champ quantite.
- Ajouter bouton confirmer.
- Afficher erreurs.

Fichiers a creer :
- `lib/views/reservation/booking_view.dart`

Fichiers a modifier :
- `lib/views/home/event_detail_view.dart`

Test :
- Reserver 1 place.
- Reserver plusieurs places.
- Tester trop de places.

Resultat attendu :
L'utilisateur peut reserver simplement.

### Tâche 17 — Mes reservations

Statut : [ ] Non commence

Objectif :
Permettre a l'utilisateur de consulter ses reservations.

Sous-taches :
- Creer `my_reservations_view.dart`.
- Lire les reservations de l'utilisateur.
- Afficher evenement, quantite et statut.
- Ajouter etat vide.

Fichiers a creer :
- `lib/views/user/my_reservations_view.dart`

Fichiers a modifier :
- `lib/controllers/reservation_controller.dart`
- `lib/views/user/user_home.dart`

Test :
- Faire une reservation.
- Ouvrir Mes reservations.

Resultat attendu :
L'utilisateur retrouve ses reservations.

### Tâche 18 — Gestion complete des places

Statut : [~] Partiellement termine

Objectif :
Eviter les reservations impossibles.

Sous-taches :
- Utiliser transaction.
- Bloquer si `seatsAvailable <= 0`.
- Bloquer si quantite superieure aux places.
- Afficher evenement complet.

Fichiers a modifier :
- `reservation_controller.dart`
- `event_detail_view.dart`
- `event_card.dart`

Test :
- Reserver toutes les places.
- Verifier bouton desactive.

Resultat attendu :
Les places restent toujours coherentes.

### Tâche 19 — Ajouter ReviewModel

Statut : [ ] Non commence

Objectif :
Representer les avis utilisateurs.

Sous-taches :
- Creer `ReviewModel`.
- Ajouter `id`, `userId`, `eventId`, `rating`, `comment`, `createdAt`.
- Ajouter validations simples.

Fichiers a creer :
- `lib/models/review_model.dart`

Test :
- Verifier compilation.

Resultat attendu :
Les avis ont un modele clair.

### Tâche 20 — Commentaires et notation

Statut : [ ] Non commence

Objectif :
Permettre aux utilisateurs de noter et commenter un evenement.

Sous-taches :
- Creer `ReviewController`.
- Ajouter formulaire avis dans detail evenement.
- Afficher liste des avis.
- Afficher note moyenne si possible.

Fichiers a creer :
- `lib/controllers/review_controller.dart`

Fichiers a modifier :
- `lib/views/home/event_detail_view.dart`

Configuration manuelle :
- Verifier collection `reviews`.
- Verifier regles Firestore.

Test :
- Ajouter un avis.
- Verifier Firestore.
- Verifier affichage.

Resultat attendu :
Les avis sont visibles sur les evenements.

### Tâche 21 — Filtres evenements

Statut : [ ] Non commence

Objectif :
Faciliter la recherche d'evenements.

Sous-taches :
- Ajouter filtre categorie.
- Ajouter filtre gratuit/payant.
- Ajouter recherche par titre si temps disponible.
- Garder l'UI simple.

Fichiers a modifier :
- `lib/views/user/user_home.dart`
- `lib/controllers/event_controller.dart`

Test :
- Creer evenements de categories differentes.
- Tester les filtres.

Resultat attendu :
L'utilisateur trouve plus facilement un evenement.

### Tâche 22 — Calendrier evenements

Statut : [ ] Non commence

Objectif :
Afficher les evenements par date.

Sous-taches :
- Creer vue calendrier simple.
- Ajouter selection de date.
- Afficher evenements du jour.
- Ajouter package calendrier seulement si necessaire.

Fichiers a creer :
- `lib/views/user/calendar_view.dart`

Fichiers a modifier :
- `pubspec.yaml` si package ajoute.
- `lib/views/user/user_home.dart`

Test :
- Selectionner une date avec evenement.
- Selectionner une date sans evenement.

Resultat attendu :
L'utilisateur peut consulter les evenements par date.

### Tâche 23 — Regles de securite Firestore

Statut : [ ] Non commence

Objectif :
Protegger les donnees selon les roles.

Sous-taches :
- Ajouter les regles dans Firebase Console.
- Tester utilisateur classique.
- Tester organisateur.
- Documenter les regles.

Fichiers a creer :
- Optionnel : `firestore.rules`

Configuration manuelle :
- Firebase Console > Firestore Database > Rules.

Test :
- Utilisateur ne peut pas creer d'evenement.
- Organisateur peut creer son evenement.

Resultat attendu :
Les droits d'acces respectent le cahier des charges.

### Tâche 24 — UI finale

Statut : [ ] Non commence

Objectif :
Polir l'interface apres les fonctionnalites.

Sous-taches :
- Verifier chaque page.
- Harmoniser textes et icones.
- Ajouter pages vides propres.
- Verifier navigation.
- Verifier responsive mobile.

Fichiers a modifier :
- Toutes les views si necessaire.

Test :
- Parcours complet utilisateur.
- Parcours complet organisateur.

Resultat attendu :
L'application est propre pour la demonstration.

### Tâche 25 — Tests et correction finale

Statut : [ ] Non commence

Objectif :
Stabiliser le projet.

Sous-taches :
- Remplacer `widget_test.dart`.
- Lancer `flutter analyze`.
- Lancer `flutter test`.
- Corriger warnings et erreurs.
- Tester manuellement toutes les fonctionnalites.

Fichiers a modifier :
- `test/widget_test.dart`
- Fichiers necessaires selon erreurs.

Test :
- `flutter analyze`
- `flutter test`
- `flutter run`

Resultat attendu :
Le projet est pret pour rendu.

### Tâche 26 — Preparation APK et demonstration

Statut : [ ] Non commence

Objectif :
Preparer la presentation finale.

Sous-taches :
- Preparer donnees de test.
- Preparer comptes utilisateur et organisateur.
- Preparer scenario de demo.
- Generer APK si demande.
- Capturer les ecrans obligatoires.

Fichiers a modifier :
- Aucun obligatoire.

Configuration manuelle :
- Verifier Firebase.
- Verifier Android.

Test :
- Rejouer la demo complete.

Resultat attendu :
Le projet peut etre presente sans improvisation.

## 9. Plan de commits Git

### Commit 01 — Harmoniser le design des views existantes

Statut : [x] Termine

Objectif :
Appliquer une identite visuelle commune aux pages deja creees.

Taches :
- Creer un theme global.
- Ameliorer LoginView, SignupView, OrganizerHome, CreateEventView et UserHome.
- Corriger les textes mal encodes.

Fichiers touches :
- `lib/main.dart`
- `lib/theme/app_theme.dart`
- `lib/views/auth/login_view.dart`
- `lib/views/auth/signup_view.dart`
- `lib/views/home/role_debug_home.dart`
- `lib/views/organizer/organizer_home.dart`
- `lib/views/organizer/create_event_view.dart`
- `lib/views/user/user_home.dart`

Test :
- `flutter analyze`
- `flutter run`

Commandes Git :

```bash
git status
git add .
git commit -m "style: harmonize existing views design"
```

Critere de validation :
Les vues existantes sont coherentes et fonctionnent comme avant.

### Commit 02 — Creer les widgets UI reutilisables

Statut : [x] Termine

Objectif :
Centraliser les composants UI communs.

Taches :
- Creer `CustomButton`.
- Creer `CustomTextField`.
- Creer `AppScaffold`.
- Creer `SectionTitle`.

Fichiers touches :
- `lib/widgets/custom_button.dart`
- `lib/widgets/custom_text_field.dart`
- `lib/widgets/app_scaffold.dart`
- `lib/widgets/section_title.dart`

Test :
- `flutter analyze`
- Verifier chaque page existante.

Commandes Git :

```bash
git status
git add .
git commit -m "style: add reusable UI widgets"
```

Critere de validation :
Les composants sont reutilisables et ne cassent pas l'UI.

### Commit 03 — Nettoyer la structure et corriger les imports

Statut : [x] Termine

Objectif :
Stabiliser l'arborescence.

Taches :
- Verifier dossiers.
- Corriger imports.
- Supprimer imports inutiles.

Fichiers touches :
- `PROJECT_PROGRESS_AND_TASKS.md`

Test :
- `flutter analyze` execute avec succes.

Commandes Git :

```bash
git status
git add .
git commit -m "chore: clean project structure and imports"
```

Critere de validation :
Le projet analyse sans erreur.

### Commit 04 — Ameliorer le modele Event

Statut : [x] Termine

Objectif :
Preparer les evenements pour liste, detail et reservation.

Taches :
- [x] Completer `EventModel`.
- [x] Ajouter getters utiles.
- [x] Garder compatibilite Firestore.

Fichiers touches :
- `lib/models/event_model.dart`
- `lib/controllers/event_controller.dart`
- `lib/widgets/event_card.dart`

Test :
- `flutter analyze` execute avec succes.
- Creation evenement gardee compatible.

Commandes Git :

```bash
git status
git add .
git commit -m "refactor: improve event model"
```

Critere de validation :
Les evenements existants restent lisibles.

### Commit 05 — Ajouter le modele User

Statut : [x] Termine

Objectif :
Centraliser les profils utilisateurs.

Taches :
- [x] Creer `UserModel`.
- [x] Ajouter mapping Firestore.
- [x] Utiliser `UserModel` dans `AuthController`.
- [x] Ajouter `displayName` dans `SignupView`.

Fichiers touches :
- `lib/models/user_model.dart`
- `lib/controllers/auth_controller.dart`
- `lib/views/auth/signup_view.dart`

Test :
- `flutter analyze` execute avec succes.

Commandes Git :

```bash
git status
git add .
git commit -m "feat: add user model"
```

Critere de validation :
Le modele compile et represente `users/{uid}`.

### Commit 06 — Corriger AuthController

Statut : [x] Termine

Objectif :
Nettoyer l'authentification.

Taches :
- [x] Utiliser `UserModel`.
- [x] Corriger les erreurs en francais.
- [x] Ajouter recuperation profil.
- [x] Ajouter verification de role.

Fichiers touches :
- `lib/controllers/auth_controller.dart`

Test :
- `flutter analyze` execute avec succes.
- Signup, login et logout restent geres par `AuthController`.

Commandes Git :

```bash
git status
git add .
git commit -m "refactor: improve auth controller"
```

Critere de validation :
L'authentification fonctionne toujours.

### Commit 07 — Gerer completement les roles

Statut : [x] Termine

Objectif :
Stabiliser la redirection utilisateur/organisateur.

Taches :
- [x] Ameliorer lecture du role.
- [x] Gerer role manquant.
- [x] Gerer profil manquant.
- [x] Gerer role invalide.

Fichiers touches :
- `lib/views/auth/auth_wrapper.dart`
- `lib/controllers/auth_controller.dart`

Test :
- `flutter analyze` execute avec succes.
- Connexion utilisateur et organisateur routees par `AuthWrapper`.

Commandes Git :

```bash
git status
git add .
git commit -m "feat: complete role based navigation"
```

Critere de validation :
Chaque role arrive dans le bon espace.

### Commit 08 — Ameliorer AuthWrapper

Statut : [x] Termine

Objectif :
Rendre les etats de chargement et erreur propres.

Taches :
- [x] Loader propre.
- [x] Message profil introuvable.
- [x] Message erreur de chargement.
- [x] Message role invalide.
- [x] Bouton deconnexion si besoin.

Fichiers touches :
- `lib/views/auth/auth_wrapper.dart`

Test :
- `flutter analyze` execute avec succes.
- Tester connexion.

Commandes Git :

```bash
git status
git add .
git commit -m "style: improve auth wrapper states"
```

Critere de validation :
Aucun ecran brut pendant l'authentification.

### Commit 09 — Creer EventCard

Statut : [x] Termine

Objectif :
Preparer l'affichage des evenements.

Taches :
- [x] Creer carte evenement.
- [x] Afficher titre, date, categorie, lieu, places, prix.
- [x] Ajouter badges statut, categorie et prix.
- [x] Ajouter callback `onTap`.

Fichiers touches :
- `lib/widgets/event_card.dart`

Test :
- `flutter analyze` execute avec succes.

Commandes Git :

```bash
git status
git add .
git commit -m "feat: add event card widget"
```

Critere de validation :
La carte evenement est reutilisable.

### Commit 10 — Ajouter la liste des evenements

Statut : [x] Termine

Objectif :
Afficher les evenements dans l'espace utilisateur.

Taches :
- [x] Utiliser `getUpcomingEvents`.
- [x] Ajouter `StreamBuilder`.
- [x] Afficher `EventCard`.
- [x] Gerer loading, erreur et vide.

Fichiers touches :
- `lib/views/user/user_home.dart`
- `lib/controllers/event_controller.dart`

Test :
- `flutter analyze` execute avec succes.
- Creer evenement puis le voir comme utilisateur.

Commandes Git :

```bash
git status
git add .
git commit -m "feat: show upcoming events"
```

Critere de validation :
Les evenements a venir s'affichent.

### Commit 11 — Ajouter la page detail evenement

Statut : [x] Termine

Objectif :
Afficher les informations completes d'un evenement.

Taches :
- [x] Creer page detail.
- [x] Naviguer depuis `EventCard`.
- [x] Afficher informations, statut, reservation placeholder et avis placeholder.

Fichiers touches :
- `lib/views/home/event_detail_view.dart`
- `lib/views/user/user_home.dart`
- `lib/widgets/event_card.dart`

Test :
- `flutter analyze` execute avec succes.
- Ouvrir un evenement.

Commandes Git :

```bash
git status
git add .
git commit -m "feat: add event detail view"
```

Critere de validation :
Le detail evenement est accessible.

### Commit 12 — Ameliorer la creation evenement

Objectif :
Rendre le formulaire organisateur plus complet.

Taches :
- Ameliorer validations.
- Ameliorer messages.
- Stabiliser GPS et date.

Fichiers touches :
- `lib/views/organizer/create_event_view.dart`
- `lib/controllers/event_controller.dart`

Test :
- Creer evenement valide.
- Tester erreurs formulaire.

Commandes Git :

```bash
git status
git add .
git commit -m "feat: improve event creation form"
```

Critere de validation :
La creation evenement est claire et fiable.

### Commit 13 — Ajouter mes evenements organisateur

Objectif :
Afficher les evenements de l'organisateur.

Taches :
- Utiliser `getOrganizerEvents`.
- Afficher liste avec `EventCard`.

Fichiers touches :
- `lib/views/organizer/organizer_home.dart`

Test :
- Creer un evenement puis le voir dans l'espace organisateur.

Commandes Git :

```bash
git status
git add .
git commit -m "feat: show organizer events"
```

Critere de validation :
L'organisateur voit ses propres evenements.

### Commit 14 — Ajouter le modele Reservation

Objectif :
Representer les reservations.

Taches :
- Creer `ReservationModel`.

Fichiers touches :
- `lib/models/reservation_model.dart`

Test :
- `flutter analyze`

Commandes Git :

```bash
git status
git add .
git commit -m "feat: add reservation model"
```

Critere de validation :
Le modele reservation compile.

### Commit 15 — Ajouter ReservationController

Objectif :
Gerer reservations et places.

Taches :
- Creer `ReservationController`.
- Ajouter transaction Firestore.

Fichiers touches :
- `lib/controllers/reservation_controller.dart`

Test :
- Reserver et verifier Firestore.

Commandes Git :

```bash
git status
git add .
git commit -m "feat: add reservation controller"
```

Critere de validation :
La reservation diminue les places.

### Commit 16 — Ajouter la page reservation

Objectif :
Permettre a l'utilisateur de confirmer une reservation.

Taches :
- Creer `BookingView`.
- Ajouter bouton depuis detail.

Fichiers touches :
- `lib/views/reservation/booking_view.dart`
- `lib/views/home/event_detail_view.dart`

Test :
- Reserver 1 place.

Commandes Git :

```bash
git status
git add .
git commit -m "feat: add booking view"
```

Critere de validation :
Une reservation peut etre creee depuis l'application.

### Commit 17 — Ajouter mes reservations

Objectif :
Afficher les reservations de l'utilisateur.

Taches :
- Creer page Mes reservations.
- Lire reservations utilisateur.

Fichiers touches :
- `lib/views/user/my_reservations_view.dart`
- `lib/controllers/reservation_controller.dart`
- `lib/views/user/user_home.dart`

Test :
- Reserver puis consulter Mes reservations.

Commandes Git :

```bash
git status
git add .
git commit -m "feat: show user reservations"
```

Critere de validation :
L'utilisateur voit ses reservations.

### Commit 18 — Gerer les places disponibles

Objectif :
Eviter les reservations superieures aux places.

Taches :
- Bloquer si complet.
- Bloquer quantite invalide.
- Afficher statut.

Fichiers touches :
- `lib/controllers/reservation_controller.dart`
- `lib/views/home/event_detail_view.dart`
- `lib/widgets/event_card.dart`

Test :
- Reserver toutes les places.

Commandes Git :

```bash
git status
git add .
git commit -m "fix: handle available seats correctly"
```

Critere de validation :
Les places restent coherentes.

### Commit 19 — Ajouter le modele Review

Objectif :
Representer les avis.

Taches :
- Creer `ReviewModel`.

Fichiers touches :
- `lib/models/review_model.dart`

Test :
- `flutter analyze`

Commandes Git :

```bash
git status
git add .
git commit -m "feat: add review model"
```

Critere de validation :
Le modele avis compile.

### Commit 20 — Ajouter commentaires et notation

Objectif :
Permettre avis et notes.

Taches :
- Creer `ReviewController`.
- Ajouter formulaire avis.
- Afficher avis.

Fichiers touches :
- `lib/controllers/review_controller.dart`
- `lib/views/home/event_detail_view.dart`

Test :
- Ajouter un commentaire.
- Ajouter une note.

Commandes Git :

```bash
git status
git add .
git commit -m "feat: add event reviews and ratings"
```

Critere de validation :
Les avis sont visibles.

### Commit 21 — Ajouter les filtres evenements

Objectif :
Filtrer les evenements.

Taches :
- Filtre categorie.
- Filtre gratuit/payant.

Fichiers touches :
- `lib/views/user/user_home.dart`
- `lib/controllers/event_controller.dart`

Test :
- Tester chaque filtre.

Commandes Git :

```bash
git status
git add .
git commit -m "feat: add event filters"
```

Critere de validation :
La liste se filtre correctement.

### Commit 22 — Ajouter le calendrier

Objectif :
Consulter les evenements par date.

Taches :
- Creer vue calendrier ou filtre par date.

Fichiers touches :
- `lib/views/user/calendar_view.dart`
- `lib/views/user/user_home.dart`
- `pubspec.yaml` si package ajoute.

Test :
- Selectionner une date.

Commandes Git :

```bash
git status
git add .
git commit -m "feat: add event calendar"
```

Critere de validation :
Les evenements s'affichent par date.

### Commit 23 — Ajouter les regles Firestore

Objectif :
Documenter ou ajouter les regles de securite.

Taches :
- Ajouter `firestore.rules` optionnel.
- Appliquer les regles dans Firebase Console.

Fichiers touches :
- `firestore.rules` si choisi.

Test :
- Tester droits utilisateur et organisateur.

Commandes Git :

```bash
git status
git add .
git commit -m "chore: add firestore security rules"
```

Critere de validation :
Les regles protegent les donnees.

### Commit 24 — Ameliorer l'UI finale

Objectif :
Polir l'application complete.

Taches :
- Harmoniser les nouveaux ecrans.
- Corriger pages vides.
- Verifier icones et textes.

Fichiers touches :
- Views et widgets necessaires.

Test :
- Parcours complet utilisateur.
- Parcours complet organisateur.

Commandes Git :

```bash
git status
git add .
git commit -m "style: polish final app UI"
```

Critere de validation :
L'application est coherente visuellement.

### Commit 25 — Tests et corrections finales

Objectif :
Stabiliser le projet.

Taches :
- Corriger test par defaut.
- Lancer analyse et tests.
- Corriger bugs.

Fichiers touches :
- `test/widget_test.dart`
- Fichiers necessaires.

Test :
- `flutter analyze`
- `flutter test`
- `flutter run`

Commandes Git :

```bash
git status
git add .
git commit -m "test: add final checks and fixes"
```

Critere de validation :
Le projet fonctionne sans erreur bloquante.

### Commit 26 — Preparer APK et demonstration

Objectif :
Preparer le rendu.

Taches :
- Preparer donnees demo.
- Capturer ecrans.
- Generer APK si demande.

Fichiers touches :
- Documentation ou fichiers necessaires.

Test :
- Rejouer la demo complete.

Commandes Git :

```bash
git status
git add .
git commit -m "chore: prepare final demo"
```

Critere de validation :
La demonstration est prete.

## 10. Tests à faire pendant le développement

Tests manuels principaux :
- Test inscription utilisateur.
- Test inscription organisateur.
- Test connexion utilisateur.
- Test connexion organisateur.
- Test redirection selon role.
- Test deconnexion.
- Test creation evenement.
- Test affichage evenement.
- Test details evenement.
- Test reservation.
- Test places disponibles.
- Test mes reservations.
- Test commentaire.
- Test notation.
- Test filtre categorie.
- Test filtre gratuit/payant.
- Test calendrier.
- Test espace organisateur.
- Test securite Firestore.

Commandes utiles :

```bash
flutter pub get
flutter analyze
flutter run
flutter clean
flutter test
```

Conseil :
- Lancer `flutter analyze` apres chaque commit important.
- Lancer `flutter run` apres chaque fonctionnalite visible.
- Tester avec deux comptes : un utilisateur et un organisateur.

## 11. Configuration manuelle à faire

### Firebase Console

Ouvrir Firebase Console et selectionner le projet `devmob-events`. C'est le projet deja configure dans `firebase_options.dart` et `android/app/google-services.json`.

### Activer Email/Password

Dans Firebase Console :
- Aller dans Authentication.
- Aller dans Sign-in method.
- Activer Email/Password.
- Enregistrer.

Cette etape est obligatoire pour que `createUserWithEmailAndPassword` et `signInWithEmailAndPassword` fonctionnent.

### Verifier Cloud Firestore

Dans Firebase Console :
- Aller dans Firestore Database.
- Verifier que la base existe.
- Verifier que les collections `users` et `events` sont bien creees apres utilisation de l'application.
- Les collections `reservations` et `reviews` seront creees automatiquement lors de la premiere ecriture.

### Ajouter les regles Firestore

Dans Firestore Database > Rules :
- Coller les regles proposees dans ce document.
- Publier.
- Tester avec les deux roles.

### Ajouter les index Firestore si necessaire

Firestore peut demander un index lorsqu'une requete combine `where` et `orderBy`, par exemple :
- evenements par organisateur tries par date ;
- reservations par utilisateur triees par date.

Si Firebase affiche une erreur avec un lien d'index :
- Cliquer sur le lien.
- Valider la creation de l'index.
- Attendre que l'index soit actif.

### Configuration Android

Le fichier `android/app/google-services.json` existe deja. Verifier simplement :
- Le package Android correspond au projet.
- L'application se lance sur emulateur ou telephone.

### SHA-1

SHA-1 n'est pas obligatoire pour Email/Password. Il devient utile surtout pour Google Sign-In ou certaines fonctionnalites Firebase avancees.

Pour ce projet, si vous gardez Email/Password uniquement, vous pouvez laisser cette etape de cote.

### Google Maps ou flutter_map

Le projet utilise actuellement `geolocator` pour recuperer latitude/longitude. Il n'utilise pas encore de carte.

Pour rester realiste :
- Garder seulement GPS + adresse pour la version principale.
- Ajouter une carte seulement en bonus.
- Si carte ajoutee, preferer une solution simple comme `flutter_map`, ou Google Maps si le professeur le demande.

### Packages pubspec.yaml

Packages deja presents :
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `font_awesome_flutter`
- `geolocator`

Packages possibles a ajouter plus tard :
- `intl` pour formater les dates proprement.
- `table_calendar` pour une vraie vue calendrier.

Ne pas ajouter trop de packages inutiles. Un projet etudiant doit rester facile a comprendre.

## 12. Design professionnel mais étudiant

Direction UI conseillee :
- Moderne, claire, simple.
- Pas trop luxueuse ou complexe.
- Facile a maintenir.
- Coherente entre toutes les pages.

### Couleurs principales

- Primaire : bleu petrole `#0F766E`
- Secondaire : bleu `#2563EB`
- Accent : orange `#F97316`
- Fond : `#F8FAFC`
- Surface : blanc
- Texte : `#111827`
- Texte secondaire : `#6B7280`

### Boutons

- Bouton principal rempli pour les actions importantes : connexion, inscription, creer, reserver.
- Bouton secondaire en contour pour les actions moins importantes.
- Bouton deconnexion avec icone.
- Boutons avec loading pendant les appels Firebase.

### Cartes evenement

Chaque carte doit afficher :
- Titre.
- Categorie.
- Date.
- Adresse.
- Places disponibles.
- Prix ou "Gratuit".
- Badge "Disponible" ou "Complet".

### Formulaires

- Labels clairs.
- Icônes simples.
- Espacement regulier.
- Messages d'erreur courts.
- Validation avant envoi.

### Page d'accueil utilisateur

- AppBar avec titre DEVMOB ou Evenements.
- Liste des evenements a venir.
- Zone filtre simple.
- Acces a Mes reservations.
- Etat vide propre si aucun evenement.

### Espace organisateur

- Bouton creer evenement visible.
- Liste "Mes evenements".
- Etat vide encourageant : "Aucun evenement cree pour le moment."
- Deconnexion accessible mais pas trop dominante.

### Messages d'erreur

- Utiliser SnackBar pour erreurs simples.
- Utiliser couleur rouge du theme.
- Messages courts : "Email invalide", "Places insuffisantes", "Connexion impossible".

### Pages vides

- Icône simple.
- Titre court.
- Texte explicatif.
- Action si utile.

### Navigation

- Navigation simple avec `Navigator.push`.
- Eviter une navigation trop complexe.
- Ajouter BottomNavigationBar seulement si necessaire apres les fonctionnalites principales.

## 13. Maquette obligatoire

Ecrans a faire en maquette ou a capturer :
- Page d'accueil utilisateur avec liste des evenements.
- Page details evenement.
- Page reservation.
- Page creation evenement organisateur.

Checklist maquette/captures :
- Les couleurs sont coherentes.
- Les boutons ont le meme style.
- Les champs de formulaire sont lisibles.
- Les cartes evenement affichent les informations importantes.
- Les titres sont clairs.
- La navigation est comprehensible.
- La page detail contient date, lieu, description, prix, places et reservation.
- La page creation evenement contient tous les champs necessaires.
- La page reservation montre l'evenement et le nombre de places.
- Les captures ressemblent a l'application finale.

Conseil :
- Faire les captures apres la Priorite 1 et apres les fonctionnalites principales.
- Ne pas faire une maquette trop differente de l'application reelle.

## 14. Conclusion

Ce qui est deja pret :
- Projet Flutter cree.
- Firebase configure.
- Authentification email/password partiellement fonctionnelle.
- Creation de profil avec role.
- Redirection selon role.
- Modele Event existant.
- Controleur Event existant.
- Creation evenement avec date, GPS, places et prix.

Ce qui reste a faire :
- Harmoniser le design existant.
- Creer les widgets UI communs.
- Corriger les textes mal encodes.
- Completer les modeles.
- Afficher les evenements.
- Ajouter details evenement.
- Ajouter reservation et gestion des places.
- Ajouter mes reservations.
- Ajouter commentaires et notation.
- Ajouter filtres et calendrier.
- Ajouter regles Firestore.
- Corriger les tests.
- Preparer demonstration finale.

Ordre recommande :
1. Harmoniser le design des views existantes.
2. Creer les widgets UI reutilisables.
3. Nettoyer la structure.
4. Stabiliser Auth, roles et modeles.
5. Ajouter liste et details evenement.
6. Ajouter reservation.
7. Ajouter avis, filtres et calendrier.
8. Finaliser securite, tests, UI et demo.

Premier commit a faire maintenant :

```bash
git status
git add .
git commit -m "style: harmonize existing views design"
```

Critere de validation du premier commit :
Toutes les views deja existantes ont une interface coherente, les textes sont propres, et l'application fonctionne comme avant.
