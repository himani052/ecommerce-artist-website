-----------------------------------------------------------------------------
               
               -- BDD - CRÉATION D'UN SITE E-COMMERCE 
	-- POUR UNE ARTISTE QUI VEUX VENDRE SES OEUVRES ET DES PRODUITS DÉRIVÉS
    
    -- Projet BDD CNAM 2eme annee Semestre 1 
    -- Auteure : IMANI Houssam

-----------------------------------------------------------------------------
               

-----------------------------------------------------------------------------
-- Supprimer les informations précedentes
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS PRODUIT CASCADE;
DROP TABLE IF EXISTS ILLUSTRATION CASCADE;
DROP TABLE IF EXISTS COMMANDE CASCADE;
DROP TABLE IF EXISTS FOURNISSEUR CASCADE;
DROP TABLE IF EXISTS UTILISATEUR CASCADE;
DROP TABLE IF EXISTS LIVRAISON CASCADE;
DROP TABLE IF EXISTS ACCHAT_FOURNISSEUR CASCADE;
DROP TABLE IF EXISTS PRODUITS_COMMANDE_USER CASCADE;

DROP ROLE IF EXISTS admin_site;
DROP ROLE IF EXISTS client_site;
DROP ROLE IF EXISTS "houssam.imani";
DROP ROLE IF EXISTS "hissani.imani";
DROP ROLE IF EXISTS "tom.orhon@gmail.com";
DROP ROLE IF EXISTS "amina.mroudjae@gmail.com";
DROP ROLE IF EXISTS "hissani.imani";
DROP ROLE IF EXISTS "elise.milani@gmail.com";


-----------------------------------------------------------------------------
-- Initialisation de la structure
-----------------------------------------------------------------------------

-- Ajout language plsql
CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;

-- Gestion des droits de gestion des tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO PUBLIC;

-----------------------------------------------------------------------------
-- Table User
------------------------------------------------------------------------------

CREATE TABLE UTILISATEUR (
mailUser VARCHAR(255) NOT NULL,
nomUser VARCHAR(60) NOT NULL,
prenomUser VARCHAR(60) NOT NULL,
dateNaissanceUser DATE NOT NULL, 
paysUser VARCHAR(50) NOT NULL ,
villeUser VARCHAR(50) NOT NULL,
cpUser VARCHAR(15) NOT NULL,
addressUser TEXT,
telUser VARCHAR(25),
roleUser VARCHAR(40) NOT NULL ,
CONSTRAINT datenaissance_user_chk CHECK (dateNaissanceUser > '1901-01-01' AND dateNaissanceUser <  date(CURRENT_DATE)),
CONSTRAINT type_produit_ck CHECK ( roleUser IN ('client','admin')),
CONSTRAINT email_user_chk CHECK (((mailUser)::text ~* '^[0-9a-zA-Z._-]+@[0-9a-zA-Z._-]{2,}[.][a-zA-Z]{2,4}$'::text)),
PRIMARY KEY (mailUser)
);

-----------------------------------------------------------------------------
-- Table Illustration
------------------------------------------------------------------------------

CREATE TABLE ILLUSTRATION (
labelIllust VARCHAR(255) NOT NULL,
typeillust VARCHAR(40) NOT NULL,
descriptionIllust TEXT,
imageIllust VARCHAR(255) NOT NULL,
CONSTRAINT type_illust_ck CHECK ( typeIllust IN ('sketch', 'crayon gris','crayon de couleurs', 'encre', 'acrylique', 'aquarelle', 'digitale')),
PRIMARY KEY (labelIllust)
);


-----------------------------------------------------------------------------
-- Table Produit
------------------------------------------------------------------------------

CREATE TABLE PRODUIT (
refProduit SERIAL NOT NULL,
labelproduit VARCHAR(255) NOT NULL,
typeproduit VARCHAR(60) NOT NULL,
descriptionProduit TEXT,
imageProduit VARCHAR(255),
prixProduitCde FLOAT NOT NULL,
-- le stock peut être réévalué par la suite 
stockProduit INT, 
-- Des produits pourronts être créés plus tard sans illustrations de type évènement (ex: place pour exposition)
illustration_labelIllust VARCHAR(255), 
CONSTRAINT type_produit_ck CHECK ( typeproduit IN ('décoration intérieur','vêtement', 'coque', 'accessoire', 'papeterie', 'art mural', 'non matériel', 'fond écran', 'tuto' )),
CONSTRAINT produit_illust_uq UNIQUE(labelproduit, illustration_labelIllust),
PRIMARY KEY (refProduit)
);


-----------------------------------------------------------------------------
-- Table Commande
------------------------------------------------------------------------------

CREATE TABLE COMMANDE (
refCdeUser SERIAL NOT NULL,
dateCdeUser TIMESTAMP NOT NULL DEFAULT now(),
user_mailUser VARCHAR(255) NOT NULL,
PRIMARY KEY (refCdeUser)
);


-----------------------------------------------------------------------------
-- Table Produits_commandes_user
------------------------------------------------------------------------------

CREATE TABLE PRODUITS_COMMANDE_USER (
produit_refProduit INT NOT NULL,
commande_refCdeUser INT NOT NULL,
qteCdeUser INT NOT NULL,
PRIMARY KEY (produit_refProduit, commande_refCdeUser)
);



-----------------------------------------------------------------------------
-- Table Livraison
------------------------------------------------------------------------------

-- Renvoyer à la contrainte check de la table livraison la somme des livraisons puis la somme des commandes avec la fonction qui du dessous 
-- La contrainte nb_livraison_ck visant à interdire le nombre de livraison d'excéder le nombre de commandes passés
-- et les fonctions d'agrégat étant interdit directement inscrite dans la contrainte CHECK 
CREATE OR REPLACE FUNCTION NB_LIVRAISONS ()  
RETURNS FLOAT
AS $$
BEGIN
	RETURN (SELECT count(refLivraison) FROM LIVRAISON );
END;
$$  LANGUAGE PLPGSQL; 

CREATE OR REPLACE FUNCTION NB_COMMANDES ()  
RETURNS FLOAT
AS $$
BEGIN
RETURN (SELECT count(datecdeuser) FROM COMMANDE);
END ;
$$  LANGUAGE PLPGSQL;



CREATE TABLE LIVRAISON (
refLivraison SERIAL NOT NULL,
labelTransporteur VARCHAR(255) NOT NULL,
tarifLivraison FLOAT NOT NULL,
dateLivraison DATE NOT NULL,
commande_refCdeUser INT NOT NULL,
CONSTRAINT LabelTransporteurLivraison_ck CHECK ( labelTransporteur IN ( 'courrier electronique', 'colissimo', 'chronospost','DPD', 'mondial relay', 'relais colis', 'DHL', 'FedEX', 'UPS')),
CONSTRAINT nb_livraison_ck CHECK (NB_LIVRAISONS () <  NB_COMMANDES ()),
PRIMARY KEY (refLivraison)
);


