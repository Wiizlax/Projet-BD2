DROP SCHEMA IF EXISTS projet CASCADE;
CREATE SCHEMA projet;
CREATE TABLE projet.mots_cles
(
    id_mot_cle SERIAL PRIMARY KEY,
    mot        VARCHAR(100) NOT NULL UNIQUE
        CHECK (mot <> '')
);

CREATE TABLE projet.entreprises
(
    id_entreprise      CHAR(3) PRIMARY KEY,
    nom_entreprise     VARCHAR(100) NOT NULL,
    adresse_entreprise VARCHAR(100) NOT NULL UNIQUE CHECK (adresse_entreprise <> ''),
    adresse_mail       VARCHAR(100) NOT NULL UNIQUE,
    mot_de_passe       VARCHAR(100) NOT NULL,
    CHECK (id_entreprise SIMILAR TO '[A-Z][A-Z][A-Z]'),
    CHECK (nom_entreprise <> ''),
    CHECK (mot_de_passe <> '')
);

CREATE TABLE projet.etudiants
(
    id_etudiant                SERIAL PRIMARY KEY,
    nom_etudiant               VARCHAR(100) NOT NULL,
    prenom_etudiant            VARCHAR(100) NOT NULL,
    mail                       VARCHAR(100) NOT NULL UNIQUE,
    semestre_stage             CHAR(2)      NOT NULL,
    mot_de_passe               VARCHAR(100) NOT NULL,
    nbr_candidature_en_attente int          not null default 0,

    CHECK (nom_etudiant <> ''),
    CHECK (prenom_etudiant <> ''),
    CHECK (semestre_stage = 'Q1' OR semestre_stage = 'Q2'),
    CHECK (mot_de_passe != ''),
    CHECK (mail <> '' and mail similar to '%@student.vinci.be')
);
CREATE TABLE projet.offres_de_stage
(
    id_offre_stage SERIAL PRIMARY KEY,
    entreprise     CHAR(3)      NOT NULL REFERENCES projet.entreprises (id_entreprise),
    code_stage     VARCHAR(10)  NOT NULL,
    etat           VARCHAR(25)  NOT NULL DEFAULT 'non validée',
    semestre_stage CHAR(2)      NOT NULL,
    description    VARCHAR(255) NOT NULL,
    etudiant       INT          NULL REFERENCES projet.etudiants (id_etudiant) DEFAULT NULL,

    CHECK (etat = 'non validée' OR etat = 'validée' OR etat = 'attribuée' OR etat = 'annulée'),
    CHECK (semestre_stage = 'Q1' OR semestre_stage = 'Q2'),
    CHECK (description != ''),
    CONSTRAINT check_etat_etudiant CHECK ((etat = 'attribuée' AND etudiant IS NOT NULL) OR (etat != 'attribuée'))
);
CREATE TABLE projet.mots_des_offres
(
    mot_cle INT NOT NULL REFERENCES projet.mots_cles (id_mot_cle),
    offre   INT NOT NULL REFERENCES projet.offres_de_stage (id_offre_stage),
    PRIMARY KEY (mot_cle, offre)
);

CREATE TABLE projet.candidatures
(
    etat                VARCHAR(25)  NOT NULL DEFAULT 'en attente',
    code_offre          INT          NOT NULL REFERENCES projet.offres_de_stage (id_offre_stage),
    etudiant            INT          NOT NULL REFERENCES projet.etudiants (id_etudiant),
    motivation_etudiant varchar(255) not null,
    PRIMARY KEY (code_offre, etudiant),
    check ( motivation_etudiant <> ''),
    CHECK (etat = 'en attente' OR etat = 'refusée' OR etat = 'acceptée' OR etat = 'annulée')
);

------------------------------------------INSERT-------------------------------------------------------------

INSERT INTO projet.mots_cles (mot)
VALUES ('Java'),
       ('Web'),
       ('Python');

INSERT INTO projet.etudiants (nom_etudiant, prenom_etudiant, mail, semestre_stage, mot_de_passe,
                              nbr_candidature_en_attente)
VALUES ('De', 'Jean', 'j.d@student.vinci.be', 'Q2', 'jd', 1),
       ('Du', 'Marc', 'm.d@student.vinci.be', 'Q1', 'md', 1);

