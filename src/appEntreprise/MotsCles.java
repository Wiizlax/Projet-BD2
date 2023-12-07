package appEntreprise;

public class MotsCles {

    private int idMotCle;
    private String mot;

    public MotsCles(int idMotCle, String mot) {
        this.idMotCle = idMotCle;
        this.mot = mot;
    }

    public MotsCles() {
    }

    public int getIdMotCle() {
        return idMotCle;
    }

    public void setIdMotCle(int idMotCle) {
        this.idMotCle = idMotCle;
    }

    public String getMot() {
        return mot;
    }

    public void setMot(String mot) {
        this.mot = mot;
    }

    @Override
    public String toString() {
        return "\nID mot clé : " + idMotCle + "\n" +
                "Nom mot clé : " + mot;
    }
}
