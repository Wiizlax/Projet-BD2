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
    code_stage VARCHAR(10) NOT NULL,
    etat VARCHAR(25) NOT NULL DEFAULT 'non validée' ,
    semestre_stage CHAR(2) NOT NULL ,
    description VARCHAR(255) NOT NULL ,
    etudiant INT NULL REFERENCES projet.etudiants(id_etudiant) DEFAULT NULL,

    CHECK(etat='non validée' OR etat='validée' OR etat='attribuée' OR etat='annulée'),
    CHECK(semestre_stage='Q1' OR semestre_stage='Q2'),
     CHECK(description!=''),
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
    ('SQL'),
    ('Python'),
    ('C');

INSERT INTO projet.entreprises (id_entreprise, nom_entreprise, adresse_entreprise, adresse_mail, mot_de_passe) VALUES
    ('ABC', 'Entreprise1', 'Adresse1', 'entreprise1@gmail.com', 'password1'),
    ('DEF', 'Entreprise2', 'Adresse2', 'entreprise2@gmail.com', 'password2'),
    ('GHI', 'Entreprise3', 'Adresse3', 'entreprise3@gmail.com', 'password3');


INSERT INTO projet.etudiants (nom_etudiant, prenom_etudiant, mail, semestre_stage, mot_de_passe, nbr_candidature_en_attente) VALUES
    ('Nom1', 'Prenom1', 'student1@student.vinci.be', 'Q1', 'password1',1),
    ('Nom2', 'Prenom2', 'student2@student.vinci.be', 'Q2', 'password2',1),
    ('Nom3', 'Prenom3', 'student3@student.vinci.be', 'Q1', 'password3',1);


INSERT INTO projet.offres_de_stage (entreprise, code_stage, etat, semestre_stage, description, etudiant) VALUES
    ('ABC', 'CODE1', 'non validée', 'Q1', 'Description offre 1', NULL),
    ('DEF', 'CODE2', 'validée', 'Q2', 'Description offre 2', NULL),
    ('GHI', 'CODE3', 'attribuée', 'Q1', 'Description offre 3', 1);
INSERT INTO projet.mots_des_offres (mot_cle, offre) VALUES
    (1, 1),
    (2, 2),
    (3, 3);

INSERT INTO projet.candidatures (etat, code_offre, etudiant, motivation_etudiant) VALUES
    ('en attente', 1, 2, 'Je veux de l argent'),
    ('acceptée', 3, 1, 'Je souhaite travailler chez vous car votre entreprise m intéresse'),
    ('refusée', 2, 3, 'Je suis désespére pour un stage');


-----------------------Professeur-------------------------------------

--requête point 4 professeur--
create view projet.offres_non_validees as
select ods.code_stage, ods.semestre_stage, e.nom_entreprise, ods.description
from projet.offres_de_stage ods,
     projet.entreprises e
where e.id_entreprise = ods.entreprise
  and ods.etat = 'non validée';

select *
from projet.offres_non_validees;

-- Application Professeur : point 5
CREATE OR REPLACE FUNCTION validerOffreDeStage(code VARCHAR (10)) RETURNS INTEGER AS $$
    DECLARE
        num_offre INTEGER;
        offre RECORD;
    BEGIN
        FOR offre IN SELECT * FROM projet.offres_de_stage LOOP
            IF offre.code_stage != code THEN
                RAISE 'code de offre inexistant';
            END IF;

            IF offre.code_stage = code THEN
                EXIT;
            END IF;
        END LOOP;
        UPDATE projet.offres_de_stage SET etat = 'validée' WHERE etat = 'non validée' RETURNING id_offre_stage INTO num_offre;
        RETURN num_offre;
    END;
$$ LANGUAGE plpgsql;

SELECT validerOffreDeStage('CODE1');

--requête point 6 professeur--
create view projet.offres_validees as
select ods.code_stage, ods.semestre_stage, e.nom_entreprise, ods.description
from projet.offres_de_stage ods,
     projet.entreprises e
where e.id_entreprise = ods.entreprise
  and ods.etat = 'validée';

select *
from projet.offres_validees;

--requête point 7 professeur--
create view projet.etudiants_sans_stages as
select e.nom_etudiant, e.prenom_etudiant, e.mail, e.semestre_stage, e.nbr_candidature_en_attente
from projet.etudiants e,
     projet.candidatures c
where c.etudiant = e.id_etudiant
  and c.etat <> 'acceptée';

--requête point 8 professeur--
create view projet.offres_attribuees as
select ods.code_stage, en.nom_entreprise, e.nom_etudiant, e.prenom_etudiant
from projet.offres_de_stage ods,
     projet.etudiants e,
     projet.entreprises en
where ods.etudiant = e.id_etudiant
  and en.id_entreprise = ods.entreprise
and ods.etat = 'attribuée';

-----------------------Entreprise-------------------------------------
--requête point 2 entreprise--
create view projet.mots_cles_disponibles as
select mc.id_mot_cle , mc.mot
from projet.mots_cles mc;

--requête point 4 entreprise--
create view projet.verifier_offres_stage as
SELECT os.code_stage, os.description , os.semestre_stage , os.etat ,COUNT(ca.etudiant) AS "Nbr_candidature", COALESCE(et.nom_etudiant,'non atribuée')
FROM projet.candidatures ca ,projet.offres_de_stage os
LEFT OUTER JOIN projet.etudiants et ON et.id_etudiant = os.etudiant
WHERE os.id_offre_stage = ca.code_offre
group by os.code_stage, os.description, os.semestre_stage, os.etat, COALESCE(et.nom_etudiant,'non atribuée');

select * FROM projet.verifier_offres_stage;

--requête point 5 entreprise--
CREATE VIEW projet.candidatures_pour_offre AS
SELECT
    c.etat,
    e.nom_etudiant,
    e.prenom_etudiant,
    e.mail,
    c.motivation_etudiant,
    ods.code_stage
FROM
    projet.candidatures c, projet.offres_de_stage ods
LEFT JOIN
    projet.etudiants e ON c.etudiant = e.id_etudiant
WHERE
    c.code_offre = (SELECT id_offre_stage FROM projet.offres_de_stage ods2 WHERE ods2.code_stage = ods.code_stage);

SELECT *
FROM projet.candidatures_pour_offre;