INSERT INTO projet.entreprises (id_entreprise, nom_entreprise, adresse_entreprise, adresse_mail, mot_de_passe)
VALUES ('VIN', 'VINCI', 'Adresse_vinci', 'vinci@vinci.be', 'vinci'),
       ('ULB', 'ULB', 'Adresse_ULB', 'ulb@gmail.be', 'ulb');

INSERT INTO projet.offres_de_stage (entreprise, code_stage, etat, semestre_stage, description, etudiant)
VALUES ('VIN', 'VIN1', 'validée', 'Q2', 'stage SAP', NULL),
       ('VIN', 'VIN2', 'non validée', 'Q2', 'stage BI', NULL),
       ('VIN', 'VIN3', 'non validée', 'Q2', 'stage Unity', NULL),
       ('VIN', 'VIN4', 'validée', 'Q2', 'stage IA', NULL),
       ('VIN', 'VIN5', 'validée', 'Q1', 'stage mobile', NULL),
       ('ULB', 'ULB1', 'validée', 'Q2', 'stage javascript', NULL);

INSERT INTO projet.mots_des_offres (mot_cle, offre)
VALUES (1, 3),
       (1, 5);

INSERT INTO projet.candidatures (etat, code_offre, etudiant, motivation_etudiant)
VALUES ('en attente', 4, 1, 'Je veux de l argent'),
       ('en attente', 5, 2, 'Je souhaite travailler chez vous car votre entreprise m intéresse');

------------------------------------------REQUÊTES---------------------------------------------------------------

--requête point 4 professeur--
create view projet.offres_non_validees as
select ods.code_stage, ods.semestre_stage, e.nom_entreprise, ods.description
from projet.offres_de_stage ods,
     projet.entreprises e
where e.id_entreprise = ods.entreprise
  and ods.etat = 'non validée';

select *
from projet.offres_non_validees;

---------- 5 aplication professeur ---------------------
-- Création de la fonction pour valider une offre de stage en modifiant son état à "validée"
CREATE OR REPLACE FUNCTION projet.valider_offre(id_offre_a_modifier INTEGER) RETURNS INTEGER AS
$$
DECLARE
BEGIN
    -- Mettre à jour l'état de l'offre spécifiée à "validée"
UPDATE projet.offres_de_stage
SET etat = 'validée'
WHERE id_offre_stage = id_offre_a_modifier;
RETURN id_offre_a_modifier;
END
$$ LANGUAGE plpgsql;

-- Création de la fonction est_non_valide qui vérifie si l'état est "non validée" avant la mise à jour
CREATE OR REPLACE FUNCTION projet.avant_valider_offre() RETURNS TRIGGER AS
$$
DECLARE
BEGIN
    -- Vérifier si l'état avant la mise à jour est "non validée"
    IF (OLD.etat <> 'non validée' AND NEW.etat = 'validée') THEN
        RAISE 'Impossible de valider une offre de stage dont l état n est pas non validée.';
END IF;
    IF (OLD.etat <> 'validée' AND NEW.etat = 'attribuée') THEN
        RAISE 'Impossible d attribuer une offre de stage dont l eétat n est pas validée.';
END IF;
RETURN NEW;
END
$$ LANGUAGE plpgsql;

-- Création du déclencheur (trigger) pour appeler la fonction avant la mise à jour de la table des offres
CREATE TRIGGER valider_offre_trigger
    BEFORE UPDATE OF etat
    ON projet.offres_de_stage
    FOR EACH ROW
    WHEN (NEW.etat = 'validée')
    EXECUTE PROCEDURE projet.avant_valider_offre();

SELECT * FROM projet.valider_offre('ULB1');

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

select *
from projet.etudiants_sans_stages;

--requête point 8 professeur--
create view projet.offres_attribuees as
select ods.code_stage, en.nom_entreprise, e.nom_etudiant, e.prenom_etudiant
from projet.offres_de_stage ods,
     projet.etudiants e,
     projet.entreprises en
where ods.etudiant = e.id_etudiant
  and en.id_entreprise = ods.entreprise
  and ods.etat = 'attribuée';

