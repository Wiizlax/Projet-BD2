-----------------------Entreprise-------------------------------------
--requête point 2 entreprise--
create view projet.mots_cles_disponibles as
select mc.id_mot_cle , mc.mot
from projet.mots_cles mc;

select * from projet.mots_cles_disponibles;

-- Application Entreprise : point 3
CREATE OR REPLACE FUNCTION projet.ajoutMotCleAUneOffre(id_entreprise CHAR(3), code VARCHAR(10), _mot_cle VARCHAR(100)) RETURNS INTEGER AS $$
DECLARE
    id_mot_cle_offre INTEGER := 0;
    id_mot INTEGER := 0;
    id_offre INTEGER := 0;
    code_offre INTEGER := 0;
BEGIN
    IF NOT EXISTS(SELECT * FROM projet.offres_de_stage WHERE entreprise = id_entreprise AND code = code_stage) THEN
        RAISE 'pas une offre de l entreprise';
    END IF;

    IF EXISTS(SELECT * FROM projet.offres_de_stage WHERE entreprise = id_entreprise AND code_stage = code AND (etat = 'attribuée' OR etat = 'annulée')) THEN
        RAISE 'ajout mot clé impossible';
    END IF;

    IF NOT EXISTS(SELECT * FROM projet.mots_cles WHERE mot = _mot_cle) THEN
        RAISE 'mot existe pas';
    END IF;

    IF EXISTS(SELECT mo.offre FROM projet.offres_de_stage os, projet.mots_des_offres mo WHERE os.code_stage = code AND os.id_offre_stage
        = mo.offre GROUP BY mo.offre HAVING COUNT(mo.*) = 3) THEN
        RAISE 'trop de mots pour cette offre';
    END IF;

    SELECT id_mot_cle FROM projet.mots_cles WHERE _mot_cle = mot INTO id_mot;

    SELECT id_offre_stage FROM projet.offres_de_stage WHERE code_stage = code INTO code_offre;

    INSERT INTO projet.mots_des_offres VALUES
        (id_mot,code_offre) RETURNING mot_cle, offre INTO id_mot_cle_offre;
    RETURN id_mot_cle_offre;
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM projet.ajoutMotCleAUneOffre('VIN','VIN4','java');


--requête point 4 entreprise--CREATE OR REPLACE VIEW vue_offres_de_stage AS
CREATE OR REPLACE FUNCTION projet.afficher_offres_par_entreprise(entreprise_param CHAR(3))
    RETURNS TABLE (
                      code_stage varchar(10),
                      description varchar(255),
                      semestre_stage char(2),
                      etat varchar(25),
                      nbr_candidatures_en_attente bigint,
                      nom_etudiant varchar(100)
                  ) AS $$
DECLARE
    entrepriseRecord RECORD;
BEGIN
    SELECT * FROM projet.entreprises WHERE id_entreprise = entreprise_param INTO entrepriseRecord;

    RETURN QUERY
        SELECT os.code_stage, os.description , os.semestre_stage , os.etat ,COALESCE(COUNT(ca.code_offre),0) AS "Nbr_candidature", COALESCE(et.nom_etudiant,'non atribuée')
        FROM  projet.offres_de_stage os
                  LEFT OUTER JOIN projet.etudiants et ON et.id_etudiant = os.etudiant
                  LEFT OUTER JOIN projet.candidatures ca ON ca.code_offre = os.id_offre_stage
            AND os.id_offre_stage = ca.code_offre
        WHERE os.entreprise = entrepriseRecord.id_entreprise
        group by os.code_stage, os.description, os.semestre_stage, os.etat, COALESCE(et.nom_etudiant,'non atribuée');
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM projet.afficher_offres_par_entreprise('VIN');

--procédure point 5 entreprise--
CREATE OR REPLACE FUNCTION projet.getCandidaturesPourOffre(code_entreprise_param CHAR(3) ,code_offre_param VARCHAR(10)) RETURNS TABLE (
                                                                                                                                          etat VARCHAR(25),
                                                                                                                                          nom_etudiant VARCHAR(100),
                                                                                                                                          prenom_etudiant VARCHAR(100),
                                                                                                                                          mail_etudiant VARCHAR(100),
                                                                                                                                          motivation_etudiant VARCHAR(255)
                                                                                                                                      ) AS $$