-----------------------------------------------------------------------------
-- Table Fournisseur
------------------------------------------------------------------------------

CREATE TABLE FOURNISSEUR (
mailFournisseur VARCHAR(255) NOT NULL,
labelFournisseur VARCHAR(255) NOT NULL,
CodePaysFournisseur VARCHAR(5),
CONSTRAINT email_fournisseur_chk CHECK (((mailFournisseur)::text ~* '^[0-9a-zA-Z._-]+@[0-9a-zA-Z._-]{2,}[.][a-zA-Z]{2,4}$'::text)),
PRIMARY KEY (mailFournisseur)
);

-----------------------------------------------------------------------------
-- Table PRODUIT_FOURNISSEUR
------------------------------------------------------------------------------

CREATE TABLE PRODUIT_FOURNISSEUR (
refProduitFournisseur SERIAL NOT NULL, 
labelproduitFournisseur VARCHAR(255) NOT NULL,
typeproduitFournisseur VARCHAR(60) NOT NULL,
prixProduitFournisseur FLOAT NOT NULL,
fournisseur_mailfournisseur VARCHAR(255) NOT NULL,
CONSTRAINT type_produitFournisseur_ck CHECK ( typeproduitFournisseur IN ('décoration intérieur','vêtement', 'coque', 'accessoire', 'papeterie', 'art mural', 'non matériel', 'fond écran', 'tuto' )),
PRIMARY KEY (refProduitFournisseur )
);



-----------------------------------------------------------------------------
-- Table Achat_fournisseur
------------------------------------------------------------------------------

CREATE TABLE ACHAT_FOURNISSEUR (
refAchatFournisseur SERIAL NOT NULL,
dateAchatFournisseur DATE,
fournisseur_mailFournisseur VARCHAR(255) NOT NULL,
PRIMARY KEY (refAchatFournisseur)
);

-----------------------------------------------------------------------------
-- Table Produits_achat_fournisseur
------------------------------------------------------------------------------

CREATE TABLE PRODUITS_ACHAT_FOURNISSEUR (
produit_refProduit INT NOT NULL,
achat_fournisseur_refAchatFournisseur INT NOT NULL,
qteAchatFournisseur INT NOT NULL,
PRIMARY KEY (produit_refProduit, achat_fournisseur_refAchatFournisseur)
);



-----------------------------------------------------------------------------
-- Add Constraint 
-----------------------------------------------------------------------------


ALTER TABLE PRODUIT ADD CONSTRAINT fk_illustration FOREIGN KEY(illustration_labelIllust)  REFERENCES ILLUSTRATION(labelIllust) ON DELETE CASCADE;
ALTER TABLE COMMANDE ADD CONSTRAINT fk_user FOREIGN KEY(user_mailUser) REFERENCES UTILISATEUR(mailUser) ON DELETE CASCADE;
ALTER TABLE PRODUITS_COMMANDE_USER ADD CONSTRAINT fk_produit_has_produits_commande FOREIGN KEY(produit_refProduit) REFERENCES PRODUIT(refProduit) ON DELETE CASCADE;
ALTER TABLE PRODUITS_COMMANDE_USER ADD CONSTRAINT fk_commande_has_produits_commande FOREIGN KEY(commande_refCdeUser)  REFERENCES COMMANDE(refCdeUser) ON DELETE CASCADE;
ALTER TABLE LIVRAISON ADD CONSTRAINT fk_commande FOREIGN KEY(commande_refCdeUser)   REFERENCES COMMANDE(refCdeUser) ON DELETE CASCADE;
ALTER TABLE ACHAT_FOURNISSEUR ADD CONSTRAINT fk_fournisseur FOREIGN KEY(fournisseur_mailFournisseur)  REFERENCES FOURNISSEUR(mailFournisseur) ON DELETE CASCADE;
ALTER TABLE PRODUITS_ACHAT_FOURNISSEUR ADD CONSTRAINT fk_produit_has_achat_fournisseur FOREIGN KEY(produit_refProduit)  REFERENCES PRODUIT(refProduit) ON DELETE CASCADE;
ALTER TABLE PRODUITS_ACHAT_FOURNISSEUR ADD CONSTRAINT fk_achat_fournisseur_has_achat_fournisseur FOREIGN KEY(achat_fournisseur_refAchatFournisseur)  REFERENCES ACHAT_FOURNISSEUR(refAchatFournisseur) ON DELETE CASCADE;
ALTER TABLE PRODUIT_FOURNISSEUR  ADD CONSTRAINT fk_fournisseur FOREIGN KEY(fournisseur_mailFournisseur)  REFERENCES FOURNISSEUR(mailFournisseur) ON DELETE CASCADE;



-----------------------------------------------------------------------------
-- Defining roles.
-----------------------------------------------------------------------------

CREATE ROLE admin_site;
CREATE role client_site;

CREATE ROLE "houssam.imani" LOGIN IN GROUP admin_site;
	ALTER ROLE "houssam.imani" ENCRYPTED PASSWORD 'admin';
CREATE ROLE "hissani.imani" LOGIN IN GROUP client_site;
	ALTER ROLE "hissani.imani" ENCRYPTED PASSWORD 'client';
CREATE ROLE "tom.orhon@gmail.com" LOGIN IN GROUP client_site;
	ALTER ROLE "tom.orhon@gmail.com" ENCRYPTED PASSWORD 'client';
CREATE ROLE "amina.mroudjae@gmail.com" LOGIN IN GROUP client_site;
	ALTER ROLE "amina.mroudjae@gmail.com" ENCRYPTED PASSWORD 'client';
CREATE ROLE "elise.milani@gmail.com" LOGIN IN GROUP client_site;
	ALTER ROLE "elise.milani@gmail.com" ENCRYPTED PASSWORD 'client';
    
-----------------------------------------------------------------------------
-- Insertion des données de test
-----------------------------------------------------------------------------

-- Création des utilisateurs 
INSERT INTO UTILISATEUR VALUES ('houssam.imani@gmail.com', 'imani', 'houssam', '2000-03-17', 'france', 'Toulon', '83000', '89 Boulevar mege résidance les orangiers', '06 49 17 34 26', 'admin' );
INSERT INTO UTILISATEUR VALUES ('hissani.imani@gmail.com', 'imani', 'hissani', '1998-09-29', 'france', 'Angers', '49000', '03 court madeleine appartement 10 1er étage', '06 72 34 56 67', 'client' );
INSERT INTO UTILISATEUR VALUES ('tom.orhon@gmail.com', 'orhon', 'tom', '1998-07-25', 'france', 'St Bartelemy d anjour', '49100', '08 escapade de la liberté', '06 56 76 89 67', 'client' );
INSERT INTO UTILISATEUR VALUES ('amina.mroudjae@gmail.com', 'mroudjae', 'amina', '1966-03-02', 'france', 'Réunion', '97400', '08 escapade de la liberté', '06 56 76 89 67', 'client' );
INSERT INTO UTILISATEUR VALUES ('elise.milani@gmail.com', 'elise', 'milani', '1999-08-18', 'france', 'Strasbourg', '67200', '27 bourlevard de la paix', '07 56 34 56 89', 'client' );


