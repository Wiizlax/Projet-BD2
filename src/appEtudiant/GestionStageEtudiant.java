package appEtudiant;

import appEtudiant.Etudiant;

import java.sql.*;
import java.util.Scanner;

public class GestionStageEtudiant {

    private Connection conn;

    public static void main(String[] args)  {
        GestionStageEtudiant gestionStageEtudiant = new GestionStageEtudiant();
        gestionStageEtudiant.run();
    }

    private void afficherMenu(Etudiant etudiant, Connection conn) {
        Scanner scanner = new Scanner(System.in);

        int choix;
        do {
            System.out.println("\nMenu étudiant :");
            System.out.println("1 -> Voir toutes les offres de stage validées pour mon semestre");
            System.out.println("2 -> Recherche d’une offre de stage par mot clé (du même quadrimestre que l'étudiant)");
            System.out.println("3 -> Poser sa candidature");
            System.out.println("4 -> Voir les offres de stage pour lesquels l’étudiant a posé sa candidature");
            System.out.println("5 -> Annuler une candidature");
            System.out.println("0 -> Quitter");

            System.out.print("Choix : ");
            choix = scanner.nextInt();

            switch (choix) {
                case 1 -> afficherOffresValideesParSemestre(etudiant, conn);
                case 2 -> rechercherOffreParMotCle(etudiant, conn);
                case 3 -> poserCandidature(etudiant,conn);
                case 4 -> afficherCandidaturesEtudiant(etudiant, conn);
                case 5 -> annulerCandidature(etudiant, conn);
                case 0 -> System.out.println("Au revoir !");
                default -> System.out.println("Choix invalide. Veuillez réessayer.");
            }
        } while (choix != 0);
    }

    private void initializeDatabase(){
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }

        String url="jdbc:postgresql://localhost:5432/postgres";
        conn=null;
        try {
            conn= DriverManager.getConnection(url,"postgres","Tomtom2002=Wiizlax");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
    }

    public void run(){
        initializeDatabase();
        Etudiant etudiantConnecte = null;

        // Boucle pour demander le mail et le mdp jusqu'a ce que la connexion réussisse
        while (etudiantConnecte == null) {
            etudiantConnecte = authenticateStudent(conn);

            if (etudiantConnecte != null) {
                System.out.println("Connexion réussie pour l'étudiant : " + etudiantConnecte.getPrenomEtudiant() + ' ' + etudiantConnecte.getNomEtudiant());

                afficherMenu(etudiantConnecte, conn);
            } else {
                System.out.println("Mauvais mail ou mot de passe ! Veuillez réessayer.");
            }
        }
    }

    private Etudiant authenticateStudent(Connection conn) {
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
                    // Création de l'objet appEtudiant.Etudiant avec les informations de la base de données
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

    private void afficherOffresValideesParSemestre(Etudiant etudiant, Connection conn) {
        // Requête SQL pour récupérer les offres validées par semestre pour un étudiant
        String query = "SELECT * FROM projet.visualiseroffresvalideesparsemestre WHERE id_etudiant = ?";

        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setInt(1, etudiant.getIdEtudiant());
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next()) {
                    String codeStage = resultSet.getString("code_stage");
                    String nomEntreprise = resultSet.getString("nom_entreprise");
                    String adresseEntreprise = resultSet.getString("adresse_entreprise");
                    String description = resultSet.getString("description");
                    String motsCles = resultSet.getString("mots_cles");

                    System.out.println("Code Stage: " + codeStage);
                    System.out.println("Nom appEntreprise.Entreprise: " + nomEntreprise);
                    System.out.println("Adresse appEntreprise.Entreprise: " + adresseEntreprise);
                    System.out.println("Description: " + description);
                    System.out.println("Mots-clés: " + motsCles);
                    System.out.println();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void rechercherOffreParMotCle(Etudiant etudiant, Connection conn) {
        Scanner scanner = new Scanner(System.in);

        System.out.print("Entrez le mot-clé : ");
        String motCle = scanner.nextLine();

        String query = "SELECT * FROM projet.rechercheoffreparmotcle WHERE id_etudiant = ? AND mot = ?";

        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setInt(1, etudiant.getIdEtudiant());
            preparedStatement.setString(2, motCle);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next()) {
                    String codeStage = resultSet.getString("code_stage");
                    String nomEntreprise = resultSet.getString("nom_entreprise");
                    String adresseEntreprise = resultSet.getString("adresse_entreprise");
                    String description = resultSet.getString("description");
                    String motsCles = resultSet.getString("mot");

                    System.out.println("Code Stage: " + codeStage);
                    System.out.println("Nom appEntreprise.Entreprise: " + nomEntreprise);
                    System.out.println("Adresse appEntreprise.Entreprise: " + adresseEntreprise);
                    System.out.println("Description: " + description);
                    System.out.println("Mot-clé: " + motsCles);
                    System.out.println();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void poserCandidature(Etudiant etudiant, Connection conn) {
        Scanner scanner = new Scanner(System.in);

        System.out.print("Entrez le code de l'offre de stage : ");
        String codeOffre = scanner.nextLine();

        System.out.print("Entrez vos motivations : ");
        String motivations = scanner.nextLine();

        String query = "SELECT projet.poserCandidature(?, ?, ?, ?) AS result";
        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setString(1, etudiant.getMail());
            preparedStatement.setString(2, codeOffre);
            preparedStatement.setString(3, motivations);
            preparedStatement.setString(4, etudiant.getSemestreStage());

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    int result = resultSet.getInt("result");
                    if (result > 0) {
                        System.out.println("Candidature envoyée avec succès !");
                        etudiant.setNbrCandidatureEnAttente(etudiant.getNbrCandidatureEnAttente() + 1);
                    } else {
                        System.out.println("Échec de l'envoi de la candidature. Veuillez réessayer.");
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void afficherCandidaturesEtudiant(Etudiant etudiant, Connection conn) {
        String query = "SELECT * FROM projet.getcandidaturesetudiant WHERE etudiant = ?";

        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setInt(1, etudiant.getIdEtudiant());

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next()) {
                    String codeStage = resultSet.getString("code_stage");
                    String nomEntreprise = resultSet.getString("nom_entreprise");
                    String etatCandidature = resultSet.getString("etat");

                    System.out.println("Code Stage: " + codeStage);
                    System.out.println("Nom appEntreprise.Entreprise: " + nomEntreprise);
                    System.out.println("État de la Candidature: " + etatCandidature);
                    System.out.println();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void annulerCandidature(Etudiant etudiant, Connection conn) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("Entrez le code de l'offre de stage à annuler : ");
        String codeOffre = scanner.nextLine();

        String query = "SELECT projet.annulercandidature(?, ?)";
        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setString(1, codeOffre);
            preparedStatement.setInt(2, etudiant.getIdEtudiant());
            preparedStatement.execute();

            System.out.println("Candidature annulée avec succès !");
        } catch (SQLException e) {
            System.out.println("Erreur lors de l'annulation de la candidature : " + e.getMessage());
        }
    }

}
