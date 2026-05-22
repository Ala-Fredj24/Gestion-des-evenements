# Analyse et conception du projet Flutter

## 1. Presentation generale du projet

Ce projet est une application mobile Flutter de gestion et de reservation d'evenements culturels et sportifs. Elle permet a des organisateurs de publier des evenements, et a des utilisateurs de consulter ces evenements, voir leurs details, reserver des places et laisser des avis.

L'application utilise Firebase pour l'authentification et Cloud Firestore pour stocker les donnees principales. L'interface est construite avec Material Design, des widgets reutilisables, des cartes, des formulaires et des listes dynamiques.

### Acteurs principaux

**Utilisateur**

- Cree un compte avec le role `user`.
- Consulte la liste des evenements disponibles.
- Filtre les evenements par categorie et par prix.
- Consulte le detail d'un evenement.
- Reserve des places.
- Effectue une simulation de paiement si l'evenement est payant.
- Consulte ses reservations.
- Consulte le calendrier mensuel.
- Ajoute un avis et une note sur un evenement.

**Organisateur**

- Cree un compte avec le role `organizer`.
- Cree des evenements.
- Choisit le lieu officiel de l'evenement sur une carte.
- Consulte uniquement ses propres evenements.
- Modifie ou supprime uniquement les evenements qu'il a crees.
- Peut consulter les details et les avis des evenements.

### Fonctionnalites realisees

- Authentification par email et mot de passe avec Firebase Authentication.
- Gestion des roles `user` et `organizer`.
- Redirection automatique selon le role apres connexion.
- Ecran de confirmation apres creation de compte.
- Creation, modification et suppression d'evenements par l'organisateur.
- Liste des evenements disponibles pour les utilisateurs.
- Detail complet d'un evenement.
- Selection d'un lieu officiel avec carte interactive OpenStreetMap.
- Affichage de la carte dans le detail de l'evenement.
- Ouverture du lieu dans Google Maps.
- Reservation de places avec mise a jour du nombre de places restantes.
- Simulation de paiement pour les evenements payants.
- Confirmation d'email simulee apres reservation.
- Consultation des reservations de l'utilisateur.
- Calendrier mensuel des evenements.
- Avis, commentaires et notes sur les evenements.

## 2. Analyse des fonctionnalites realisees

### Authentification et gestion des roles

L'authentification est geree par `AuthController` avec Firebase Authentication. Lors de l'inscription, un document utilisateur est cree dans la collection `users` avec le role choisi.

Le fichier `AuthWrapper` ecoute l'etat de connexion avec `authStateChanges()`. Si aucun utilisateur n'est connecte, l'application affiche la page de connexion. Si un utilisateur est connecte, l'application charge son profil Firestore pour connaitre son role.

- Role `user` : redirection vers `UserHome`.
- Role `organizer` : redirection vers `OrganizerHome`.
- Role invalide ou profil manquant : affichage d'un ecran d'erreur avec bouton de deconnexion.

Apres creation d'un compte, l'application affiche une page de confirmation propre, puis l'utilisateur clique sur `Continuer` pour revenir a la page de connexion.

### Creation d'evenement

La creation d'evenement est faite dans `CreateEventView`. L'organisateur remplit un formulaire contenant :

- titre,
- categorie,
- description,
- date et heure,
- lieu officiel choisi sur la carte,
- nombre de places,
- image URL optionnelle,
- prix optionnel.

Le lieu est obligatoire. L'organisateur doit choisir un lieu via `PlacePickerView`, qui utilise OpenStreetMap et Nominatim pour rechercher ou selectionner un lieu existant.

Les donnees sont ensuite envoyees vers Firestore dans la collection `events` via `EventController.createEvent()`.

### Modification et suppression d'evenement

L'organisateur possede une section `Mes evenements` dans `OrganizerHome`. Cette section affiche seulement les evenements dont `organizerId` correspond a l'utilisateur connecte.

L'organisateur peut :

- ouvrir le detail de l'evenement,
- modifier l'evenement,
- supprimer l'evenement.

Dans le controleur, la modification et la suppression verifient que l'evenement appartient bien a l'organisateur connecte. Cela evite qu'un organisateur modifie ou supprime les evenements d'un autre organisateur.

### Liste et detail des evenements

