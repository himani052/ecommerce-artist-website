# DÉMARRAGE RAPIDE DU PROJET 

### Hortalia E.commerce



## I - Lancement de docker

On lance les **conteneurs dockers** définis dans le `docker-compose.yml` à la racine du projet. 

- Conteneur PHP 8.0 Apache
- Conteneur PostgresSQL 13.4 pour la base de donnée
- Conteneur PgAdmin pour l'interface graphique de gestion de la base de donnée

````shell
#Chargement du Dockerfile
docker-compose build --no-cache
#Changement des tous nos conteneurs
docker-compose up --build 
````



## II- Connection à la base de donnée



Une fois les conteneurs démarrés. Pour se connecter à la base de données avec **PgAdmin** on se rend vers le lien `http://localhost:8081/` via un navigateur web. 

> Il faut renseigner pour l'accès à PgAdmin
>
> - Identifiant : postgres@local.int
> - Password : password



Une fois connecté, on nous demande de renseigner le mot de passe de **utilisateur postgres **:

> - Password : password



On peut alors créer un **serveur postgres**. Attention l'hébergeur (Host name) n'est  pas localhost mais bien le nom du conteneur. Dans notre cas : `postgres_container`

À l'intérieur du serveur créé on retrouve bien la base de données **<mark>hortaliaecommerce</mark>** qui
a été lancé automatiquement à partir du fichier sql `hortalia-bdd.sql`

Les informations de la base de données seront automatiquement sauvegardées dans le répertoire racine `/data` .



## III - Lancement du projet Symfony 



On lance le conteneur apache et sa console. Depuis le répertoire où l'on se trouve, **on télécharge le projet Symfony via le lien git :** 
````shell
git clone -b master https://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:x-oauth-basic@github.com/himani052/ecommerce-bdd.git
````



On se rend à l'intérieur du projet qui a été téléchargé :

````shell
cd ecommerce-bdd
````



Dans un projet Symfony **le cache et les "Bundles"** (plugins) du projet sont placés dans les dossiers `/var/ `   et `/vendor/` . Ces dossiers ne sont pas inclus dans git car ils sont spécifiques à chaque machine. 
Pour retélécharger ces dossiers on fait appel à la commande :

````shell
composer install
````

**L'installation de toutes les librairies peut prendre quelque temps**. Une fois qu'elles sont téléchargées, symfony va procéder au nettoyage du cash (commande : ``symfony console cache:clear`) . Si la durée du processus est trop longue il se peut qu'un message d'erreur s'affiche. Il n'empêche pas de démarrer l'application en suivant les étapes ci-dessous. 



Dans les fichiers du projets que l'on retrouve dans le volume `/site/ecommerce-bdd` modifier à partir d'un IDE (PhpStorm, Visual studio, ...) ou directement via la console, le fichier `doctrine.yaml ` situé dans le chemin `/config/packages/doctrine.yaml` .  Pour modifier le fichier via la console il est nécessaire de télécharger au préalable la commande `vim`. Pour cela, on tape directement dans le shell `apt install vim` ou l'on peu ajouter dans le Dokerfile la ligne `RUN apt install vim`. 

Le lien de connexion à la base de données a été spécifié avec hébergeur `localhost` , on le change pour intégré notre **conteneur postgres**. On passe donc de `pgsql://postgres:password@127.0.0.1:5432/hortaliaecommerce`  à `pgsql://postgres:password@postgres_container:5432/hortaliaecommerce`

```yaml
connections:
    pgsql:
        url: 'pgsql://postgres:password@postgres_container:5432/hortaliaecommerce'
        driver: 'pdo_pgsql'
        server_version: '11.4'
        host: 127.0.0.1
        port: 5432
```



Il est désormais possible de lancer la commande pour démarrer le serveur Symfony

````shell
 symfony serve
````



Une fois le serveur lancé il suffit de se rendre vers l'URL : 

 `http://localhost:5000/admin/dashbord`



À partir de là, le menu de navigation de gauche permettra d'avoir accès aux entités suivantes :

- Utilisateurs
- Illustrations
- Produits
- Fournisseurs
- Commandes
- Livraisons 
- Achat fournisseurs
- Boutique fournisseurs (produit fournisseurs)

Il est possible d'avoir accès aux contenues de ces entités, mais également de 
mettre en place 

- un ajout
- une modification
- une suppression du contenu de ces entités. Excepté pour les tables Commandes, achat fournisseurs et livraison. Leur contenu ne peuvent pas être supprimé, modifié pour garder une trace des actions qui ont eu lieu. 

