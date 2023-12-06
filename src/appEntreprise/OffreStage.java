package appEntreprise;

import appEntreprise.Entreprise;

public class OffreStage {

    private int idOffreStage;
    private String  code_stage , etat , semestre_stage , description ;
    private Etudiant etudiant;
    private Entreprise entreprise;

    public OffreStage(String code_stage , String etat , String semestre_stage , String description , Entreprise entreprise){
        this.code_stage = code_stage;
        this.etat = etat;
        this.semestre_stage = semestre_stage;
        this.description = description;
        this.entreprise = entreprise;
    }

    public OffreStage() {
    }

    public int getIdOffreStage() {
        return idOffreStage;
    }

    public void setIdOffreStage(int idOffreStage) {
        this.idOffreStage = idOffreStage;
    }

    public String getCode_stage() {
        return code_stage;
    }

    public void setCode_stage(String code_stage) {
        this.code_stage = code_stage;
    }

    public String getEtat() {
        return etat;
    }

    public void setEtat(String etat) {
        this.etat = etat;
    }

    public String getSemestre_stage() {
        return semestre_stage;
    }

    public void setSemestre_stage(String semestre_stage) {
        this.semestre_stage = semestre_stage;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Etudiant getEtudiant() {
        return etudiant;
    }

    public void setEtudiant(Etudiant etudiant) {
        this.etudiant = etudiant;
    }

    public Entreprise getEntreprise() {
        return entreprise;
    }

    public void setEntreprise(Entreprise entreprise) {
        this.entreprise = entreprise;
    }

    @Override
    public String toString() {
        return "Id  : " + idOffreStage + '\n' +
                "Code stage : " + code_stage + '\n' +
                "Etat : " + etat + '\n' +
                "Semestre Stage : " + semestre_stage + '\n' +
                "Description  : " + description + '\n' +
                "appEtudiant.Etudiant : " + etudiant + '\n' +
                "appEntreprise.Entreprise : " + entreprise + '\n';
    }
}