La page utilisateur affiche les evenements disponibles avec `EventController.getUpcomingEvents()`. Les evenements sont filtres localement selon :

- evenement actif,
- evenement a venir,
- categorie,
- gratuit ou payant.

Le detail d'un evenement affiche :

- titre,
- categorie,
- statut,
- image si disponible,
- carte du lieu,
- date,
- adresse,
- prix,
- places disponibles,
- description,
- bouton de reservation si l'evenement est reservable,
- section des avis.

### Systeme de reservation

La reservation est faite dans `BookingView`. L'utilisateur choisit le nombre de places. Le controleur `ReservationController` cree une reservation dans Firestore et diminue le champ `seatsAvailable` de l'evenement.

La reservation utilise une transaction Firestore. Cela permet de lire l'evenement, verifier les places disponibles, diminuer les places, puis creer la reservation dans une operation logique.

La reservation est refusee si :

- l'utilisateur n'est pas connecte,
- l'evenement n'existe pas,
- l'evenement est passe,
- l'evenement est complet,
- la quantite demandee est invalide.

### Simulation de paiement

Si l'evenement est payant, la page de reservation affiche un formulaire de paiement simule avec :

- nom du titulaire,
- numero de carte,
- date d'expiration,
- CVV.

Le formulaire est valide cote application. Aucun paiement reel n'est effectue. Apres validation, la reservation est confirmee.

### Confirmation email apres paiement

L'application ne fait pas d'envoi reel d'email. Elle affiche une confirmation simulee apres reservation, indiquant qu'un email simule a ete envoye avec les informations suivantes :

- evenement,
- date,
- lieu,
- nombre de places,
- total.

Cette fonctionnalite est donc une simulation, adaptee a un projet universitaire sans integration SMTP ou service d'email reel.

### Calendrier mensuel

La page `CalendarView` affiche un calendrier mensuel. L'utilisateur peut :

- passer au mois precedent,
- passer au mois suivant,
- choisir un mois,
- selectionner une date,
- voir les evenements prevus ce jour-la,
- ouvrir le detail d'un evenement depuis le calendrier.

Les evenements sont charges depuis Firestore avec `EventController.getEventsForMonth()`.

### Selection de lieu sur carte

La selection de lieu utilise :

- `flutter_map` pour afficher la carte,
- OpenStreetMap comme fond de carte,
- Nominatim pour rechercher ou trouver un lieu officiel,
- `PlaceModel` pour representer le nom, le nom complet, la latitude et la longitude.

Le lieu selectionne est ensuite stocke dans le document de l'evenement avec :

- `address`,
- `latitude`,
- `longitude`.

Dans le detail d'un evenement, `LocationMapCard` affiche le marqueur sur la carte et propose un bouton pour ouvrir le lieu dans Google Maps.

### Avis, commentaires et notes

La section `Avis` est presente dans la page de detail d'un evenement. Un utilisateur connecte peut ajouter :

- une note de 1 a 5,
- un commentaire.

Les avis sont stockes dans la collection `reviews`. L'application affiche aussi la moyenne des notes et le nombre total d'avis.

### Fonctionnalites absentes ou partielles

- Les favoris ne sont pas implementes dans le code actuel.
- L'email de confirmation est simule, pas envoye reellement.
- Il n'y a pas de paiement reel.
- Il n'y a pas de panneau administrateur.
- Les images sont saisies sous forme d'URL, il n'y a pas d'upload Firebase Storage.
- Les avis peuvent etre ajoutes, mais il n'y a pas encore de modification ou suppression d'avis.

## 3. Conception de la base de donnees NoSQL

La base de donnees utilise Cloud Firestore. Firestore est une base NoSQL orientee documents. Les donnees sont stockees dans des collections, et chaque collection contient des documents.

### Collection: users

Cette collection stocke les profils utilisateurs apres inscription.

**Document ID**

- `uid` Firebase Authentication de l'utilisateur.

**Fields**

- `email` : email de l'utilisateur.
- `displayName` : nom affiche.
- `role` : `user` ou `organizer`.
- `createdAt` : date de creation du profil.

**Role dans l'application**

Cette collection permet de savoir si un compte connecte doit acceder a l'espace utilisateur ou a l'espace organisateur.

