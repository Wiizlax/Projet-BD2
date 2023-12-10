DROP SCHEMA IF EXISTS projet CASCADE;
CREATE SCHEMA projet;
CREATE TABLE projet.mots_cles (
                                  id_mot_cle SERIAL PRIMARY KEY,
                                  mot VARCHAR(100) NOT NULL UNIQUE
                                      CHECK(mot<>'')
);

CREATE TABLE projet.entreprises (
                                    id_entreprise CHAR(3) PRIMARY KEY ,
                                    nom_entreprise VARCHAR(100) NOT NULL ,
                                    adresse_entreprise VARCHAR(100) NOT NULL UNIQUE CHECK(adresse_entreprise<>''),
                                    adresse_mail VARCHAR(100) NOT NULL UNIQUE,
                                    mot_de_passe  VARCHAR(100) NOT NULL,
                                    CHECK(id_entreprise SIMILAR TO '[A-Z][A-Z][A-Z]'),
                                    CHECK(nom_entreprise<>''),
                                    CHECK(mot_de_passe<>'')
);

CREATE TABLE projet.etudiants (
                                  id_etudiant SERIAL PRIMARY KEY,
                                  nom_etudiant VARCHAR(100) NOT NULL,
                                  prenom_etudiant VARCHAR(100) NOT NULL,
                                  mail VARCHAR(100) NOT NULL UNIQUE,
                                  semestre_stage CHAR(2) NOT NULL,
                                  mot_de_passe VARCHAR(100) NOT NULL,
                                  nbr_candidature_en_attente int not null default 0,

                                  CHECK(nom_etudiant<>''),
                                  CHECK(prenom_etudiant<>''),
                                  CHECK(semestre_stage='Q1' OR semestre_stage='Q2'),
                                  CHECK(mot_de_passe !=''),
                                  CHECK(mail <> '' and mail similar to '%@student.vinci.be')
);
CREATE TABLE projet.offres_de_stage (
                                        id_offre_stage SERIAL PRIMARY KEY,
                                        entreprise CHAR(3) NOT NULL REFERENCES projet.entreprises(id_entreprise),
                                        code_stage VARCHAR(10) NULL,
                                        etat VARCHAR(25) NOT NULL DEFAULT 'non validée' ,
                                        semestre_stage CHAR(2) NOT NULL ,
                                        description VARCHAR(255) NOT NULL ,
                                        etudiant INT NULL REFERENCES projet.etudiants(id_etudiant) DEFAULT NULL,

                                        CHECK(etat='non validée' OR etat='validée' OR etat='attribuée' OR etat='annulée'),
                                        CHECK(semestre_stage='Q1' OR semestre_stage='Q2'),
                                        CHECK(description!=''),
                                        CHECK (code_stage != '' ),
                                        CONSTRAINT check_etat_etudiant CHECK((etat = 'attribuée' AND etudiant IS NOT NULL) OR (etat != 'attribuée'))
);
CREATE TABLE projet.mots_des_offres (
                                        mot_cle INT NOT NULL REFERENCES projet.mots_cles(id_mot_cle),
                                        offre INT NOT NULL REFERENCES projet.offres_de_stage(id_offre_stage),
                                        PRIMARY KEY(mot_cle,offre)
);

CREATE TABLE projet.candidatures (
                                     etat VARCHAR(25) NOT NULL DEFAULT 'en attente' ,
                                     code_offre INT NOT NULL REFERENCES projet.offres_de_stage(id_offre_stage),
                                     etudiant INT NOT NULL REFERENCES projet.etudiants(id_etudiant),
                                     motivation_etudiant varchar(255) not null,
                                     PRIMARY KEY(code_offre,etudiant),
                                     check ( motivation_etudiant <> ''),
                                     CHECK(etat='en attente' OR etat='refusée' OR etat='acceptée' OR etat='annulée')
);

------------------------------------------INSERT-------------------------------------------------------------

INSERT INTO projet.mots_cles (mot) VALUES
                                       ('Java'),
                                       ('Web'),
                                       ('Python');

INSERT INTO projet.etudiants (nom_etudiant, prenom_etudiant, mail, semestre_stage, mot_de_passe, nbr_candidature_en_attente) VALUES
                                                                                                                                 ('De', 'Jean', 'j.d@student.vinci.be', 'Q2', '$2a$10$pADNNXEwdzo7JCmFEPBV0.s9DDHZaC6wFKoLqJN2iZZ00YH6UPhmm',1),
                                                                                                                                 ('Du', 'Marc', 'm.d@student.vinci.be', 'Q1', '$2a$10$tH8lGytrCRc7UHgzJTbeC.zpzxcGLuE/TxvFvyXAn4NccEuqtwPGW',1);

INSERT INTO projet.entreprises (id_entreprise, nom_entreprise, adresse_entreprise, adresse_mail, mot_de_passe) VALUES
                                                                                                                   ('VIN', 'VINCI', 'Adresse_vinci', 'vinci@vinci.be', 'vinci'),
                                                                                                                   ('ULB', 'ULB', 'Adresse_ULB', 'ulb@gmail.be', 'ulb');

INSERT INTO projet.offres_de_stage (entreprise, code_stage, etat, semestre_stage, description, etudiant) VALUES
                                                                                                             ('VIN', 'VIN1', 'validée', 'Q2', 'stage SAP', NULL),
                                                                                                             ('VIN', 'VIN2', 'non validée', 'Q2', 'stage BI', NULL),
                                                                                                             ('VIN', 'VIN3', 'non validée', 'Q2', 'stage Unity', NULL),
                                                                                                             ('VIN', 'VIN4', 'validée', 'Q2', 'stage IA', NULL),
                                                                                                             ('VIN', 'VIN5', 'validée', 'Q1', 'stage mobile', NULL),
                                                                                                             ('ULB', 'ULB1', 'validée', 'Q2', 'stage javascript', NULL),
                                                                                                             ('ULB', 'ULB2', 'annulée', 'Q2', 'stage javascript', NULL);

INSERT INTO projet.mots_des_offres (mot_cle, offre) VALUES
                                                        (1, 3),
                                                        (1, 5);

INSERT INTO projet.candidatures (etat, code_offre, etudiant, motivation_etudiant) VALUES
                                                                                      ('en attente', 4, 1, 'Je veux de l argent'),
                                                                                      ('en attente', 5, 2, 'Je souhaite travailler chez vous car votre entreprise m intéresse'),
                                                                                      ('en attente', 5, 1, 'Je souhaite travailler chez vous car votre entreprise m intéresse'),
                                                                                      ('en attente', 4, 2, 'Je souhaite travailler chez vous car votre entreprise m intéresse');