-- Définition des illustrations 
INSERT INTO ILLUSTRATION VALUES ( 'dans_la_nuit', 'encre', 'fille perdue dans la profondeur de la nuit sous les eclats de la lune', '001-dans-la-nuit.png' );
INSERT INTO ILLUSTRATION VALUES ( 'danceuse_etoile', 'sketch', 'representation danceuse étoile', '002-danceuse-etoile.png' );
INSERT INTO ILLUSTRATION VALUES ( 'le_monde_a_l_envers', 'digitale', 'le monde à l envers est une painture digitale représentant la peur du vide', '003-le-monde-a-l-envers.png' );
INSERT INTO ILLUSTRATION VALUES ( 'la_fille_de_la_lune', 'digitale', 'enfant de la lune', '004-la-fille-de-la-lune.png' );
INSERT INTO ILLUSTRATION VALUES ( 'les_deux_oceans', 'acrylique', 'representation de la beauté des océan', '005-les-deux-oceans' );
INSERT INTO ILLUSTRATION VALUES ( 'orage_et_tunage', 'aquarelle', 'representation de la pluie dans son sinistre', '006-orage-et-tunage' );
INSERT INTO ILLUSTRATION VALUES ( 'dans_tes_yeux', 'crayon gris', 'representation de l amour', '007-dans-tes-yeux' );
INSERT INTO ILLUSTRATION VALUES ( 'fougue_du_printemps', 'crayon de couleurs', 'representation des beaux jours après hiver', '008-fougue-du-primtemp' );
INSERT INTO ILLUSTRATION VALUES ( 'dernier_jours_d_une_vie', 'encre', 'representation de la vie ephémère', '009-fougue-du-primtemp' );
INSERT INTO ILLUSTRATION VALUES ( 'danse_avec_moi', 'sketch', 'representation de la beauté de la danse', '010-fougue-du-primtemp' );


-- Insertion des produits
-- Pour les clés primaires de type SERIAL (Auto_increment) on spécifie les champs à remplirs, la référence se remplissante toute seule
-- Pour les clés étrangères on effectu un select pour retrouver la bonne donnée dans la bonne table

INSERT INTO PRODUIT (labelproduit, typeproduit, descriptionProduit, imageProduit, prixProduitCde,stockProduit,illustration_labelIllust)
VALUES ( 'place pour exposition cristale by Hortalia', 'non matériel', 'Ticket pour entrer à cette exposition annuelle présentant toutes les oeuvres','image-produit.png', 18.30 , NULL, NULL ), 
		( 'TUTO : apprendre a dessiner des yeux', 'tuto', 'Tuto sur pour aider à manier le dessin des yeux','image-produit.png', 14.30 , NULL, NULL),
		( 'TUTO : dessiner un corp humain en moins de 10 min', 'tuto', 'Tuto sur pour aider à manier le dessin du corp humain','image-produit.png', 16.30 , NULL, NULL),
		( 'Fond écran Iphone', 'fond écran', 'Habiller fond écran Iphone avec une belle illustration ','image-produit.png', 5.50 , NULL, NULL),
		( 'Fond écran ordinateur', 'fond écran', 'Habiller fond écran ordinateur avec une belle illustration au format 4k HD (4 096 × 2 160)', 'image-produit.png', 10.30 , NULL, NULL),

		-- vêtement 
		( 'sweatshirt', 'vêtement', 'pull en laine manche longue et capuche', 'image-produit.png', 36.9 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='dans_la_nuit')),
        ( 't-shirt', 'vêtement', 'T-shirt été très léger', 'image-produit.png', 19.5 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='danceuse_etoile')),
		( 'débardeur', 'vêtement', 'portez vos inspirations', 'image-produit.png', 13.6 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='le_monde_a_l_envers')),
		( 'robe', 'vêtement', 'portez vos inspirations', 'image-produit.png', 28.9 ,  100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='la_fille_de_la_lune')),
		( 'legging', 'vêtement', 'portez vos inspirations', 'image-produit.png', 15.3 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='les_deux_oceans')),

		-- décoration intérieur
		( 'coussin', 'décoration intérieur', 'decorez votre interieur', 'image-produit.png',  12.3 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='danceuse_etoile')),
		( 'horloge', 'décoration intérieur', 'decorez votre interieur', 'image-produit.png', 12.3 , 100, (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='dernier_jours_d_une_vie')),
		( 'mug', 'décoration intérieur', 'decorez votre interieur', 'image-produit.png', 12.3 ,  100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='orage_et_tunage')),
		( 'plaid', 'décoration intérieur', 'decorez votre interieur', 'image-produit.png', 12.3 , 100, (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='fougue_du_printemps')),
		( 'couvre lit', 'décoration intérieur', 'decorez votre interieur', 'image-produit.png', 20,  100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='dans_tes_yeux')),

		-- coque 
        ( 'coque Iphone X', 'coque', 'portez vos inspirations', 'image-produit.png', 25.5 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='danse_avec_moi')),
		( 'coque Samsung Galaxy S20', 'coque', 'portez vos inspirations', 'image-produit.png', 25.5 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='danceuse_etoile')),
		( 'coque Ipad mini', 'coque', 'portez vos inspirations', 'image-produit.png',  28.5 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='la_fille_de_la_lune')),
		( 'coque MacBook Pro', 'coque', 'portez vos inspirations', 'image-produit.png',  15.5 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='les_deux_oceans')),

		-- accessoire
		( 'trousse', 'accessoire', 'Trousse de toilette large', 'image-produit.png',  10.9 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='danse_avec_moi')),
		( 'tote bag', 'accessoire', 'Sac en tissus très léger', 'image-produit.png', 12.5 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='orage_et_tunage')),
		( 'sac à dos', 'accessoire', 'Sac à dos assez large et très solide','image-produit.png', 45.6 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='la_fille_de_la_lune')),
		( 'chaussettes', 'accessoire', 'Chaussette super comfortables', 'image-produit.png', 8.9 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='le_monde_a_l_envers')),
		( 'masques', 'accessoire', 'masque de protection pour se protéger des infections', 'image-produit.png',  5.3 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='dans_tes_yeux')),
		( 'pochette', 'accessoire', 'pochette de rangement', 'image-produit.png', 12 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='les_deux_oceans')),
		
        -- papeterie
		( 'cahier à spiral', 'papeterie', 'Cahier avec pages détachables', 'image-produit.png', 4.3 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='dans_la_nuit')),
		( 'carnet à dessin', 'papeterie', 'Carnet de croquis pour artistes', 'image-produit.png', 12.5 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='la_fille_de_la_lune')),
		( 'carte postale', 'papeterie', 'Envoyez un petit message inspirationnel à vos proches', 'image-produit.png', 3.6 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='fougue_du_printemps')),
		( 'sticker', 'papeterie', 'Sticker à accrocher', 'image-produit.png', 3.6 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='le_monde_a_l_envers')),

		 -- art mural
		( 'poster', 'art mural', 'Cahier avec pages détachables', 'image-produit.png',  25.5 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='danceuse_etoile')),
		( 'impression photo', 'art mural', 'Carnet de croquis pour artistes', 'image-produit.png', 12.5 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='les_deux_oceans')),
		( 'tableau décoratif', 'art mural', 'Envoyez un petit message inspirationnel à vos proches', 'image-produit.png', 45.9 , 100 , (SELECT labelIllust from ILLUSTRATION WHERE labelIllust='le_monde_a_l_envers'));



