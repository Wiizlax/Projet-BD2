package appProfesseur;

import appEntreprise.BCrypt;
import appEntreprise.Entreprise;
import appEntreprise.MotsCles;
import appEntreprise.OffreStage;
import appEtudiant.Etudiant;

import java.sql.*;
import java.util.Scanner;

public class GestionStageProfesseur {

    private static final Scanner scanner = new Scanner(System.in);

    public static void main(String[] args) {

        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }

        String url = "jdbc:postgresql://localhost:5432/postgres";
        Connection conn = null;
        OffreStage offreStage = new OffreStage();
        try {
            conn = DriverManager.getConnection(url, "postgres", "mdp"); //ton mdp postgres
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
        afficherMenu(conn, offreStage);
    }

    private static void afficherMenu(Connection conn, OffreStage offreStage) {

        int choix;
        do {
            System.out.println("\nMenu professeur :");
            System.out.println("0 -> Quitter");
            System.out.println("1 -> Encoder un étudiant");
            System.out.println("2 -> Encoder une entreprise");
            System.out.println("3 -> Encoder un mot clé");
            System.out.println("4 -> Voir les offres de stage non validées");
            System.out.println("5 -> Valider une offre de stage");
            System.out.println("6 -> Voir les offres de stage validées");
            System.out.println("7 -> Voir les étudiants sans stages");
            System.out.println("8 -> Voir les offres de stage attribuées");

            System.out.print("Choix : ");

            if (scanner.hasNextInt()) {
                choix = scanner.nextInt();

                switch (choix) {
                    case 0 -> System.out.println("Au revoir !");
                    case 1 -> encoderEtudiant(conn);
                    case 2 -> encoderEntreprise(conn);
                    case 3 -> encoderMotCle(conn);
                    case 4 -> voirOffresDeStageNonValidees(conn);
                    case 5 -> validerOffreDeStage(conn, offreStage);
                    case 6 -> voirOffresDeStageValidees(conn);
                    case 7 -> voirEtudiantsSansStages(conn);
                    case 8 -> voirOffresDeStageAttribuees(conn);
                    default -> System.out.println("Choix invalide. Veuillez réessayer.");
                }
            } else {
                System.out.println("Veuillez entrer un nombre entier.");
                scanner.nextLine(); // Consomme la ligne invalide
                choix = -1;
            }
        } while (choix != 0);
    }

    private static Etudiant encoderEtudiant(Connection conn) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("\nEntrez le nom de l'étudiant : ");
        String nomEtudiant = scanner.nextLine();
        System.out.print("\nEntrez le prénom de l'étudiant : ");
        String prenomEtudiant = scanner.nextLine();
        System.out.print("\nEntrez l'adresse mail de l'étudiant : ");
        String mailEtudiant = scanner.nextLine();
        System.out.print("\nEntrez le semestre du stage de l'étudiant : ");
        String semestreStageEtudiant = scanner.nextLine();
        System.out.print("\nEntrez le mot de passe de l'étudiant : ");
        String mdpEtudiant = scanner.nextLine();

        String hashedPassword = BCrypt.hashpw(mdpEtudiant, BCrypt.gensalt());

        Etudiant nouvelEtudiant = new Etudiant();
        nouvelEtudiant.setNomEtudiant(nomEtudiant);
        nouvelEtudiant.setPrenomEtudiant(prenomEtudiant);
        nouvelEtudiant.setMail(mailEtudiant);
        nouvelEtudiant.setSemestreStage(semestreStageEtudiant);
        nouvelEtudiant.setMdp(hashedPassword);

        String query = "SELECT * FROM projet.encoder_etudiant(?, ?, ?, ?, ?)";
        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setString(1, nouvelEtudiant.getNomEtudiant());
            preparedStatement.setString(2, nouvelEtudiant.getPrenomEtudiant());
            preparedStatement.setString(3, nouvelEtudiant.getMail());
            preparedStatement.setString(4, nouvelEtudiant.getSemestreStage());
            preparedStatement.setString(5, nouvelEtudiant.getMdp());


