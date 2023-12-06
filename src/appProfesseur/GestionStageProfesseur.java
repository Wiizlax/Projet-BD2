package appProfesseur;

import appEntreprise.BCrypt;
import appEntreprise.Entreprise;
import appEtudiant.Etudiant;

import java.sql.*;
import java.util.Scanner;

public class GestionStageProfesseur {

    private static Scanner scanner;

    public static void main(String[] args) {

        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }

        String url = "jdbc:postgresql://localhost:5432/postgres";
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(url, "postgres", "Tomtom2002=Wiizlax"); //ton mdp postgres
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
        afficherMenu(conn);
    }

    private static void afficherMenu(Connection conn) {
        Scanner scanner = new Scanner(System.in);

        int choix;
        do {
            System.out.println("\nMenu professeur :");
            System.out.println("0 -> Quitter");
            System.out.println("1 -> Encoder un étudiant");
            System.out.println("2 -> Encoder une entreprise");

            System.out.print("Choix : ");

            if (scanner.hasNextInt()) {
                choix = scanner.nextInt();

                switch (choix) {
                    case 0 -> System.out.println("Au revoir !");
                    case 1 -> encoderEtudiant(conn);
                    case 2 -> encoderEntreprise(conn);
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

        String query = "INSERT INTO projet.etudiants (nom_etudiant,prenom_etudiant,mail,semestre_stage,mot_de_passe,nbr_candidature_en_attente) VALUES (?,?,?,?,?,DEFAULT) RETURNING id_etudiant";
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
        System.out.print("\nEntrez  l'identifiant de l'entreprise (3 lettres majuscules) : ");
        String idEntreprise = scanner.nextLine();
        System.out.print("\nEntrez le mot de passe de l'entreprise : ");
        String mdpEntreprise = scanner.nextLine();

        Entreprise nouvelleEntreprise = new Entreprise();
        nouvelleEntreprise.setNom_entreprise(nomEntreprise);
        nouvelleEntreprise.setAdresse_entreprise(adresseEntreprise);
        nouvelleEntreprise.setId_entreprise(idEntreprise);
        nouvelleEntreprise.setMot_de_passe(mdpEntreprise);

        String query = "INSERT INTO projet.etudiants (id_entreprise, nom_entreprise, adresse_entreprise, adresse_mail, mot_de_passe) VALUE (?,?,?,?,?) RETURNING id_entreprise";
        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setString(1, nouvelleEntreprise.getId_entreprise());
            preparedStatement.setString(2, nouvelleEntreprise.getNom_entreprise());
            preparedStatement.setString(3, nouvelleEntreprise.getAdresse_entreprise());
            preparedStatement.setString(4, nouvelleEntreprise.getAdresse_mail());
            preparedStatement.setString(5, nouvelleEntreprise.getMot_de_passe());


            // verifie si on a modifié + d'une colonne
            try (ResultSet generatedKeys = preparedStatement.executeQuery()) {
                if (generatedKeys.next()) {
                    String id_Entreprise = generatedKeys.getString(1); // Récupération de la valeur de la colonne auto-incrémentée
                    nouvelleEntreprise.setId_entreprise(id_Entreprise);
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
}