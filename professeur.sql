-----------------------Professeur-------------------------------------

-- Application Professeur : point 1
CREATE OR REPLACE FUNCTION projet.encoder_etudiant(p_nom_etudiant VARCHAR(100), p_prenom_etudiant VARCHAR(100), p_mail VARCHAR(100),
                                                   p_semestre_stage CHAR(3), p_mdp VARCHAR(100)) RETURNS INT AS $$
DECLARE
    v_id_etudiant INT;
BEGIN
    INSERT INTO projet.etudiants (nom_etudiant, prenom_etudiant, mail, semestre_stage, mot_de_passe, nbr_candidature_en_attente)
    VALUES (p_nom_etudiant, p_prenom_etudiant, p_mail, p_semestre_stage, p_mdp, DEFAULT) RETURNING id_etudiant INTO v_id_etudiant;

    RETURN v_id_etudiant;
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM projet.encoder_etudiant('Moulin','Arnaud','a.m@student.vinci.be','Q1','Marnaud12');

-- Application Professeur : point 2
CREATE OR REPLACE FUNCTION projet.encoder_entreprise(p_nom_entreprise VARCHAR(100), p_adresse VARCHAR(100), p_mail_entreprise VARCHAR(100),
                                                     p_id_entreprise CHAR(3), p_mdp_entreprise VARCHAR(100)) RETURNS CHAR AS $$
DECLARE
    v_id_entreprise CHAR(3);
BEGIN
    INSERT INTO projet.entreprises (id_entreprise, nom_entreprise, adresse_entreprise, adresse_mail, mot_de_passe)
    VALUES (p_id_entreprise, p_nom_entreprise, p_adresse, p_mail_entreprise, p_mdp_entreprise) RETURNING id_entreprise INTO v_id_entreprise;

    RETURN v_id_entreprise;
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM projet.encoder_entreprise('UMons','Adresse_UMons','um@gmail.be','UMO','umons2');

-- Application Professeur : point 3
CREATE OR REPLACE FUNCTION projet.encoder_mot_cle(p_nom_mot VARCHAR(100)) RETURNS INT AS $$
DECLARE
    v_id_mot INT;
BEGIN
    INSERT INTO projet.mots_cles (mot)
    VALUES (p_nom_mot) RETURNING id_mot_cle INTO v_id_mot;

    RETURN v_id_mot;
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM projet.encoder_mot_cle('SQL');

--requête point 4 professeur--
create view projet.offres_non_validees as
select ods.code_stage, ods.semestre_stage, e.nom_entreprise, ods.description
from projet.offres_de_stage ods,
     projet.entreprises e
where e.id_entreprise = ods.entreprise
  and ods.etat = 'non validée';

--select * from projet.offres_non_validees;

-- Application Professeur : point 5
CREATE OR REPLACE FUNCTION valider_offre_de_stage(code_offre_stage varchar(10)) RETURNS VOID AS $$
BEGIN
    UPDATE projet.offres_de_stage
    SET etat = 'validée'
    WHERE code_stage = code_offre_stage AND etat = 'non validée';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'L''offre de stage avec le code % ne peut pas être validée ou n''existe pas.', code_offre_stage;
    END IF;

    IF FOUND THEN
        RAISE NOTICE 'L''offre de stage avec le code % a été validée avec succès.', code_offre_stage;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION avant_valider_offre_de_stage()
    RETURNS TRIGGER AS $$
DECLARE
    offre RECORD;
BEGIN
    SELECT * FROM projet.offres_de_stage WHERE id_offre_stage = OLD.id_offre_stage INTO offre;
    -- Vérification de l'état de l'offre avant la validation
    IF offre.etat != 'non validée'  THEN
        RAISE EXCEPTION 'L''offre n''est pas dans l''état "non validée"';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger avant acceptation
CREATE OR REPLACE TRIGGER trig_avant_validation_offre
    BEFORE UPDATE OF etat ON projet.offres_de_stage
    FOR EACH ROW
    WHEN (NEW.etat = 'validée')
EXECUTE FUNCTION avant_valider_offre_de_stage();


--SELECT * FROM valider_offre_de_stage('VIN3');

--requête point 6 professeur--
create view projet.offres_validees as
select ods.code_stage, ods.semestre_stage, e.nom_entreprise, ods.description
from projet.offres_de_stage ods,
     projet.entreprises e
where e.id_entreprise = ods.entreprise
  and ods.etat = 'validée';

--select * from projet.offres_validees;

--requête point 7 professeur--
CREATE OR REPLACE VIEW projet.etudiants_sans_stages AS
SELECT DISTINCT e.nom_etudiant, e.prenom_etudiant, e.mail, e.semestre_stage, e.nbr_candidature_en_attente
FROM projet.etudiants e
         LEFT JOIN projet.candidatures c ON c.etudiant = e.id_etudiant
WHERE c.etat != 'acceptée' OR c.etat IS NULL;


SELECT * FROM projet.etudiants_sans_stages;

--requête point 8 professeur--
create view projet.offres_attribuees as
select ods.code_stage, en.nom_entreprise, e.nom_etudiant, e.prenom_etudiant
from projet.offres_de_stage ods,
     projet.etudiants e,
     projet.entreprises en
where ods.etudiant = e.id_etudiant
  and en.id_entreprise = ods.entreprise
  and ods.etat = 'attribuée';