            // verifie si on a modifié + d'une colonne
            try (ResultSet generatedKeys = preparedStatement.executeQuery()) {
                if (generatedKeys.next()) {
                    int idEtudiant = generatedKeys.getInt(1); // Récupération de la valeur de la colonne auto-incrémentée
                    nouvelEtudiant.setIdEtudiant(idEtudiant);
                    System.out.println("\nEtudiant encodé avec succès !  ");
                    System.out.println("-------------------------------------");
                    System.out.println("Informations sur l'étudiant ajouté : " + "\n" + nouvelEtudiant);
                    return nouvelEtudiant;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("Erreur lors de l'encodage de l'étudiant.");
        return null;

    }

    private static Entreprise encoderEntreprise(Connection conn) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("\nEntrez le nom de l'entreprise : ");
        String nomEntreprise = scanner.nextLine();
        System.out.print("\nEntrez l'adresse de l'entreprise : ");
        String adresseEntreprise = scanner.nextLine();
        System.out.print("\nEntrez l'adresse mail de l'entreprise : ");
        String mailEntreprise = scanner.nextLine();
        System.out.print("\nEntrez l'identifiant de l'entreprise (3 lettres majuscules) : ");
        String idEntreprise = scanner.nextLine();
        System.out.print("\nEntrez le mot de passe de l'entreprise : ");
        String mdpEntreprise = scanner.nextLine();

        String hashedPassword = BCrypt.hashpw(mdpEntreprise, BCrypt.gensalt());

        Entreprise nouvelleEntreprise = new Entreprise();
        nouvelleEntreprise.setNom_entreprise(nomEntreprise);
        nouvelleEntreprise.setAdresse_entreprise(adresseEntreprise);
        nouvelleEntreprise.setAdresse_mail(mailEntreprise);
        nouvelleEntreprise.setId_entreprise(idEntreprise);
        nouvelleEntreprise.setMot_de_passe(hashedPassword);

        String query = "SELECT * FROM projet.encoder_entreprise(?, ?, ?, ?, ?)";
        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setString(1, nouvelleEntreprise.getNom_entreprise());
            preparedStatement.setString(2, nouvelleEntreprise.getAdresse_entreprise());
            preparedStatement.setString(3, nouvelleEntreprise.getAdresse_mail());
            preparedStatement.setString(4, nouvelleEntreprise.getId_entreprise());
            preparedStatement.setString(5, nouvelleEntreprise.getMot_de_passe());


            // verifie si on a modifié + d'une colonne
            try (ResultSet generatedKeys = preparedStatement.executeQuery()) {
                if (generatedKeys.next()) {
                    String id_entreprise = generatedKeys.getString(1); // Récupération de la valeur de la colonne auto-incrémentée
                    nouvelleEntreprise.setId_entreprise(id_entreprise);
                    System.out.println("\nEntreprise encodée avec succès !  ");
                    System.out.println("-------------------------------------");
                    System.out.println("Informations sur l'entreprise ajoutée : " + "\n" + nouvelleEntreprise);
                    return nouvelleEntreprise;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("Erreur lors de l'encodage de l'entreprise.");
        return null;

    }

    private static MotsCles encoderMotCle(Connection conn) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("\nEntrez le nom du mot clé : ");
        String nomMotCle = scanner.nextLine();

        MotsCles nouveauMotCle = new MotsCles();
        nouveauMotCle.setMot(nomMotCle);

        String query = "SELECT * FROM projet.encoder_mot_cle(?)";
        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setString(1, nouveauMotCle.getMot());

            // verifie si on a modifié + d'une colonne
            try (ResultSet generatedKeys = preparedStatement.executeQuery()) {
                if (generatedKeys.next()) {
                    int id_motCle = generatedKeys.getInt(1); // Récupération de la valeur de la colonne auto-incrémentée
                    nouveauMotCle.setIdMotCle(id_motCle);
                    System.out.println("\nMot clé encodé avec succès !  ");
                    System.out.println("-------------------------------------");
                    System.out.println("Informations sur le mot clé ajouté : " + "\n" + nouveauMotCle);
                    return nouveauMotCle;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("Erreur lors de l'encodage du mot clé.");
        return null;

    }

    private static void voirOffresDeStageNonValidees(Connection conn) {
        String query = "SELECT * FROM projet.offres_non_validees";
        System.out.println();
        try (Statement statement = conn.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {

            // Parcourir les résultats du ResultSet
            while (resultSet.next()) {

                String codeStage = resultSet.getString("code_stage");
                String semestreStage = resultSet.getString("semestre_stage");
                String nomEntreprise = resultSet.getString("nom_entreprise");
                String description = resultSet.getString("description");

                System.out.println("Code du stage : " + codeStage);
                System.out.println("Semstre du stage : " + semestreStage);
                System.out.println("Nom de l'entreprise : " + nomEntreprise);
                System.out.println("Description : " + description);
                System.out.println();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static void validerOffreDeStage(Connection conn, OffreStage offreStage) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("\nEntrez le code du stage : ");
        String codeStage = scanner.nextLine();

        String query = "SELECT * FROM valider_offre_de_stage(?)";

        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setString(1, codeStage);

            try (ResultSet generatedKeys = preparedStatement.executeQuery()) {
                if (generatedKeys.next()) {
                    System.out.println("\nL'offre de stage " + codeStage + " a été validée avec succès !");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Erreur lors de la validation de l'offre de stage.");
        }
    }

    private static void voirOffresDeStageValidees(Connection conn) {
        String query = "SELECT * FROM projet.offres_validees";
        System.out.println();
        try (Statement statement = conn.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {

            // Parcourir les résultats du ResultSet
            while (resultSet.next()) {

                String codeStage = resultSet.getString("code_stage");
                String semestreStage = resultSet.getString("semestre_stage");
                String nomEntreprise = resultSet.getString("nom_entreprise");
                String description = resultSet.getString("description");

                System.out.println("Code du stage : " + codeStage);
                System.out.println("Semstre du stage : " + semestreStage);
                System.out.println("Nom de l'entreprise : " + nomEntreprise);
                System.out.println("Description : " + description);
                System.out.println();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static void voirEtudiantsSansStages(Connection conn) {
        String query = "SELECT * FROM projet.etudiants_sans_stages";
        System.out.println();
        try (Statement statement = conn.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {

            // Parcourir les résultats du ResultSet
            while (resultSet.next()) {

                String nomEtudiant = resultSet.getString("nom_etudiant");
                String prenomEtudiant = resultSet.getString("prenom_etudiant");
                String emailEtudiant = resultSet.getString("mail");
                String semestreStage = resultSet.getString("semestre_stage");
                int nbrCandidatureEnAttante = resultSet.getInt("nbr_candidature_en_attente");

                System.out.println("Nom de l'étudiant : " + nomEtudiant);
                System.out.println("Prénom de l'étudiant : " + prenomEtudiant);
                System.out.println("E-mail de l'étudiant : " + emailEtudiant);
                System.out.println("Semestre du stage : " + semestreStage);
                System.out.println("Nombre de candidature en attente : " + nbrCandidatureEnAttante);
                System.out.println();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static void voirOffresDeStageAttribuees(Connection conn) {
        String query = "SELECT * FROM projet.offres_attribuees";
        System.out.println();
        try (Statement statement = conn.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {

            // Parcourir les résultats du ResultSet
            while (resultSet.next()) {

                String codeStage = resultSet.getString("code_stage");
                String nomEntreprise = resultSet.getString("nom_entreprise");
                String nomEtudiant = resultSet.getString("nom_etudiant");
                String prenomEtudiant = resultSet.getString("prenom_etudiant");


                System.out.println("Code du stage : " + codeStage);
                System.out.println("Nom de l'entreprise : " + nomEntreprise);
                System.out.println("Nom de l'étudiant : " + nomEtudiant);
                System.out.println("Prénom de l'étudiant : " + prenomEtudiant);
                System.out.println();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}