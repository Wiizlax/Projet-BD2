public class Entreprise {

    private String id_entreprise;
    private String nom_entreprise,adresse_entreprise,adresse_mail,mot_de_passe;

    public Entreprise(String id_entreprise ,String nom_entreprise,String adresse_entreprise , String adresse_mail , String mot_de_passe){
        this.id_entreprise=id_entreprise;
        this.nom_entreprise = nom_entreprise;
        this.adresse_entreprise = adresse_entreprise;
        this.adresse_mail = adresse_mail;
        this.mot_de_passe=mot_de_passe;
    }

    public Entreprise() {
    }

    public String getId_entreprise() {
        return id_entreprise;
    }

    public void setId_entreprise(String id_entreprise) {
        this.id_entreprise = id_entreprise;
    }

    public String getNom_entreprise() {
        return nom_entreprise;
    }

    public void setNom_entreprise(String nom_entreprise) {
        this.nom_entreprise = nom_entreprise;
    }

    public String getAdresse_entreprise() {
        return adresse_entreprise;
    }

    public void setAdresse_entreprise(String adresse_entreprise) {
        this.adresse_entreprise = adresse_entreprise;
    }

    public String getAdresse_mail() {
        return adresse_mail;
    }

    public void setAdresse_mail(String adresse_mail) {
        this.adresse_mail = adresse_mail;
    }

    public String getMot_de_passe() {
        return mot_de_passe;
    }

    public void setMot_de_passe(String mot_de_passe) {
        this.mot_de_passe = mot_de_passe;
    }


    @Override
    public String toString() {
        return "\nNom_entreprise : " + nom_entreprise + "\n" +
                "Id_entreprise : " + id_entreprise + "\n" +
                "Adresse_entreprise : " + adresse_entreprise + "\n" +
                "Adresse_mail : " + adresse_mail + "\n";
    }
}