-- Création des commandes en combinant la table COMMANDE et PRODUITS_COMMANDE_USER

	-- Création de toutes les commandes
-- Commande n°1
INSERT INTO COMMANDE (dateCdeUser,user_mailUser)
VALUES ( NOW(), 'hissani.imani@gmail.com'); 

-- Commande n°2
INSERT INTO COMMANDE (dateCdeUser,user_mailUser)
VALUES ( NOW(), 'houssam.imani@gmail.com');

-- Commande n°3
INSERT INTO COMMANDE (dateCdeUser,user_mailUser)
VALUES ( NOW(), 'tom.orhon@gmail.com');

-- Commande n°4
INSERT INTO COMMANDE (dateCdeUser,user_mailUser)
VALUES ( NOW(), 'amina.mroudjae@gmail.com');

-- Commande n°5
INSERT INTO COMMANDE (dateCdeUser,user_mailUser)
VALUES ( NOW(), 'elise.milani@gmail.com');

-- Commande n°6
INSERT INTO COMMANDE (dateCdeUser,user_mailUser)
VALUES ( NOW(), 'hissani.imani@gmail.com'); 

	
-- Ajout des produits par commandes
    
    -- Commande n°1
INSERT INTO PRODUITS_COMMANDE_USER 
VALUES ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 1) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 1), 2 ),
		( (SELECT refProduit FROM PRODUIT WHERE refProduit= 2) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 1), 2 ),
        ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 14) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 1), 2 ),
        ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 17) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 1), 2 ),
        ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 7) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 1), 1 );

	-- Commande n°2
INSERT INTO PRODUITS_COMMANDE_USER 
VALUES ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 1) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 2), 1 ),
		( (SELECT refProduit FROM PRODUIT WHERE refProduit= 2) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 2), 3 ),
        ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 3) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 2), 1 );

	-- Commande n°3
INSERT INTO PRODUITS_COMMANDE_USER 
VALUES ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 11) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 3), 1 ),
		( (SELECT refProduit FROM PRODUIT WHERE refProduit= 5) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 3), 2 ),
        ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 7) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 3), 3 ),
        ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 19) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 3), 5 );

	-- Commande n°4
INSERT INTO PRODUITS_COMMANDE_USER 
VALUES ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 4) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 4), 1 ),
		( (SELECT refProduit FROM PRODUIT WHERE refProduit= 15) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 4), 6 ),
        ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 31) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 4), 1 ),
         ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 3) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 4), 1 ),
        ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 28) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 4), 4 ),
         ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 21) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 4), 3 );

	-- Commande n°5
INSERT INTO PRODUITS_COMMANDE_USER 
VALUES ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 20) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 5), 1 );
		
 	-- Commande n°6
INSERT INTO PRODUITS_COMMANDE_USER 
VALUES ( (SELECT refProduit FROM PRODUIT WHERE refProduit= 1) , (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser= 6), 3 );       
        


-- Création des livraisons 
-- date au format YYYY-mm-dd

	-- livraison commande 1
INSERT INTO LIVRAISON (labelTransporteur,tarifLivraison,dateLivraison,commande_refCdeUser)
VALUES ( 'colissimo', 3.9, '2021-11-25', (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser = 1)) ; 

	-- livraison commande 2
INSERT INTO LIVRAISON (labelTransporteur,tarifLivraison,dateLivraison,commande_refCdeUser)
VALUES ( 'chronospost', 5.8, '2021-11-26', (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser = 2)) ; 

	-- livraison commande 3
INSERT INTO LIVRAISON (labelTransporteur,tarifLivraison,dateLivraison,commande_refCdeUser)
VALUES ( 'mondial relay', 2.9, '2021-11-28', (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser = 3)) ; 

	-- livraison commande 4
INSERT INTO LIVRAISON (labelTransporteur,tarifLivraison,dateLivraison,commande_refCdeUser)
VALUES ( 'FedEX', 7.9, '2021-11-28', (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser = 4)) ; 

	-- livraison commande 5
INSERT INTO LIVRAISON (labelTransporteur,tarifLivraison,dateLivraison,commande_refCdeUser)
VALUES ( 'UPS', 4.9, '2021-11-29', (SELECT refCdeUser FROM COMMANDE WHERE refCdeUser = 5)) ; 

	-- La commande 6 n'a pas de livraison



-- Définition des fournisseurs


INSERT INTO FOURNISSEUR VALUES ('contact-printful@printful.com', 'printful', 'US'); 
INSERT INTO FOURNISSEUR VALUES ('contact-printify@printify.com', 'printify', 'US'); 
INSERT INTO FOURNISSEUR VALUES ('contact-imprimer-aura@imprimer-aura.com', 'imprimer-aura', 'FR'); 
INSERT INTO FOURNISSEUR VALUES ('contact-obtenu@obtenu.com', 'obtenu', 'FR'); 
INSERT INTO FOURNISSEUR VALUES ('contact-teespring@teespring.com', 'teespring', 'US'); 
INSERT INTO FOURNISSEUR VALUES ('contact-spreadshirt@spreadshirt.com', 'spreadshirt', 'US'); 
INSERT INTO FOURNISSEUR VALUES ('contact-redbubble@redbubble.com', 'redbubble', 'US'); 
INSERT INTO FOURNISSEUR VALUES ('contact-zazzle@zazzle.com', 'zazzle', 'US'); 
INSERT INTO FOURNISSEUR VALUES ('contact-sunfrog@sunfrog.com', 'sunfrog', 'US'); 


-- Remplissage de la table PRODUIT_FOURNISSEUR
-- Chaque fournisseur possède ses types de produits 

-- Produits proposés par printful 
INSERT INTO PRODUIT_FOURNISSEUR (labelproduitFournisseur, typeproduitFournisseur, prixProduitFournisseur, fournisseur_mailfournisseur)
VALUES ('coque Iphone X', 'coque', 5, 'contact-printful@printful.com' ),
		('sweatshirt', 'vêtement', 10.5, 'contact-printful@printful.com' ) , 
		('t-shirt', 'vêtement', 7.8, 'contact-printful@printful.com' ),
		('masques', 'accessoire', 2.5, 'contact-printful@printful.com' );   