select *
from projet.offres_attribuees;

--requête point 2 entreprise--
create view projet.mots_cles_disponibles as
select mc.id_mot_cle, mc.mot
from projet.mots_cles mc;

select *
from projet.mots_cles_disponibles;

-- Application Entreprise : point 3 --
CREATE OR REPLACE FUNCTION projet.ajoutMotCleAUneOffre(id_entreprise CHAR(3), code VARCHAR(10), _mot_cle VARCHAR(100)) RETURNS INTEGER AS
$$
DECLARE
id_mot_cle_offre INTEGER := 0;
    id_mot           INTEGER := 0;
    id_offre         INTEGER := 0;
    code_offre       INTEGER := 0;
BEGIN
    IF NOT EXISTS(SELECT * FROM projet.offres_de_stage WHERE entreprise = id_entreprise AND code = code_stage) THEN
        RAISE 'pas une offre de l entreprise';
END IF;

    IF EXISTS(SELECT *
              FROM projet.offres_de_stage
              WHERE entreprise = id_entreprise
                AND code_stage = code
                AND (etat = 'attribuée' OR etat = 'annulée')) THEN
        RAISE 'ajout mot clé impossible';
END IF;

    IF NOT EXISTS(SELECT * FROM projet.mots_cles WHERE mot = _mot_cle) THEN
        RAISE 'mot existe pas';
END IF;

    IF EXISTS(SELECT mo.offre
              FROM projet.offres_de_stage os,
                   projet.mots_des_offres mo
              WHERE os.code_stage = code
                AND os.id_offre_stage
                  = mo.offre
              GROUP BY mo.offre
              HAVING COUNT(mo.*) = 3) THEN
        RAISE 'trop de mots pour cette offre';
END IF;

SELECT id_mot_cle FROM projet.mots_cles WHERE _mot_cle = mot INTO id_mot;

SELECT id_offre_stage FROM projet.offres_de_stage WHERE code_stage = code INTO code_offre;

INSERT INTO projet.mots_des_offres
VALUES (id_mot, code_offre)
    RETURNING mot_cle, offre INTO id_mot_cle_offre;
RETURN id_mot_cle_offre;
END;
$$ LANGUAGE plpgsql;

select *
from projet.ajoutMotCleAUneOffre('VIN','VIN1','Web');

--requête point 4 entreprise--
create or replace view projet.verifier_offres_stage as
SELECT os.code_stage,
       os.description,
       os.semestre_stage,
       os.etat,
       COUNT(ca.etudiant) AS "Nbr_candidature",
       COALESCE(et.nom_etudiant, 'non atribuée')
FROM projet.offres_de_stage ods
         left outer join projet.candidatures ca on ods.id_offre_stage = ca.code_offre,
     projet.offres_de_stage os
         LEFT OUTER JOIN projet.etudiants et ON et.id_etudiant = os.etudiant
group by os.code_stage, os.description, os.semestre_stage, os.etat, COALESCE(et.nom_etudiant, 'non atribuée');

select *
FROM projet.verifier_offres_stage;

--procédure point 5 entreprise--
CREATE OR REPLACE FUNCTION projet.getCandidaturesPourOffre(code_offre_param VARCHAR(10))
    RETURNS TABLE
            (
                etat                VARCHAR(25),
                nom_etudiant        VARCHAR(100),
                prenom_etudiant     VARCHAR(100),
                mail_etudiant       VARCHAR(100),
                motivation_etudiant VARCHAR(255)
            )
AS
$$
BEGIN
RETURN QUERY
SELECT c.etat,
       e.nom_etudiant,
       e.prenom_etudiant,
       e.mail,
       c.motivation_etudiant
FROM projet.candidatures c
         LEFT JOIN
     projet.etudiants e ON c.etudiant = e.id_etudiant
WHERE c.code_offre =
      (SELECT ods.id_offre_stage FROM projet.offres_de_stage ods WHERE ods.code_stage = code_offre_param);

IF NOT FOUND THEN
        RAISE EXCEPTION 'Il n''y a pas de candidatures pour cette offre ou vous n''avez pas d''offre ayant ce code';
END IF;
END;
$$ LANGUAGE plpgsql;

