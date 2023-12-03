import java.sql.*;
import java.util.Scanner;

public class GestionStage {

    private static Scanner scanner;

    public static void main(String[] args)  {

        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }

        String url="jdbc:postgresql://localhost:5432/postgres";
        Connection conn=null;
        try {
            conn= DriverManager.getConnection(url,"postgres","mdp"); // password = votre password postgres
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }

        Etudiant etudiantConnecte = null;

        // Boucle pour demander le mail et le mot de passe jusqu'à ce que la connexion réussisse
        while (etudiantConnecte == null) {
            etudiantConnecte = authenticateStudent(conn);

            if (etudiantConnecte != null) {
                System.out.println("Connexion réussie pour l'étudiant : " + etudiantConnecte.getPrenomEtudiant() + ' ' +etudiantConnecte.getNomEtudiant());

                // Afficher le menu
                afficherMenu(etudiantConnecte, conn);
            } else {
                System.out.println("Mauvais mail ou mot de passe ! Veuillez réessayer.");
            }
        }

        // Reste du code...
    }

    private static void afficherMenu(Etudiant etudiant, Connection conn) {
        Scanner scanner = new Scanner(System.in);

        int choix;
        do {
            System.out.println("\nMenu étudiant :");
            System.out.println("1 -> Voir toutes les offres de stage validées pour mon semestre");
            System.out.println("0 -> Quitter");

            // Demander le choix à l'utilisateur
            System.out.print("Choix : ");
            choix = scanner.nextInt();

            // Effectuer l'action en fonction du choix
            switch (choix) {
                case 1:
                    afficherOffresValideesParSemestre(etudiant, conn);
                    break;
                case 2:
                    break;
                case 0:
                    System.out.println("Au revoir !");
                    break;
                default:
                    System.out.println("Choix invalide. Veuillez réessayer.");
            }
        } while (choix != 0);
    }

    private static Etudiant authenticateStudent(Connection conn) {
        Scanner scanner = new Scanner(System.in);

        System.out.print("Entrez votre email : ");
        String email = scanner.nextLine();

        System.out.print("Entrez votre mot de passe : ");
        String motDePasse = scanner.nextLine();

        // Requête pour vérifier l'authentification
        String query = "SELECT * FROM projet.etudiants WHERE mail = ? AND mot_de_passe = ?";
        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setString(1, email);
            preparedStatement.setString(2, motDePasse);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    // Création de l'objet Etudiant avec les informations de la base de données
                    Etudiant etudiant = new Etudiant();
                    etudiant.setIdEtudiant(resultSet.getInt("id_etudiant"));
                    etudiant.setNomEtudiant(resultSet.getString("nom_etudiant"));
                    etudiant.setPrenomEtudiant(resultSet.getString("prenom_etudiant"));
                    etudiant.setMail(email);
                    etudiant.setSemestreStage(resultSet.getString("semestre_stage"));
                    etudiant.setMdp(motDePasse);
                    etudiant.setNbrCandidatureEnAttente(resultSet.getInt("nbr_candidature_en_attente"));

                    return etudiant;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private static void afficherOffresValideesParSemestre(Etudiant etudiant, Connection conn) {
        // Requête SQL pour récupérer les offres validées par semestre pour un étudiant
        String query = "SELECT * FROM projet.visualiserOffresValideesParSemestre WHERE id_etudiant = ?";

        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setInt(1, etudiant.getIdEtudiant());

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next()) {
                    // Récupération des données de l'offre
                    String codeStage = resultSet.getString("code_stage");
                    String nomEntreprise = resultSet.getString("nom_entreprise");
                    String adresseEntreprise = resultSet.getString("adresse_entreprise");
                    String description = resultSet.getString("description");
                    String motsCles = resultSet.getString("mots_cles");

                    // Affichage des informations de l'offre
                    System.out.println("Code Stage: " + codeStage);
                    System.out.println("Nom Entreprise: " + nomEntreprise);
                    System.out.println("Adresse Entreprise: " + adresseEntreprise);
                    System.out.println("Description: " + description);
                    System.out.println("Mots-clés: " + motsCles);
                    System.out.println();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


}