-- Produits proposés par printify
INSERT INTO PRODUIT_FOURNISSEUR (labelproduitFournisseur, typeproduitFournisseur, prixProduitFournisseur, fournisseur_mailfournisseur)
	VALUES ('coque Iphone X', 'coque', 6.3, 'contact-printify@printify.com' ),
	('coque Samsung Galaxy S20', 'coque', 6.4, 'contact-printify@printify.com' ),
	('coque Ipad mini', 'coque', 7.8, 'contact-printify@printify.com' ),
	('coque MacBook Pro', 'coque', 8, 'contact-printify@printify.com' ),
	('sweatshirt', 'vêtement', 13.5, 'contact-printify@printify.com' ),
	('t-shirt', 'vêtement', 9 , 'contact-printify@printify.com' ),
	('masques', 'accessoire', 1.5 , 'contact-printify@printify.com' );   


-- Produits proposés par imprimer-aura
INSERT INTO PRODUIT_FOURNISSEUR (labelproduitFournisseur, typeproduitFournisseur, prixProduitFournisseur, fournisseur_mailfournisseur)
VALUES ('coque Iphone X', 'coque', 5.9 , 'contact-imprimer-aura@imprimer-aura.com' ),
('sweatshirt', 'vêtement', 12.8 , 'contact-imprimer-aura@imprimer-aura.com' ),  
('t-shirt', 'vêtement', 5.9 , 'contact-imprimer-aura@imprimer-aura.com' ),
('masques', 'accessoire', 0.5, 'contact-imprimer-aura@imprimer-aura.com' ),
('horloge', 'décoration intérieur', 4.8 , 'contact-imprimer-aura@imprimer-aura.com' ), 
('mug', 'décoration intérieur', 7.7 , 'contact-imprimer-aura@imprimer-aura.com' ),
('plaid', 'décoration intérieur', 10 , 'contact-imprimer-aura@imprimer-aura.com' ),
('couvre lit', 'décoration intérieur', 12 , 'contact-imprimer-aura@imprimer-aura.com' ); 


-- Produits proposés par obtenu.com
INSERT INTO PRODUIT_FOURNISSEUR (labelproduitFournisseur, typeproduitFournisseur, prixProduitFournisseur, fournisseur_mailfournisseur)
VALUES ('tote bag', 'accessoire', 5, 'contact-obtenu@obtenu.com' ),
		('trousse', 'accessoire', 3.8 , 'contact-obtenu@obtenu.com' ),
        ('sticker', 'accessoire', 0.75 , 'contact-obtenu@obtenu.com' ),
        ('sac à dos', 'accessoire', 15 , 'contact-obtenu@obtenu.com' ),
        ('chaussettes', 'accessoire', 5 , 'contact-obtenu@obtenu.com' ),
        ('pochette', 'accessoire', 2 , 'contact-obtenu@obtenu.com' ); 

-- Produits proposés par teespring
INSERT INTO PRODUIT_FOURNISSEUR (labelproduitFournisseur, typeproduitFournisseur, prixProduitFournisseur, fournisseur_mailfournisseur)
VALUES ('sweatshirt', 'vêtement', 18, 'contact-teespring@teespring.com' ),  
		('t-shirt', 'vêtement', 14, 'contact-teespring@teespring.com' ),
         ('tote bag', 'accessoire', 5, 'contact-teespring@teespring.com' );
         
         
-- Produits proposés par spreadshirt
INSERT INTO PRODUIT_FOURNISSEUR (labelproduitFournisseur, typeproduitFournisseur, prixProduitFournisseur, fournisseur_mailfournisseur)
VALUES ('sweatshirt', 'vêtement', 16.5, 'contact-spreadshirt@spreadshirt.com' ),  
		('t-shirt', 'vêtement', 12.1, 'contact-spreadshirt@spreadshirt.com' ),
        ('débardeur', 'vêtement', 6.1, 'contact-spreadshirt@spreadshirt.com' ),
        ('robes', 'vêtement', 12 , 'contact-spreadshirt@spreadshirt.com' ),
		('legging', 'vêtement', 8, 'contact-spreadshirt@spreadshirt.com' ),
		('impression photo', 'vêtement', 2 , 'contact-spreadshirt@spreadshirt.com' ),
         ('sac à dos', 'accessoire', 4 , 'contact-spreadshirt@spreadshirt.com' );


-- Produits proposés par redbubble@redbubble.com
INSERT INTO PRODUIT_FOURNISSEUR (labelproduitFournisseur, typeproduitFournisseur, prixProduitFournisseur, fournisseur_mailfournisseur)
VALUES ('poster', 'art mural', 1.75 , 'contact-redbubble@redbubble.com' ),  
		('impression photo', 'art mural', 0.5 , 'contact-redbubble@redbubble.com' ), 
		('tableau décoratif', 'art mural', 6 , 'contact-redbubble@redbubble.com' ), 
        ('cahier à spiral', 'papeterie', 3, 'contact-redbubble@redbubble.com' ), 
		('carnet à dessin', 'papeterie', 7, 'contact-redbubble@redbubble.com' ), 
        ('carte postale', 'papeterie', 1.8 , 'contact-redbubble@redbubble.com' ), 
        ('sticker', 'papeterie', 0.3, 'contact-redbubble@redbubble.com' ), 
		('trousse', 'accessoire', 5.7, 'contact-redbubble@redbubble.com' ), 
        ('tote bag', 'accessoire', 8, 'contact-redbubble@redbubble.com' ), 
		('sac à dos', 'accessoire', 17, 'contact-redbubble@redbubble.com' ), 
        ('chaussettes', 'accessoire', 5, 'contact-redbubble@redbubble.com' ), 
        ('masques', 'accessoire', 3, 'contact-redbubble@redbubble.com' ), 
        ('pochette', 'accessoire', 5, 'contact-redbubble@redbubble.com' ); 


-- Produits proposés par zazzle
INSERT INTO PRODUIT_FOURNISSEUR (labelproduitFournisseur, typeproduitFournisseur, prixProduitFournisseur, fournisseur_mailfournisseur)
VALUES ('poster', 'art mural', 5, 'contact-zazzle@zazzle.com' ); 

-- Produits proposés par unfrog
INSERT INTO PRODUIT_FOURNISSEUR (labelproduitFournisseur, typeproduitFournisseur, prixProduitFournisseur, fournisseur_mailfournisseur)
VALUES ('tote bag', 'accessoire', 7 , 'contact-sunfrog@sunfrog.com' ); 





-- Création achats fournisseurs en combinant la table ACHAT_FOURNISSEUR et PRODUITS_ACHAT_FOURNISSEUR

-- Création de toutes les achats
    
	-- Achat fournisseur n°1
INSERT INTO ACHAT_FOURNISSEUR (dateAchatFournisseur,fournisseur_mailFournisseur)
VALUES ( '2021-06-05', (SELECT mailFournisseur FROM FOURNISSEUR WHERE mailFournisseur='contact-printful@printful.com')); 

	-- Achat fournisseur n°2
INSERT INTO ACHAT_FOURNISSEUR (dateAchatFournisseur,fournisseur_mailFournisseur)
VALUES ( '2021-06-05', (SELECT mailFournisseur FROM FOURNISSEUR WHERE mailFournisseur='contact-printify@printify.com')); 

	-- Achat fournisseur n°3
