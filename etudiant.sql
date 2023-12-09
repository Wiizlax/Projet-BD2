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


--------------------point 5 etudiant--------------------------
CREATE OR REPLACE FUNCTION projet.annulerCandidature(code_offre_param VARCHAR(10), id_etudiant_param INT) RETURNS VOID AS
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
                 JOIN projet.offres_de_stage o ON c.code_offre = o.id_offre_stage
        WHERE c.etudiant = id_etudiant_param
          AND o.code_stage = code_offre_param;

        IF etat_candidature IS NULL THEN
            RAISE EXCEPTION 'La candidature n''existe pas.';
        ELSIF etat_candidature <> 'en attente' THEN
            RAISE EXCEPTION 'La candidature ne peut être annulée que si elle est en attente.';
        END IF;

        -- Mettre à jour l'état de la candidature à annulé au lieu de la supprimer
        UPDATE projet.candidatures
        SET etat = 'annulée'
        WHERE etudiant = id_etudiant_param AND code_offre = id_offre_stage;

        -- Mettre à jour le nombre de candidatures en attente de l'étudiant
        UPDATE projet.etudiants
        SET nbr_candidature_en_attente = candidature_count - 1
        WHERE id_etudiant = id_etudiant_param;
    END;
END;
$$ LANGUAGE plpgsql;

------------Trigger nbr de candidatures etudiant----------
CREATE OR REPLACE FUNCTION projet.nbrCadidatureUpdate()
    RETURNS TRIGGER AS $$
DECLARE
    nbr_candidature INT;
    etudiant_param RECORD;
BEGIN
    SELECT * FROM projet.etudiants WHERE etudiant = NEW.etudiant INTO etudiant_param;
    nbr_candidature = etudiant_param.nbr_candidature_en_attente + 1;


    UPDATE projet.etudiants
    SET nbr_candidature_en_attente = nbr_candidature
    WHERE etudiant = NEW.etudiant;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

--Trigger pour lancer la function qui va generer le code de l'offre de stage
CREATE OR REPLACE TRIGGER updateNbrCandidature AFTER INSERT ON projet.candidatures FOR EACH ROW
EXECUTE PROCEDURE projet.nbrCadidatureUpdate();