### Collection: events

Cette collection stocke les evenements crees par les organisateurs.

**Document ID**

- ID automatique genere par Firestore.

**Fields**

- `organizerId` : identifiant de l'organisateur qui a cree l'evenement.
- `title` : titre de l'evenement.
- `category` : categorie, par exemple `Culture`, `Sport` ou `Autre`.
- `description` : description de l'evenement.
- `dateTime` : date et heure.
- `address` : nom officiel du lieu choisi.
- `latitude` : latitude du lieu.
- `longitude` : longitude du lieu.
- `seatsTotal` : nombre total de places.
- `seatsAvailable` : nombre de places encore disponibles.
- `price` : prix, ou `null` si gratuit.
- `imageUrl` : URL de l'image, optionnelle.
- `isActive` : indique si l'evenement est actif.
- `createdAt` : date de creation.
- `updatedAt` : date de derniere modification.

**Role dans l'application**

Cette collection est centrale. Elle alimente la liste des evenements, le calendrier, le detail, les reservations et la section organisateur.

### Collection: reservations

Cette collection stocke les reservations faites par les utilisateurs.

**Document ID**

- ID automatique genere par Firestore.

**Fields**

- `userId` : identifiant de l'utilisateur qui reserve.
- `eventId` : identifiant de l'evenement reserve.
- `organizerId` : identifiant de l'organisateur de l'evenement.
- `quantity` : nombre de places reservees.
- `status` : statut de reservation, par exemple `confirmed`.
- `createdAt` : date de creation de la reservation.

**Role dans l'application**

Elle permet d'afficher les reservations d'un utilisateur dans `Mes reservations`. Elle garde aussi le lien avec l'evenement et l'organisateur.

### Collection: reviews

Cette collection stocke les avis des utilisateurs sur les evenements.

**Document ID**

- ID automatique genere par Firestore.

**Fields**

- `userId` : identifiant de l'utilisateur qui a laisse l'avis.
- `eventId` : identifiant de l'evenement concerne.
- `rating` : note de 1 a 5.
- `comment` : commentaire.
- `createdAt` : date de creation de l'avis.

**Role dans l'application**

Elle permet d'afficher les avis sur la page detail de l'evenement et de calculer une moyenne simple des notes.

### Relations entre collections

Firestore ne gere pas les relations comme une base SQL. Les relations sont faites avec des identifiants stockes dans les documents.

- `users.uid` est reference par `events.organizerId`.
- `users.uid` est reference par `reservations.userId`.
- `events.id` est reference par `reservations.eventId`.
- `users.uid` est reference par `reviews.userId`.
- `events.id` est reference par `reviews.eventId`.

### Diagramme textuel de conception

```text
users/{uid}
  - email
  - displayName
  - role
  - createdAt

events/{eventId}
  - organizerId --------------> users/{uid}
  - title
  - category
  - description
  - dateTime
  - address
  - latitude
  - longitude
  - seatsTotal
  - seatsAvailable
  - price
  - imageUrl
  - isActive
  - createdAt
  - updatedAt

reservations/{reservationId}
  - userId -------------------> users/{uid}
  - eventId ------------------> events/{eventId}
  - organizerId --------------> users/{uid}
  - quantity
  - status
  - createdAt

reviews/{reviewId}
  - userId -------------------> users/{uid}
  - eventId ------------------> events/{eventId}
  - rating
  - comment
  - createdAt
```

### Pourquoi cette structure convient a NoSQL

Cette structure convient a Firestore car les donnees sont organisees selon les ecrans de l'application :

- une collection pour les profils,
- une collection pour les evenements,
- une collection pour les reservations,
- une collection pour les avis.

Les documents sont simples, lisibles et faciles a charger dans Flutter. Les listes sont obtenues par des requetes directes, par exemple les evenements d'un organisateur avec `organizerId`, les reservations d'un utilisateur avec `userId`, ou les avis d'un evenement avec `eventId`.

Pour un projet etudiant, cette structure est suffisante et claire. Elle evite une conception trop complexe et reste compatible avec les besoins de l'application.

## 4. Use case du projet

### Acteurs

- **Utilisateur non connecte**
- **Utilisateur connecte**
- **Organisateur**

### Cas d'utilisation principaux