INSERT INTO ACHAT_FOURNISSEUR (dateAchatFournisseur,fournisseur_mailFournisseur)
VALUES ( '2021-06-05', (SELECT mailFournisseur FROM FOURNISSEUR WHERE mailFournisseur='contact-imprimer-aura@imprimer-aura.com')); 

	-- Achat fournisseur n°4
INSERT INTO ACHAT_FOURNISSEUR (dateAchatFournisseur,fournisseur_mailFournisseur)
VALUES ( '2021-06-05', (SELECT mailFournisseur FROM FOURNISSEUR WHERE mailFournisseur='contact-teespring@teespring.com')); 

	-- Achat fournisseur n°5
INSERT INTO ACHAT_FOURNISSEUR (dateAchatFournisseur,fournisseur_mailFournisseur)
VALUES ( '2021-06-05', (SELECT mailFournisseur FROM FOURNISSEUR WHERE mailFournisseur='contact-spreadshirt@spreadshirt.com')); 

	-- Achat fournisseur n°6
INSERT INTO ACHAT_FOURNISSEUR (dateAchatFournisseur,fournisseur_mailFournisseur)
VALUES ( '2021-06-05', (SELECT mailFournisseur FROM FOURNISSEUR WHERE mailFournisseur='contact-redbubble@redbubble.com')); 


-- Choisir le produit qui necessite un achat fournisseur, la référence de l'achat, et la quantité de produit à ajouter 

    -- Achat fournisseur n°1
INSERT INTO PRODUITS_ACHAT_FOURNISSEUR 
VALUES ((SELECT refProduit FROM PRODUIT WHERE refProduit= 7), (SELECT refAchatFournisseur FROM ACHAT_FOURNISSEUR WHERE refAchatFournisseur=1), 50);

	-- Achat fournisseur n°2
INSERT INTO PRODUITS_ACHAT_FOURNISSEUR 
VALUES ((SELECT refProduit FROM PRODUIT WHERE refProduit= 23), (SELECT refAchatFournisseur FROM ACHAT_FOURNISSEUR WHERE refAchatFournisseur= 2), 50);

	-- Achat fournisseur n°3
INSERT INTO PRODUITS_ACHAT_FOURNISSEUR 
VALUES ((SELECT refProduit FROM PRODUIT WHERE refProduit= 30), (SELECT refAchatFournisseur FROM ACHAT_FOURNISSEUR WHERE refAchatFournisseur= 3), 50);

	-- Achat fournisseur n°4
INSERT INTO PRODUITS_ACHAT_FOURNISSEUR 
VALUES ((SELECT refProduit FROM PRODUIT WHERE refProduit= 17), (SELECT refAchatFournisseur FROM ACHAT_FOURNISSEUR WHERE refAchatFournisseur= 4), 50);

	-- Achat fournisseur n°5
INSERT INTO PRODUITS_ACHAT_FOURNISSEUR 
VALUES ((SELECT refProduit FROM PRODUIT WHERE refProduit= 21), (SELECT refAchatFournisseur FROM ACHAT_FOURNISSEUR WHERE refAchatFournisseur= 5), 50);




-----------------------------------------------------------------------------
-- Procedures
-----------------------------------------------------------------------------
-- Ces prodédures ont étés implémentés pour faciliter l'ajout de nouvelles 
-- informations dans la base 


-- Passer la 1ère commande utilisateur (1 seul produit)
	-- Appel procedure : commandeUser(mail_user VARCHAR, ref_produit INT, qte_produit_commande INT)
	-- ex : call commandeUser('houssam.imani@gmail.com',2, 10);

CREATE OR REPLACE PROCEDURE commandeUser(mail_user VARCHAR, ref_produit INT, qte_produit_commande INT)
LANGUAGE SQL
AS $$
		-- Génération de la commande
		INSERT INTO COMMANDE (dateCdeUser,user_mailUser)
		VALUES ( NOW(),mail_user);

		INSERT INTO PRODUITS_COMMANDE_USER 
		VALUES ( (SELECT refProduit FROM PRODUIT WHERE refProduit= ref_produit) ,
        -- retrouver dernière refcommande a partir de email user
        (select refCdeUser
			FROM COMMANDE, PRODUITS_COMMANDE_USER
            -- variable mail user
			WHERE user_mailUser = mail_user
			GROUP BY refCdeUser
			ORDER BY MAX(dateCdeUser) DESC LIMIT 1
		), qte_produit_commande );
$$;


-- Ajouter produit à la dernier commande créée 
-- Appel procedure : ajouterProduitCommandeUser(mail_user VARCHAR, ref_produit INT, qte_produit_commande INT)
-- ex : call ajouterProduitCommandeUser('houssam.imani@gmail.com',2, 10);

CREATE OR REPLACE PROCEDURE ajouterProduitCommandeUser(mail_user VARCHAR, ref_produit INT, qte_produit_commande INT)
LANGUAGE SQL
AS $$
		INSERT INTO PRODUITS_COMMANDE_USER 
		VALUES ( (SELECT refProduit FROM PRODUIT WHERE refProduit= ref_produit) ,
        -- retrouver dernière refcommande a partir de email user
        (select refCdeUser
			FROM COMMANDE, PRODUITS_COMMANDE_USER
            -- variable mail user
			WHERE user_mailUser = mail_user
			GROUP BY refCdeUser
			ORDER BY MAX(dateCdeUser) DESC LIMIT 1
		), qte_produit_commande );
$$;



-- Passer un achat fournisseur pour un produit  
-- ex : call commandefournisseur('contact-printful@printful.com', 2, 5);

-- AMELIORATION : Stopper la procedure si le fournisseur choisis ne propose pas ce type de produit
-- Si le type de produit est définit comme 'non-materiel', 'tuto' ou 'fond écran' il est impossible de realiser un achat fournisseur

CREATE OR REPLACE PROCEDURE commandefournisseur(f_fournisseur_email VARCHAR, p_ref_produit INT, a_qte_achat_fournisseur INT)
LANGUAGE SQL
AS $$
	INSERT INTO ACHAT_FOURNISSEUR (dateAchatFournisseur,fournisseur_mailFournisseur)
				VALUES (now(), (SELECT mailFournisseur FROM FOURNISSEUR WHERE mailFournisseur= f_fournisseur_email) ); 
                
                
    INSERT INTO PRODUITS_ACHAT_FOURNISSEUR 
				VALUES ( (SELECT refProduit FROM PRODUIT WHERE refProduit = p_ref_produit), 
                (SELECT max(refAchatfournisseur) from ACHAT_FOURNISSEUR), a_qte_achat_fournisseur);
$$;



