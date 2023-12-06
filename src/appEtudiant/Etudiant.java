package appEtudiant;

public class Etudiant {

    private int idEtudiant, nbrCandidatureEnAttente;
    private String nomEtudiant, prenomEtudiant, mail, semestreStage, mdp;


    public Etudiant(int idEtudiant ,String nomEtudiant, String prenomEtudiant, String mail, String semestreStage, String mdp, int nbrCandidatureEnAttente) {
        this.idEtudiant = idEtudiant;
        this.nomEtudiant = nomEtudiant;
        this.prenomEtudiant = prenomEtudiant;
        this.mail = mail;
        this.semestreStage = semestreStage;
        this.mdp = mdp;
        this.nbrCandidatureEnAttente = nbrCandidatureEnAttente;
    }

    public Etudiant() {

    }

    public int getIdEtudiant() {
        return idEtudiant;
    }

    public String getNomEtudiant() {
        return nomEtudiant;
    }

    public String getPrenomEtudiant() {
        return prenomEtudiant;
    }

    public String getMail() {
        return mail;
    }

    public String getSemestreStage() {
        return semestreStage;
    }

    public String getMdp() {
        return mdp;
    }

    public int getNbrCandidatureEnAttente() {
        return nbrCandidatureEnAttente;
    }

    public void setIdEtudiant(int idEtudiant) {
        this.idEtudiant = idEtudiant;
    }

    public void setNomEtudiant(String nomEtudiant) {
        this.nomEtudiant = nomEtudiant;
    }

    public void setPrenomEtudiant(String prenomEtudiant) {
        this.prenomEtudiant = prenomEtudiant;
    }

    public void setMail(String mail) {
        this.mail = mail;
    }

    public void setSemestreStage(String semestreStage) {
        this.semestreStage = semestreStage;
    }

    public void setMdp(String mdp) {
        this.mdp = mdp;
    }

    public void setNbrCandidatureEnAttente(int nbrCandidatureEnAttente) {
        this.nbrCandidatureEnAttente = nbrCandidatureEnAttente;
    }

    @Override
    public String toString() {
        return "\nId_etudiant : " + idEtudiant + "\n" +
                "Nom etudiant : " + nomEtudiant + "\n" +
                "Prenom etudiant : " + prenomEtudiant + "\n" +
                "Mail : " + mail + "\n" +
                "Semestre stage : " + semestreStage + "\n" +
                "Nbr candidature en attente : " + nbrCandidatureEnAttente + "\n";
    }
}