SELECT *
FROM projet.getCandidaturesPourOffre('VIN5');

-------point 6 Entreprise----------------

--- Function qui accepte un etudiant pour une offre de stage
CREATE OR REPLACE FUNCTION projet.selectionner_etudiant(id_offre_param INTEGER, mail_etudiant VARCHAR(255))
    RETURNS VOID AS
$$
DECLARE
offre            RECORD;
    etudiant_accepte RECORD;
    --nbr_candidature_en_attente INTEGER;
BEGIN
    -- Recherche de l'offre et de l'étudiant
SELECT * FROM projet.offres_de_stage WHERE id_offre_stage = id_offre_param INTO offre;
SELECT * FROM projet.etudiants WHERE mail = mail_etudiant INTO etudiant_accepte;

-- Vérification de l'existence de l'offre et de l'étudiant
IF NOT FOUND THEN
        RAISE EXCEPTION 'Offre ou étudiant inexistant(e)';
END IF;


    -- Mise à jour de l'état de l'offre
UPDATE projet.offres_de_stage SET etudiant = etudiant_accepte.id_etudiant WHERE id_offre_stage = id_offre_param;
UPDATE projet.offres_de_stage SET etat = 'attribuée' WHERE id_offre_stage = id_offre_param;
END;
$$ LANGUAGE plpgsql;


----- Function qui fait les updates avant l'acceptation
CREATE OR REPLACE FUNCTION projet.avant_acceptation_offre()
    RETURNS TRIGGER AS
$$
DECLARE
offre            RECORD;
    etudiant_accepte RECORD;
BEGIN

    -- Recherche de l'offre et de l'étudiant
SELECT * FROM projet.offres_de_stage WHERE id_offre_stage = OLD.id_offre_stage INTO offre;
SELECT * FROM projet.etudiants WHERE id_etudiant = OLD.etudiant INTO etudiant_accepte;

-- Vérification de l'état de l'offre et de la candidature OR etudiant_accepte.nbr_candidature_en_attente = 0
IF offre.etat != 'validée' THEN
        RAISE EXCEPTION 'L''offre n''est pas dans l''état "validée"';
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

----- Function qui fait les updates apres l'acceptation
CREATE OR REPLACE FUNCTION projet.apres_acceptation_offre()
    RETURNS TRIGGER AS
$$
DECLARE
offre            RECORD;
    etudiant_accepte RECORD;
BEGIN

    -- Recherche de l'offre et de l'étudiant
SELECT * FROM projet.offres_de_stage WHERE id_offre_stage = NEW.id_offre_stage INTO offre;
SELECT * FROM projet.etudiants WHERE id_etudiant = NEW.etudiant INTO etudiant_accepte;


-- Mise à jour de l'état de la candidature
UPDATE projet.candidatures
SET etat = 'acceptée'
WHERE code_offre = offre.id_offre_stage
  AND etudiant = etudiant_accepte.id_etudiant;

-- Annulation des autres offres de stage de l'entreprise pour ce semestre
UPDATE projet.offres_de_stage
SET etat = 'annulée'
WHERE entreprise = offre.entreprise
  AND semestre_stage = offre.semestre_stage
  AND etat <> 'attribuée';

-- Mise à jour des autres candidatures en attente de cet étudiant
UPDATE projet.candidatures
SET etat = 'annulée'
WHERE etudiant = etudiant_accepte.id_etudiant;

-- Mise à jour des autres candidatures en attente de cette offre
UPDATE projet.candidatures
SET etat = 'refusée'
WHERE code_offre = offre.id_offre_stage;

-- Refus de toutes les autres candidatures de stage de l'entreprise pour ce semestre
UPDATE projet.candidatures
SET etat = 'refusée'
WHERE code_offre IN (
    SELECT id_offre_stage
    FROM projet.offres_de_stage
    WHERE id_offre_stage = offre.id_offre_stage
      AND entreprise = offre.entreprise
      AND semestre_stage = offre.semestre_stage
      AND etat = 'annulée'
);

-- Mise à jour de l'état de la candidature de l'étudiant
UPDATE projet.candidatures
SET etat = 'acceptée'
WHERE code_offre = NEW.id_offre_stage
  AND etudiant = etudiant_accepte.id_etudiant;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger apres acceptation