BEGIN
    IF NOT EXISTS(SELECT * FROM projet.offres_de_stage WHERE entreprise = code_entreprise_param AND code_stage = code_offre_param) THEN
        RAISE 'pas une offre de l entreprise';
    END IF;
    RETURN QUERY
        SELECT
            c.etat,
            e.nom_etudiant,
            e.prenom_etudiant,
            e.mail,
            c.motivation_etudiant
        FROM
            projet.candidatures c
                LEFT JOIN
            projet.etudiants e ON c.etudiant = e.id_etudiant
        WHERE
                c.code_offre = (SELECT ods.id_offre_stage FROM projet.offres_de_stage ods WHERE ods.code_stage = code_offre_param);

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Il n''y a pas de candidatures pour cette offre ou vous n''avez pas d''offre ayant ce code';
    END IF;
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM projet.getCandidaturesPourOffre('VIN','VIN5');

-------point 6 Entreprise----------------

--- Function qui accepte un etudiant pour une offre de stage
CREATE OR REPLACE FUNCTION projet.selectionner_etudiant(code_entreprise_param CHAR(3) ,code_offre_param CHAR(10), mail_etudiant VARCHAR(255))
    RETURNS VOID AS $$
DECLARE
    offre RECORD;
    etudiant_accepte RECORD;
    --nbr_candidature_en_attente INTEGER;
BEGIN
    -- Recherche de l'offre et de l'étudiant
    SELECT * FROM projet.offres_de_stage WHERE code_stage = code_offre_param INTO offre;
    SELECT * FROM projet.etudiants WHERE mail = mail_etudiant INTO etudiant_accepte;

    -- Vérification de l'existence de l'offre et de l'étudiant
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Offre ou étudiant inexistant(e)';
    END IF;
    IF NOT EXISTS(SELECT * FROM projet.offres_de_stage WHERE code_stage = code_offre_param AND entreprise = code_entreprise_param) THEN
        RAISE 'pas une offre de l entreprise';
    END IF;


    -- Mise à jour de l'état de l'offre
    UPDATE projet.offres_de_stage SET etudiant = etudiant_accepte.id_etudiant WHERE code_stage = code_offre_param;
    UPDATE projet.offres_de_stage SET etat = 'attribuée' WHERE code_stage = code_offre_param;
END;
$$ LANGUAGE plpgsql;


----- Function qui fait les updates avant l'acceptation
CREATE OR REPLACE FUNCTION projet.avant_acceptation_offre()
    RETURNS TRIGGER AS $$
DECLARE
    offre RECORD;
    etudiant_accepte RECORD;
BEGIN

    -- Recherche de l'offre et de l'étudiant
    SELECT * FROM projet.offres_de_stage WHERE id_offre_stage = OLD.id_offre_stage INTO offre;
    SELECT * FROM projet.etudiants WHERE id_etudiant = OLD.etudiant INTO etudiant_accepte;

    -- Vérification de l'état de l'offre et de la candidature OR etudiant_accepte.nbr_candidature_en_attente = 0
    IF offre.etat != 'validée'  THEN
        RAISE EXCEPTION 'L''offre n''est pas dans l''état "validée"';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

----- Function qui fait les updates apres l'acceptation
CREATE OR REPLACE FUNCTION projet.apres_acceptation_offre()
    RETURNS TRIGGER AS $$
DECLARE
    offre RECORD;
    etudiant_accepte RECORD;
BEGIN

    -- Recherche de l'offre et de l'étudiant
    SELECT * FROM projet.offres_de_stage WHERE id_offre_stage = NEW.id_offre_stage INTO offre;
    SELECT * FROM projet.etudiants WHERE id_etudiant = NEW.etudiant INTO etudiant_accepte;


    -- Mise à jour de l'état de la candidature
    UPDATE projet.candidatures SET etat = 'acceptée' WHERE code_offre = offre.id_offre_stage AND etudiant = etudiant_accepte.id_etudiant;

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
CREATE OR REPLACE TRIGGER trig_apres_acceptation_offre
    AFTER UPDATE OF etat ON projet.offres_de_stage
    FOR EACH ROW
    WHEN (NEW.etat = 'attribuée')