#### S'inscrire

Un visiteur cree un compte en saisissant son nom, email, mot de passe et role. Le profil est cree dans Firebase Authentication et Firestore. Apres inscription, un ecran de succes est affiche.

#### Se connecter

Un utilisateur saisit son email et son mot de passe. Firebase verifie les identifiants. L'application lit ensuite le role dans Firestore et redirige vers le bon espace.

#### Consulter les evenements

Un utilisateur connecte consulte les evenements actifs et a venir. Il peut filtrer par categorie ou par prix.

#### Consulter le detail d'un evenement

L'utilisateur ouvre une fiche evenement. Il voit les informations principales, la carte, la description, le prix, les places disponibles et les avis.

#### Reserver un evenement

L'utilisateur choisit le nombre de places. Si l'evenement est payant, il remplit le formulaire de paiement simule. La reservation est ensuite creee dans Firestore.

#### Consulter mes reservations

L'utilisateur ouvre la page `Mes reservations` pour voir ses reservations confirmees et acceder aux details des evenements reserves.

#### Ajouter un avis

L'utilisateur ajoute une note et un commentaire dans la page detail d'un evenement. L'avis est sauvegarde dans Firestore.

#### Consulter le calendrier

L'utilisateur ouvre le calendrier mensuel, choisit un mois puis une date, et consulte les evenements prevus ce jour-la.

#### Creer un evenement

L'organisateur remplit le formulaire d'evenement, choisit un lieu sur la carte, puis publie l'evenement.

#### Modifier un evenement

L'organisateur ouvre sa liste d'evenements, choisit un evenement qu'il a cree, puis modifie ses informations.

#### Supprimer un evenement

L'organisateur supprime un de ses propres evenements apres confirmation.

### Diagramme textuel des cas d'utilisation

```text
Acteur: Utilisateur non connecte
  - Creer un compte
  - Se connecter

Acteur: Utilisateur connecte
  - Consulter les evenements
  - Filtrer les evenements
  - Voir le detail d'un evenement
  - Voir le lieu sur la carte
  - Ouvrir le lieu dans Google Maps
  - Reserver des places
  - Simuler un paiement
  - Recevoir une confirmation simulee
  - Consulter mes reservations
  - Consulter le calendrier mensuel
  - Ajouter un avis

Acteur: Organisateur
  - Creer un evenement
  - Choisir un lieu officiel sur la carte
  - Voir mes evenements
  - Modifier mes evenements
  - Supprimer mes evenements
  - Consulter les details et avis
  - Se deconnecter
```

## 5. Gestionnaire d'etat

### Definition simple

En Flutter, la gestion d'etat signifie la maniere dont l'application met a jour l'interface quand une donnee change. Par exemple :

- afficher un chargement pendant une connexion,
- mettre a jour la liste des evenements quand Firestore change,
- changer le nombre de places selectionnees,
- afficher une erreur dans un formulaire.

### Approche utilisee dans ce projet

Le projet n'utilise pas de package externe comme Provider, Riverpod ou Bloc. Il utilise une approche simple et adaptee a un projet etudiant :

- `StatefulWidget` pour les ecrans interactifs,
- `setState()` pour modifier l'etat local,
- des controleurs pour separer la logique Firebase,
- `StreamBuilder` pour ecouter les donnees Firestore en temps reel,
- `FutureBuilder` pour charger une donnee une seule fois,
- `FirebaseAuth.authStateChanges()` pour suivre la connexion.

Cette approche est suffisante car le projet reste de taille moyenne et les donnees sont principalement gerees par Firebase.

### Exemples dans le projet

**Connexion utilisateur**

Dans `LoginView`, `isLoading` passe a `true` pendant la tentative de connexion. Apres la reponse Firebase, il repasse a `false`. Ensuite, `AuthWrapper` detecte automatiquement le nouvel etat de connexion avec `authStateChanges()` et affiche la bonne page selon le role.

**Creation, modification et suppression d'evenement**

Dans `CreateEventView`, les champs du formulaire sont stockes dans des `TextEditingController`. La date, la categorie et le lieu selectionne sont gardes dans l'etat local du widget. Quand l'organisateur sauvegarde, `EventController` envoie les donnees a Firestore.