CREATE TRIGGER trig_apres_acceptation_offre
    AFTER UPDATE OF etat
    ON projet.offres_de_stage
    FOR EACH ROW
    WHEN (NEW.etat = 'attribuée')
    EXECUTE FUNCTION projet.apres_acceptation_offre();

--Trigger avant acceptation
CREATE TRIGGER trig_avant_acceptation_offre
    BEFORE UPDATE OF etat
    ON projet.offres_de_stage
    FOR EACH ROW
    WHEN (NEW.etat = 'attribuée')
    EXECUTE FUNCTION projet.avant_acceptation_offre();

select projet.selectionner_etudiant(5, 'm.d@student.vinci.be');

--procedure point 7 entreprise--
CREATE OR REPLACE FUNCTION projet.annulerOffreDeStage(code_offre_param VARCHAR(10), nom_entreprise_param varchar(100)) RETURNS VOID AS
$$
BEGIN
    DECLARE
code_offre_stage varchar(10);
        id_offre_stage   integer;
BEGIN
        -- Vérifier si l'offre appartient à l'entreprise et n'est ni attribuée ni annulée
SELECT ods.code_stage
FROM projet.offres_de_stage ods
         JOIN projet.entreprises e ON ods.entreprise = e.id_entreprise
WHERE ods.code_stage = code_offre_param
  and nom_entreprise_param = e.nom_entreprise
    INTO code_offre_stage;

select ods2.id_offre_stage
from projet.offres_de_stage ods2
where code_stage = code_offre_stage
    into id_offre_stage;

IF code_offre_stage IS NULL THEN
            RAISE EXCEPTION 'L''offre avec le code % n''appartient pas à votre entreprise ou le nom de l''entreprise est incorrect', code_offre_param;
END IF;

        -- Mettre à jour l'état de l'offre à annulée
UPDATE projet.offres_de_stage
SET etat = 'annulée'
WHERE code_stage = code_offre_stage;

-- Mettre à jour l'état des candidatures en attente à refusée
UPDATE projet.candidatures
SET etat = 'refusée'
WHERE code_offre = id_offre_stage;

END;
END;
$$ LANGUAGE plpgsql;

SELECT projet.annulerOffreDeStage('CODE1', 'Entreprise1');

--requete point 1 Etudiant--

CREATE VIEW projet.visualiserOffresValideesParSemestre AS
SELECT ods.code_stage,
       e.nom_entreprise,
       e.adresse_entreprise,
       ods.description,
       string_agg(mc.mot, ', ') AS mots_cles,
       etu.id_etudiant
FROM projet.offres_de_stage ods
         left JOIN projet.entreprises e ON ods.entreprise = e.id_entreprise
         left JOIN projet.mots_des_offres mdo ON ods.id_offre_stage = mdo.offre
         left JOIN projet.mots_cles mc ON mdo.mot_cle = mc.id_mot_cle
         left JOIN projet.etudiants etu ON ods.semestre_stage = etu.semestre_stage
WHERE ods.etat = 'validée'
  AND ods.semestre_stage = etu.semestre_stage
GROUP BY ods.code_stage, e.nom_entreprise, e.adresse_entreprise, ods.description, etu.id_etudiant;

SELECT *
FROM projet.visualiserOffresValideesParSemestre
where id_etudiant = 2; --a remplacer par ? a la partie java pour la requete, ici c'est hardcodé pour test

--requete point 2 Etudiant--
create view projet.rechercheOffreParMotCle as
SELECT ods.code_stage,
       e.nom_entreprise,
       e.adresse_entreprise,
       ods.description,
       mc.mot,
       etu.id_etudiant
FROM projet.offres_de_stage ods
         JOIN projet.entreprises e ON ods.entreprise = e.id_entreprise
         JOIN projet.mots_des_offres mdo ON ods.id_offre_stage = mdo.offre
         JOIN projet.mots_cles mc ON mdo.mot_cle = mc.id_mot_cle
         JOIN projet.etudiants etu ON ods.semestre_stage = etu.semestre_stage
WHERE ods.etat = 'validée'
  AND ods.semestre_stage = etu.semestre_stage