EXECUTE FUNCTION projet.apres_acceptation_offre();

--Trigger avant acceptation
CREATE OR REPLACE TRIGGER trig_avant_acceptation_offre
    BEFORE UPDATE OF etat ON projet.offres_de_stage
    FOR EACH ROW
    WHEN (NEW.etat = 'attribuée')
EXECUTE FUNCTION projet.avant_acceptation_offre();

--select projet.selectionner_etudiant('VIN', 'VIN5' , 'm.d@student.vinci.be');

-------point 7 Entreprise----------------
--procedure point 7 entreprise--
CREATE OR REPLACE FUNCTION projet.annulerOffreDeStage(code_offre_param VARCHAR(10), code_entreprise CHAR(3)) RETURNS VOID AS $$
BEGIN
    DECLARE
        code_offre_stage varchar(10);
        id_offre_stage integer;
    BEGIN
        -- Vérifier si l'offre appartient à l'entreprise et n'est ni attribuée ni annulée
        SELECT ods.code_stage
        FROM projet.offres_de_stage ods
                 JOIN projet.entreprises e ON ods.entreprise = e.id_entreprise
        WHERE ods.code_stage = code_offre_param
          and e.id_entreprise = code_entreprise
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

---Pour create table);


CREATE OR REPLACE FUNCTION projet.genererCodeStage()
    RETURNS TRIGGER AS $$
DECLARE
    nbr_offres_entreprise INT;
    entrepriseRecord RECORD;
    code_stage_param VARCHAR(10);
BEGIN
    SELECT * FROM projet.entreprises WHERE entreprises.id_entreprise = NEW.entreprise INTO entrepriseRecord;
    SELECT count(ods.id_offre_stage)
    FROM projet.offres_de_stage ods
    WHERE entreprise = entrepriseRecord.id_entreprise INTO nbr_offres_entreprise;

    code_stage_param = concat(entrepriseRecord.id_entreprise,nbr_offres_entreprise);
    UPDATE projet.offres_de_stage
    SET code_stage = code_stage_param
    WHERE id_offre_stage = NEW.id_offre_stage;

    RETURN new.code_stage;
END;
$$ LANGUAGE plpgsql;

--Trigger pour lancer la function qui va generer le code de l'offre de stage
CREATE OR REPLACE TRIGGER generateCodeOffre AFTER INSERT ON projet.offres_de_stage FOR EACH ROW
EXECUTE PROCEDURE projet.genererCodeStage();

--INSERT INTO projet.offres_de_stage (entreprise, code_stage, etat, semestre_stage, description, etudiant) VALUES
-- ('VIN', DEFAULT, DEFAULT, 'Q2', 'stage SAP', NULL) RETURNING id_offre_stage , etat , code_stage;


---- Get Code offre generé par le trigger -----
create or replace view projet.getcode_offre as
select ods.code_stage, ods.id_offre_stage
from projet.offres_de_stage ods;

---SELECT * FROM projet.getcode_offre WHERE id_offre_stage = 5;

--DROP FUNCTION projet.encodeoffrestage(entreprise_param char(3) , semestre_param CHAR (2) , description_param varchar(100));
CREATE OR REPLACE FUNCTION projet.encoderOffreStage(entreprise_param CHAR(3) , semestre_param CHAR(2), description_param varchar(100))
    RETURNS VARCHAR(10)  AS $$
DECLARE
    code_param varchar(10);
    id INT;
BEGIN
    INSERT INTO projet.offres_de_stage (entreprise, code_stage, etat, semestre_stage, description, etudiant) VALUES
        (entreprise_param, NULL, DEFAULT, semestre_param, description_param, NULL) RETURNING id_offre_stage INTO id;

    SELECT code_stage FROM projet.getcode_offre WHERE id_offre_stage = id INTO code_param;
    RETURN code_param;
END
$$ LANGUAGE plpgsql;

--SELECT * FROM projet.encodeOffreStage('VIN','Q2','Testestetstqst');