Dans `OrganizerHome`, la liste des evenements utilise un `StreamBuilder`. Quand Firestore est modifie, la liste se met a jour automatiquement.

**Reservation d'un evenement**

Dans `BookingView`, le nombre de places est stocke dans `quantity`. Les boutons plus et moins utilisent `setState()` pour actualiser le total affiche. Quand la reservation est confirmee, `ReservationController` cree la reservation et diminue les places disponibles avec une transaction Firestore.

**Simulation de paiement reussie**

Si l'evenement est payant, le formulaire de paiement simule est valide. Apres validation, la reservation continue normalement. L'application affiche ensuite une confirmation simulee dans une boite de dialogue.

**Mise a jour Firestore**

Les ecrans qui utilisent `StreamBuilder` recoivent automatiquement les changements Firestore :

- liste des evenements,
- evenements de l'organisateur,
- calendrier,
- reservations,
- avis.

Cela donne une impression de mise a jour en temps reel sans devoir rafraichir manuellement l'ecran.

## 6. Guide Figma from scratch

Ce guide explique comment creer une maquette Figma proche de l'application Flutter actuelle.

### Etape 1: Creer un nouveau fichier Figma

1. Ouvrir Figma.
2. Cliquer sur `New design file`.
3. Renommer le fichier, par exemple `Application Evenements - Maquette`.
4. Creer une page nommee `Screens`.
5. Creer une autre page nommee `Components`.

### Etape 2: Creer les frames mobiles

1. Selectionner l'outil `Frame`.
2. Choisir une taille mobile, par exemple `Android Small` ou `iPhone 13`.
3. Creer plusieurs frames :
   - Login,
   - Creation de compte,
   - Confirmation compte,
   - Accueil utilisateur,
   - Detail evenement,
   - Reservation,
   - Calendrier,
   - Accueil organisateur,
   - Creation evenement,
   - Choix du lieu.

Utiliser une largeur proche de 390 px pour imiter une application mobile moderne.

### Etape 3: Definir les couleurs

Creer des styles de couleur proches du theme Flutter :

- Primaire : vert teal `#0F766E`.
- Secondaire : bleu `#2563EB`.
- Accent : orange `#F97316`.
- Fond : gris tres clair `#F8FAFC`.
- Surface : blanc `#FFFFFF`.
- Texte principal : `#111827`.
- Texte secondaire : `#6B7280`.
- Erreur : rouge `#DC2626`.

Appliquer le fond gris clair aux frames et utiliser des cartes blanches pour les blocs de contenu.

### Etape 4: Definir la typographie

Utiliser une police proche de Flutter Material, par exemple `Roboto`.

Styles conseilles :

- Titre AppBar : 20 px, Bold.
- Titre section : 18 px, Bold.
- Texte normal : 14 ou 16 px, Regular.
- Texte secondaire : 13 ou 14 px, Regular, couleur grise.
- Bouton : 15 px, Bold.

### Etape 5: Definir l'espacement

Utiliser une grille simple :

- marge generale : 20 px,
- espace entre champs : 12 px,
- espace entre grandes sections : 20 ou 24 px,
- padding des cartes : 16 ou 18 px,
- rayon des cartes et boutons : 12 px.

Cela permet de garder une maquette tres proche de l'application.

### Etape 6: Creer les composants

Dans la page `Components`, creer :

- bouton principal vert,
- bouton secondaire outline,
- champ de texte avec icone,
- carte evenement,
- badge de statut,
- carte d'information,
- AppBar avec titre et icones,
- carte de carte geographique,
- champ de recherche.

Transformer chaque element en composant Figma avec `Create component`.

### Etape 7: Designer la page Login

1. Creer une frame mobile.
2. Ajouter une AppBar avec le titre `Gestion des evenements`.
3. Ajouter une carte blanche au centre.
4. Dans la carte, ajouter :
   - titre `Connexion`,
   - sous-titre,
   - champ `Email`,
   - champ `Mot de passe`,
   - bouton `Se connecter`,
   - lien `Creer un compte`.
5. Utiliser les icones email, cadenas et login.

### Etape 8: Designer la page Creation de compte

1. Creer une frame `Inscription`.
2. Ajouter une carte avec :
   - titre `Creer un compte`,
   - dropdown role,
   - champ nom complet,
   - champ email,
   - champ mot de passe,
   - champ confirmation,
   - bouton `Creer le compte`.