-- Passer un achat fournisseur pour un produit différent du 1er via la dernière référence d'achat
-- Appel procedure : commandefournisseurAjoutProduit(f_fournisseur_email VARCHAR, p_ref_produit INT, a_qte_achat_fournisseur INT)
-- ex : call commandefournisseurAjoutProduit('contact-printful@printful.com', 1, 5);
CREATE OR REPLACE PROCEDURE commandefournisseurAjoutProduit(f_fournisseur_email VARCHAR, p_ref_produit INT, a_qte_achat_fournisseur INT)
LANGUAGE SQL
AS $$
    INSERT INTO PRODUITS_ACHAT_FOURNISSEUR 
				VALUES ( (SELECT refProduit FROM PRODUIT WHERE refProduit = p_ref_produit), 
                (SELECT max(refAchatfournisseur) from ACHAT_FOURNISSEUR), a_qte_achat_fournisseur);
$$;




-----------------------------------------------------------------------------
-- Function et triggers.
-----------------------------------------------------------------------------



-- Vérifier si la quantité de commande est inférieur au Stock de produit disponible
	-- Si c'est le cas la commande ne peut pas être réalisé et génère une erreure 
	-- On utilise la fonction verifStockProduit et le trigger du même nom pour réaliser cette fonctionnalité

CREATE OR REPLACE FUNCTION verifStockProduit()
RETURNS TRIGGER
AS $$
	DECLARE stock_ok boolean := false;
	BEGIN
		SELECT new.qteCdeUser < stockProduit + 1
        FROM PRODUIT, PRODUITS_COMMANDE_USER
        WHERE refProduit = produit_refProduit 
        INTO stock_ok;
        
        RAISE INFO 'Stock disponible ?%', stock_ok ;
        
        IF (stock_ok != true) 
			THEN RAISE INFO 'Stock insuffisant ?%', stock_ok;
        ELSE
			RETURN new ;
		END IF;
	END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER verifStockProduit
BEFORE INSERT OR UPDATE
ON PRODUITS_COMMANDE_USER
FOR EACH ROW
EXECUTE PROCEDURE verifStockProduit();



--  Mise à jours automatique du stock de produit disponible après commande passé par utilisateur (decrementation)
-- On utilise la fonction miseAjoursStockProduitCommandeUser et le trigger du même nom 

CREATE OR REPLACE FUNCTION miseAjoursStockProduitCommandeUser()
RETURNS TRIGGER
AS $$
	-- DECLARE stock_restant int;
	BEGIN
		-- nouvelle stock de produit
        UPDATE PRODUIT  SET stockProduit = stockProduit - new.qteCdeUser 
        FROM PRODUITS_COMMANDE_USER
        WHERE refProduit = new.produit_refProduit ;
		RETURN new ;
	END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER miseAjoursStockProduitCommandeUser
BEFORE INSERT OR UPDATE
ON PRODUITS_COMMANDE_USER
FOR EACH ROW
EXECUTE PROCEDURE miseAjoursStockProduitCommandeUser();



--  Mise à jours automatique du stock de produit disponible après achat réalisé auprès d'un fournisseur (incrementation)
-- On utilise la fonction miseAjoursStockProduitAchatFournisseur et le trigger du même nom 

CREATE OR REPLACE FUNCTION miseAjoursStockProduitAchatFournisseur()
RETURNS TRIGGER
AS $$
	-- DECLARE stock_restant int;
	BEGIN
		-- nouvelle stock de produit
		UPDATE PRODUIT SET stockProduit = stockProduit + new.qteAchatFournisseur 
        FROM PRODUITS_ACHAT_FOURNISSEUR 
        WHERE refProduit = new.produit_refProduit;
        RETURN new ;
	END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER miseAjoursStockProduitAchatFournisseur
BEFORE INSERT OR UPDATE
ON PRODUITS_ACHAT_FOURNISSEUR
FOR EACH ROW
EXECUTE PROCEDURE miseAjoursStockProduitAchatFournisseur();



-- Passer directement un achat fournisseur lorsque le stock de produit est null 
-- AMELIORATION fonction/procedure pour passer l'appel en choisissant le fournisseur qui produit le type de produit en rupture de stock (1 er sur la liste)

CREATE OR REPLACE FUNCTION passerAchatFournisseur()
RETURNS TRIGGER
AS $$
	BEGIN
		RAISE INFO 'Il est temps de faire une commande fournisseur !';
        PERFORM pg_sleep(10); 
        RAISE INFO 'La commande auprès du fournisseur va etre exécuté';
		call commandefournisseur('contact-printful@printful.com', 2, 100);
        return new;
				
	END;
$$ LANGUAGE PLPGSQL;


CREATE TRIGGER passerAchatFournisseur
AFTER UPDATE OF stockProduit ON PRODUIT
FOR EACH ROW WHEN (NEW.stockProduit = 0)
EXECUTE PROCEDURE passerAchatFournisseur();




-- Après insertion d’une nouvelle commande afficher les informations sur la commande, le client et la livraison

CREATE OR REPLACE FUNCTION afficherCommandeUser()
RETURNS TRIGGER
AS $$
	DECLARE
		mail_user VARCHAR := mailUser from Utilisateur 
			INNER JOIN COMMANDE ON user_mailUser = mailUser
			INNER JOIN PRODUITS_COMMANDE_USER ON commande_refCdeUser = refCdeUser
			WHERE refCdeUser = new.commande_refCdeUser
             GROUP BY mailUser
			;
            
		nom_user VARCHAR := nomUser FROM PRODUITS_COMMANDE_USER, COMMANDE, UTILISATEUR
			WHERE commande_refCdeUser = refCdeUser
			AND user_mailUser = mailUser
			AND refCdeUser =  new.commande_refCdeUser
            GROUP BY nomUser ;
            
            
        prenom_user VARCHAR :=  prenomUser FROM UTILISATEUR, PRODUITS_COMMANDE_USER, COMMANDE
			WHERE commande_refCdeUser = refCdeUser
			AND user_mailUser = mailUser
			AND refCdeUser = new.commande_refCdeUser
            GROUP BY prenomUser ;
            
        label_produit VARCHAR := labelProduit FROM PRODUIT, PRODUITS_COMMANDE_USER 
			WHERE refProduit = produit_refProduit
			AND refProduit =  new.produit_refProduit
			GROUP BY labelProduit ;
            
        -- date_commande DATE := dateCdeUser FROM PRODUITS_COMMANDE_USER, COMMANDE
		-- 	WHERE commande_refCdeUser = refCdeUser
		-- 	AND refCdeUser = new.commande_refCdeUser;
            
		livraison_ok Boolean := false; 
            
        ref_livraison INT := reflivraison
			FROM PRODUITS_COMMANDE_USER, COMMANDE, LIVRAISON
			WHERE PRODUITS_COMMANDE_USER.commande_refCdeUser = COMMANDE.refCdeUser
			AND LIVRAISON.commande_refCdeUser = COMMANDE.refCdeUser
			AND refCdeUser = new.commande_refCdeUser;
            
        date_livraison DATE := datelivraison
			FROM PRODUITS_COMMANDE_USER, COMMANDE, LIVRAISON
			WHERE PRODUITS_COMMANDE_USER.commande_refCdeUser = COMMANDE.refCdeUser
			AND LIVRAISON.commande_refCdeUser = COMMANDE.refCdeUser
			AND refCdeUser = new.commande_refCdeUser;
            
		tarif_livraison DATE := tariflivraison
			FROM PRODUITS_COMMANDE_USER, COMMANDE, LIVRAISON
			WHERE PRODUITS_COMMANDE_USER.commande_refCdeUser = COMMANDE.refCdeUser
			AND LIVRAISON.commande_refCdeUser = COMMANDE.refCdeUser
			AND refCdeUser = new.commande_refCdeUser;
	BEGIN
		-- les infos qu'on a : new.user_mailUser , new.commande_refCommande, new.qteUserCde 
    
		-- INFORMATION UTILISATEUR 
        RAISE INFO 'Mail utilisateur : %', mail_user;
        RAISE INFO 'Prenom utilisateur : %', prenom_user;
        RAISE INFO 'Nom utilisateur : % ', nom_user;
    
		-- INFORMATION COMMANDE
		RAISE INFO 'Commande n° % ', new.commande_refCdeUser;
        -- RAISE INFO 'Date commande : % ', date_commande;
        
        -- INFORMATION PRODUIT
        RAISE INFO 'Produit n° %', new.produit_refProduit;
        RAISE INFO 'Label produit : %', label_produit;
        RAISE INFO 'Quantité produit : % ', new.qteCdeUser ;
        
        -- INFORMATION LIVRAISON
        SELECT reflivraison
		FROM PRODUITS_COMMANDE_USER, COMMANDE, LIVRAISON
		WHERE PRODUITS_COMMANDE_USER.commande_refCdeUser = COMMANDE.refCdeUser
		AND LIVRAISON.commande_refCdeUser = COMMANDE.refCdeUser
		AND refCdeUser = new.commande_refCdeUser 
        INTO livraison_ok;
        
		RAISE INFO 'Livraison prévue ? : %', livraison_ok;
        IF (livraison_ok != false)
			THEN 
				RAISE INFO 'Date livraison : %', ref_livraison;
				RAISE INFO 'Date livraison : %', date_livraison;
				RAISE INFO 'Tarif livraison : % \n', tarif_livraison ;
        END IF;
		
        return new;
	END;
