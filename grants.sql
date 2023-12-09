GRANT CONNECT ON DATABASE dbtomsimonis TO eduardosampaio;
GRANT USAGE ON SCHEMA projet TO eduardosampaio;
GRANT SELECT , INSERT , UPDATE ON ALL TABLES IN SCHEMA projet TO eduardosampaio;

GRANT SELECT , UPDATE ON SEQUENCE projet.etudiants_id_etudiant_seq,
    projet.mots_cles_id_mot_cle_seq ,
    projet.offres_de_stage_id_offre_stage_seq
    to eduardosampaio;

GRANT CONNECT ON DATABASE dbtomsimonis TO sebastiendewilde;
GRANT USAGE ON SCHEMA projet TO sebastiendewilde;
GRANT SELECT , INSERT , UPDATE ON ALL TABLES IN SCHEMA projet TO sebastiendewilde;

GRANT SELECT , UPDATE ON SEQUENCE projet.etudiants_id_etudiant_seq,
    projet.mots_cles_id_mot_cle_seq ,
    projet.offres_de_stage_id_offre_stage_seq
    to sebastiendewilde;
