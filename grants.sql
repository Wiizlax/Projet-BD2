
--- Entreprise : eduardosampaio
GRANT CONNECT ON DATABASE dbtomsimonis TO eduardosampaio;
GRANT USAGE ON SCHEMA projet TO eduardosampaio;
---GRANT SELECT , INSERT , UPDATE ON ALL TABLES IN SCHEMA projet TO eduardosampaio;
GRANT SELECT  ON ALL TABLES IN SCHEMA projet TO eduardosampaio;

GRANT INSERT ON TABLE projet.offres_de_stage TO eduardosampaio;
GRANT INSERT ON TABLE projet.mots_des_offres TO eduardosampaio;
GRANT SELECT ON projet.mots_cles_disponibles TO eduardosampaio;
GRANT UPDATE ON projet.candidatures TO eduardosampaio;
GRANT UPDATE ON projet.etudiants TO eduardosampaio;
GRANT UPDATE ON projet.offres_de_stage TO eduardosampaio;

GRANT SELECT , UPDATE ON SEQUENCE projet.etudiants_id_etudiant_seq,
    projet.mots_cles_id_mot_cle_seq ,
    projet.offres_de_stage_id_offre_stage_seq
    to eduardosampaio;

---- Etudiant : sebastiendewilde
GRANT CONNECT ON DATABASE dbtomsimonis TO sebastiendewilde;
GRANT USAGE ON SCHEMA projet TO sebastiendewilde;
--GRANT SELECT , INSERT , UPDATE ON ALL TABLES IN SCHEMA projet TO sebastiendewilde;
GRANT SELECT ON ALL TABLES IN SCHEMA projet TO sebastiendewilde;

GRANT SELECT ON projet.visualiserOffresValideesParSemestre TO sebastiendewilde;
GRANT SELECT ON projet.rechercheOffreParMotCle TO sebastiendewilde;
GRANT INSERT ON projet.candidatures TO sebastiendewilde;
GRANT UPDATE ON projet.candidatures TO sebastiendewilde;
GRANT SELECT ON projet.getCandidaturesEtudiant TO sebastiendewilde;

GRANT SELECT , UPDATE ON SEQUENCE projet.etudiants_id_etudiant_seq,
    projet.mots_cles_id_mot_cle_seq ,
    projet.offres_de_stage_id_offre_stage_seq
    to sebastiendewilde;