$$ LANGUAGE PLPGSQL;


CREATE TRIGGER afficherCommandeUser
AFTER INSERT OR UPDATE
ON PRODUITS_COMMANDE_USER
FOR EACH ROW
EXECUTE PROCEDURE afficherCommandeUser();






-----------------------------------------------------------------------------
-- Vues 
-----------------------------------------------------------------------------
-- Afficher plus simplement les informations importantes selectionnées

-- Implémentation d'une vue de commandes triés par produits différents commandés
-- Cette vue permet de voir 
		-- les informations de base sur les commandes : refCdeUser, dateCdeUser, qteCdeUser
        -- quel client est à l'origine de la commande : mailUser
        -- les informations de base sur les produits commandés : labelProduit, illustration_labelIllust, prixProduit (prix unitaire)
        -- le prix total prix pour la quantité commandé 
        -- le prix total par référence de commande pour tous les  produits différents commandés 
-- Tester la vue avec la commande sql : select * FROM commandesParProduits;

CREATE VIEW commandesParProduits AS
   SELECT refCdeUser, dateCdeUser, user_mailUser, labelproduit, illustration_labelIllust, prixProduitCde AS prix_Unite, qteCdeUser, (qteCdeUser * prixProduitCde) AS Prix_total_produit,   -- , refLivraison
	SUM(qteCdeUser * prixProduitCde) over (partition by refCdeUser) AS prix_total_cde
	FROM PRODUIT
	RIGHT OUTER JOIN PRODUITS_COMMANDE_USER on refProduit = produit_refProduit
	RIGHT OUTER JOIN COMMANDE on COMMANDE.refCdeUser = PRODUITS_COMMANDE_USER.commande_refCdeUser
	RIGHT OUTER JOIN UTILISATEUR on mailUser = user_mailUser
	RIGHT OUTER JOIN ILLUSTRATION on illustration_labelillust = labelIllust
	-- RIGHT OUTER JOIN LIVRAISON on COMMANDE.refCdeUser = LIVRAISON.commande_refCdeUser
	GROUP BY refCdeUser, labelproduit, illustration_labelIllust, qteCdeUser, prixProduitCde -- , refLivraison
	ORDER BY MAX(dateCdeUser) DESC;
    

-- Implémentation d'une vue de commandes triés par référence de commande et utilisateur
-- Cette vue permet de voir : 
	-- le numéro et la date des dernières commandes réalisés (sans répétitions)
    -- le client à l'origine de la commande (mailUser)
    -- le nombre de produits différents commandés pour cette commande  
    
 CREATE VIEW commandesParRefCdeUser AS   
 SELECT refCdeUser, mailuser, dateCdeUser, count(*) AS Nbr_produits
	FROM PRODUIT
	RIGHT OUTER JOIN PRODUITS_COMMANDE_USER on refProduit = produit_refProduit
	RIGHT OUTER JOIN COMMANDE on COMMANDE.refCdeUser = PRODUITS_COMMANDE_USER.commande_refCdeUser
	RIGHT OUTER JOIN UTILISATEUR on mailUser = user_mailUser
	RIGHT OUTER JOIN ILLUSTRATION on illustration_labelillust = labelIllust
	-- RIGHT OUTER JOIN LIVRAISON on COMMANDE.refCdeUser = LIVRAISON.commande_refCdeUser
	GROUP BY refCdeUser, mailuser
	ORDER BY MAX(dateCdeUser) DESC;
    
    
-----------------------------------------------------------------------------
-- Vues / Fonctions à implementer dans le futur
-----------------------------------------------------------------------------
 
-- Faire la fonction afficherCommandeUser() pour les achat fournisseur
    
    
-- Pour le côté admin implémenter une vue pour afficher :
	-- Afficher le nombre total de produit acheté / vs produit vendus
	-- calculer le chiffre d'affaire (CA) de l'entreprise par les commandes utilisateurs réalisés 
	-- En supposant que la TVA est à un taux fixe pour tous les produits afficher le total de l'argent prélevé par la TVA 
    -- On supporte que les impots prélèves 20% de ce chiffre d'affaire on l'affiche
    -- l'argent total mis dans l'achat de produits aux fournisseurs
    -- le bénéfice total réalisé par l'entreprise  (en soustrayant la TVA et les impots)
    
   -- Faire une étude poussé du produit/illustration 
	-- Produit le plus vendu / produit le moins vendu
    -- Illustration la plus vendu (tous produits confondus) / illust la moins vendu
    
-- Faire une étude poussé de l'utilisateur 
	-- age moyen client 
    -- client qui a réalisé le plus de commande (classement)
    
-- Gestion des mails 
-- Envoyer un mail à chaque utilisateur lors de son insertion dans la base de donnée ainsi que lors de la finalisation d’une commande
-- Envoyer un mail à chaque user pour son anniversaire 
