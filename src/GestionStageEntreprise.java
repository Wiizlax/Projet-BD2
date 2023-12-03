import java.sql.*;
import java.util.Scanner;

public class GestionStageEntreprise {

    private static Scanner scanner;

    public static void main(String[] args) {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }

        String url="jdbc:postgresql://localhost:5432/postgres";
        Connection conn=null;
        try {
            conn= DriverManager.getConnection(url,"postgres","coursbd123"); // password = votre password postgres
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
        Entreprise entrepriseConnecte = null;

        // Boucle authentification entreprise
        while (entrepriseConnecte == null) {
            entrepriseConnecte = authenticateCompany(conn);

            if (entrepriseConnecte != null) {
                System.out.println("Connexion réussie pour l'entreprise : " + entrepriseConnecte.getNom_entreprise());

                afficherMenu(entrepriseConnecte,conn);
            } else {
                System.out.println("Mauvais mail ou mot de passe ! Veuillez réessayer.");
            }
        }
    }

    private static void afficherMenu(Entreprise entreprise, Connection conn) {
        Scanner scanner = new Scanner(System.in);

        int choix;
        do {
            System.out.println("\n Entreprise " + entreprise.getNom_entreprise());
            System.out.println("\n Menu Entreprise :");
            System.out.println("\n Menu Entreprise :");
            System.out.println("1 -> Encoder une offre de stage.");
            System.out.println("2 -> Voir les mots-clés disponibles pour décrire une offre de stage.");
            System.out.println("3 -> Ajouter un mot-clé à une de ses offres de stage.");
            System.out.println("4 -> Voir mes offres de stages.");
            System.out.println("5 -> Voir les candidatures pour une de mes offres de stages.");
            System.out.println("6 -> Sélectionner un étudiant pour une de mes offres de stage.");
            System.out.println("7 -> Annuler une offre de stage.");
            System.out.println("0 -> Quitter");

            // Demander le choix à l'utilisateur
            System.out.print("Choix : ");
            choix = scanner.nextInt();

            // Effectuer l'action en fonction du choix
            switch (choix) {
                case 0:
                    System.out.println("Au revoir !");
                    break;
                case 1:
                    encoderNouvelleOffreStage(conn , entreprise);
                    break;
                case 2:
                    //
                    break;
                case 3:
                    //
                    break;
                case 4:
                    //
                    break;
                case 5:
                    //
                    break;
                case 6:
                    //
                    break;
                case 7:
                    //
                    break;
                default:
                    System.out.println("Choix invalide. Veuillez réessayer.");
            }
        } while (choix != 0);
    }

    private static Entreprise authenticateCompany(Connection conn) {
        Scanner scanner = new Scanner(System.in);

        System.out.print("Entrez l'email de l'entreprise : ");
        String email = scanner.nextLine();

        System.out.print("Entrez le mot de passe : ");
        String motDePasse = scanner.nextLine();

        // Requête pour vérifier l'authentification
        String query = "SELECT * FROM projet.entreprises et WHERE et.adresse_mail  = ? AND mot_de_passe = ?";
        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setString(1, email);
            preparedStatement.setString(2, motDePasse);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    // Création de l'objet Entreprise avec les informations de la base de données
                    Entreprise entreprise = new Entreprise();
                    entreprise.setId_entreprise(resultSet.getString("id_entreprise"));
                    entreprise.setAdresse_mail(email);
                    entreprise.setMot_de_passe(motDePasse);
                    entreprise.setNom_entreprise(resultSet.getString("nom_entreprise"));
                    entreprise.setAdresse_entreprise(resultSet.getString("adresse_entreprise"));

                    return entreprise;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    private static OffreStage encoderNouvelleOffreStage(Connection conn , Entreprise entreprise) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("\n Entrez le code d'identification désiré :  ");
        String codeStage = scanner.nextLine();
        System.out.print("\n Entrez le semestre auquel le stage se déroulera : ");
        String semestre_stage = scanner.nextLine();
        System.out.print("\n Entrez la description de l'offre : ");
        String description = scanner.nextLine();

        OffreStage nouvelleOffre = new OffreStage();
        nouvelleOffre.setEntreprise(entreprise);
        nouvelleOffre.setCode_stage(codeStage);
        nouvelleOffre.setDescription(description);
        nouvelleOffre.setSemestre_stage(semestre_stage); // Set the ID of the company offering the internship

        String query = "INSERT INTO projet.offres_de_stage ( entreprise, code_stage , etat, semestre_stage, description) VALUES (?, ?,DEFAULT , ?, ?)";
        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setString(1, nouvelleOffre.getEntreprise().getId_entreprise());
            preparedStatement.setString(2, nouvelleOffre.getCode_stage());
            preparedStatement.setString(3, nouvelleOffre.getSemestre_stage());
            preparedStatement.setString(4, nouvelleOffre.getDescription());
            int rowsAffected = preparedStatement.executeUpdate();
            if (rowsAffected > 0) {
                // verifie si on a modifié + d'une colonne
                try (ResultSet generatedKeys = preparedStatement.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        nouvelleOffre.setIdOffreStage(generatedKeys.getInt(1));
                        System.out.println("Offre de stage encodée avec succès : " + nouvelleOffre.toString());
                        System.out.println("\n ID de l'offre : " + nouvelleOffre.getIdOffreStage());
                        return nouvelleOffre;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("Erreur lors de l'encodage de l'offre de stage.");
        return null;
    }


}