3. Creer aussi une frame `Compte cree` avec :
   - grande icone de succes,
   - message `Votre compte a ete cree avec succes.`,
   - bouton `Continuer`.

### Etape 9: Designer la page Creation evenement

1. Creer une frame `Creer un evenement`.
2. Ajouter les champs :
   - titre,
   - categorie,
   - description,
   - date et heure,
   - lieu officiel,
   - bouton `Choisir sur la carte`,
   - nombre de places,
   - image URL,
   - prix d'entree.
3. Ajouter une carte de previsualisation du lieu avec un rectangle representant la carte.
4. Ajouter le bouton principal `Creer`.

### Etape 10: Designer la page Reservation

1. Creer une frame `Reservation`.
2. Ajouter une section avec le titre de l'evenement.
3. Ajouter une carte resume :
   - date,
   - lieu,
   - places disponibles,
   - prix unitaire.
4. Ajouter une carte `Nombre de places` avec boutons moins et plus.
5. Ajouter une carte `Total`.
6. Si evenement payant, ajouter la carte `Paiement simule` :
   - nom titulaire,
   - numero de carte,
   - expiration,
   - CVV.
7. Ajouter le bouton `Confirmer la reservation`.

### Etape 11: Designer les autres pages principales

**Accueil utilisateur**

- AppBar avec titre `Bienvenue`.
- Icnes calendrier, reservations et deconnexion.
- Section `Evenements disponibles`.
- Carte filtres.
- Liste de cartes evenements.

**Detail evenement**

- Titre, categorie et badge de statut.
- Image si disponible.
- Carte du lieu.
- Carte infos : date, lieu, prix, places.
- Description.
- Bouton reservation.
- Section avis avec note moyenne, formulaire et liste d'avis.

**Calendrier**

- AppBar `Calendrier`.
- Section `Evenements par date`.
- Carte calendrier avec mois, fleches et jours.
- Liste des evenements du jour choisi.

**Accueil organisateur**

- AppBar avec titre `Bienvenue` et icone deconnexion.
- Bouton `Creer un evenement`.
- Section `Mes evenements`.
- Cartes evenement avec boutons `Modifier` et `Supprimer`.

**Choix du lieu**

- Champ de recherche.
- Bouton recherche.
- Grande zone carte.
- Liste de resultats.
- Carte du lieu selectionne.
- Bouton `Valider ce lieu`.

### Etape 12: Rendre la maquette similaire a l'application Flutter

Pour garder la meme identite visuelle :

- utiliser un fond gris clair,
- utiliser des cartes blanches avec bordure gris clair,
- utiliser le vert comme couleur principale,
- utiliser des boutons arrondis a 12 px,
- placer les icones a gauche des champs,
- garder les titres courts,
- utiliser beaucoup d'espacement vertical,
- eviter les decorations trop complexes.

### Etape 13: Organiser le fichier Figma

Organisation conseillee :

```text
Pages Figma
  - Cover
  - Screens
  - Components
  - Prototype

Frames
  - 01 Login
  - 02 Inscription
  - 03 Confirmation compte
  - 04 Accueil utilisateur
  - 05 Detail evenement
  - 06 Reservation
  - 07 Calendrier
  - 08 Accueil organisateur
  - 09 Creation evenement
  - 10 Choix lieu
```

Nommer les calques clairement, par exemple `Button / Primary`, `Card / Event`, `Input / Email`.

### Etape 14: Exporter ou presenter la maquette

Pour presenter la maquette :

1. Cliquer sur `Present` dans Figma.
2. Relier les boutons principaux avec l'onglet `Prototype`.
3. Exemple :
   - Login vers Accueil utilisateur,
   - Creer compte vers Confirmation compte,
   - Continuer vers Login,
   - Reserver vers Reservation,
   - Choisir sur la carte vers Choix lieu.
4. Exporter les frames en PNG si besoin :
   - selectionner une frame,
   - aller dans `Export`,
   - choisir PNG,
   - cliquer sur `Export`.

Cette maquette permettra d'expliquer visuellement le fonctionnement de l'application sans devoir lancer le projet Flutter pendant la presentation.