GROUP BY ods.code_stage, e.nom_entreprise, e.adresse_entreprise, ods.description, mc.mot, etu.id_etudiant;

select *
from projet.rechercheOffreParMotCle
where id_etudiant = 2
  and mot = 'Mot2'; --idem que point 1 pour l'id et le mot

-- Application étudiant : point 3 --
CREATE OR REPLACE FUNCTION projet.poserCandidature(mail_etudiant VARCHAR(100), code VARCHAR(10),
                                                   motivations VARCHAR(100), semestre CHAR(2)) RETURNS INTEGER AS
$$
DECLARE
id_etudiant_code_offre INTEGER := 0;
    _id_etudiant           INTEGER := 0;
    id_offre               INTEGER := 0;
BEGIN
SELECT id_etudiant FROM projet.etudiants WHERE mail = mail_etudiant INTO _id_etudiant;
SELECT id_offre_stage FROM projet.offres_de_stage WHERE code_stage = code INTO id_offre;

IF EXISTS(SELECT * FROM projet.candidatures can WHERE can.etudiant = _id_etudiant AND can.etat = 'acceptée') THEN
        RAISE 'une candidature à déjà été acceptée';
END IF;

    IF EXISTS(SELECT *
              FROM projet.candidatures can
              WHERE can.etudiant = _id_etudiant AND can.code_offre = id_offre) THEN
        RAISE 'candidature déjà posée pour cette offre';
END IF;

    IF NOT EXISTS(SELECT * FROM projet.offres_de_stage os WHERE os.code_stage = code AND os.etat = 'validée') THEN
        RAISE 'offre pas validée';
END IF;

    IF EXISTS(SELECT * FROM projet.offres_de_stage os WHERE code_stage = code AND semestre_stage != semestre) THEN
        RAISE 'offre pas disponible pour ce semestre';
END IF;

INSERT INTO projet.candidatures
VALUES (DEFAULT, id_offre, _id_etudiant, motivations)
    RETURNING etudiant, code_offre INTO id_etudiant_code_offre;
RETURN id_etudiant_code_offre;
END;
$$ LANGUAGE plpgsql;

--- select point 4 etudiant -----------
CREATE OR REPLACE VIEW projet.getCandidaturesEtudiant AS
SELECT of.code_stage,
       ent.nom_entreprise,
       ca.etat,
       ca.etudiant
FROM projet.candidatures ca
         INNER JOIN
     projet.offres_de_stage of ON ca.code_offre = of.id_offre_stage
    INNER JOIN
    projet.entreprises ent ON of.entreprise = ent.id_entreprise;

select *
from projet.getCandidaturesEtudiant
WHERE etudiant = 1; ------ à remplacer en java

--requete point 5 etudiant--
CREATE OR REPLACE FUNCTION annulerCandidature(code_offre_param INT, id_etudiant_param INT) RETURNS VOID AS
$$
BEGIN
    DECLARE
etat_candidature  VARCHAR(25);
        id_offre_stage    INT;
        candidature_count INT;
BEGIN
        -- Vérifier si la candidature existe et est en attente
SELECT c.etat, c.code_offre, e.nbr_candidature_en_attente
INTO etat_candidature, id_offre_stage, candidature_count
FROM projet.candidatures c
         JOIN projet.etudiants e ON c.etudiant = e.id_etudiant
WHERE c.etudiant = id_etudiant_param
  AND c.code_offre = code_offre_param;

IF etat_candidature IS NULL THEN
            RAISE EXCEPTION 'La candidature n''existe pas.';
        ELSIF etat_candidature <> 'en attente' THEN
            RAISE EXCEPTION 'La candidature ne peut être annulée que si elle est en attente.';
END IF;

        -- Annuler la candidature
DELETE FROM projet.candidatures WHERE etudiant = id_etudiant_param AND code_offre = code_offre_param;

-- Mettre à jour le nombre de candidatures en attente de l'étudiant
UPDATE projet.etudiants
SET nbr_candidature_en_attente = candidature_count - 1
WHERE id_etudiant = id_etudiant_param;
END;
END;
$$ LANGUAGE plpgsql;

SELECT annulerCandidature(1, 4);









