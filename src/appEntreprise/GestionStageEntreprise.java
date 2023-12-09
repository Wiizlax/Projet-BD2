package appEntreprise;

import java.sql.*;
import java.util.Scanner;

public class GestionStageEntreprise {

    private Scanner scanner;
    private Connection conn;
    private Entreprise entrepriseConnecte;

    public GestionStageEntreprise() {
        scanner = new Scanner(System.in);
        conn = null;
        entrepriseConnecte = null;
    }

    /**
     * lance le programme gestionStageEntreprise
     */
    public void run() {
        initializeDatabase();

        while (entrepriseConnecte == null) {
            entrepriseConnecte = authenticateCompany(conn);

            if (entrepriseConnecte != null) {
                System.out.println("Connexion réussie pour l'entreprise : " + entrepriseConnecte.getNom_entreprise());
                afficherMenu(entrepriseConnecte, conn);
            } else {
                System.out.println("Mauvais mail ou mot de passe ! Veuillez réessayer.");
            }
        }
    }

    /**
     * initialise la base de donnees
     */
    private void initializeDatabase() {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }

        String url = "jdbc:postgresql://172.24.2.6:5432/dbtomsimonis";
        try {
            conn = DriverManager.getConnection(url, "eduardosampaio", "KNBO95M8H");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
    }

    /**
     * affiche le menu avec les choix tant que celui-ci est différent de 0
     */
    private void afficherMenu(Entreprise entreprise, Connection conn) {

        int choix;
        do {
            System.out.println("-------------------------------------------------------");
            System.out.println("\n appEntreprise.Entreprise " + entreprise.getNom_entreprise());
            System.out.println("\n Menu appEntreprise.Entreprise :");

            System.out.println("1 -> Encoder une offre de stage.");
            System.out.println("2 -> Voir les mots-clés disponibles pour décrire une offre de stage.");
            System.out.println("3 -> Ajouter un mot-clé à une de ses offres de stage.");
            System.out.println("4 -> Voir mes offres de stages.");
            System.out.println("5 -> Voir les candidatures pour une de mes offres de stages.");
            System.out.println("6 -> Sélectionner un étudiant pour une de mes offres de stage.");
            System.out.println("7 -> Annuler une offre de stage.");
            System.out.println("0 -> Quitter");

            if (scanner.hasNextInt()) {
                // Demander le choix à l'utilisateur
                System.out.print("Choix : \n");
                choix = scanner.nextInt();

                // Effectuer l'action en fonction du choix
                switch (choix) {
                    case 0 -> System.out.println("Au revoir !");
                    case 1 -> encoderNouvelleOffreStage(conn, entreprise);
                    case 2 -> voirMotClesDisponibles(conn);
                    case 3 -> ajouterMotCleAOffre(conn, entreprise);
                    case 4 -> voirOffresStage(conn, entreprise);
                    case 5 -> voirLesCandidaturesPourUneOffre(conn, entreprise);
                    case 6 -> selectionnerEtudiantPouroffre(conn, entreprise);
                    case 7 -> annulerOffreDeStage(conn, entreprise);
                    default -> System.out.println("Choix invalide. Veuillez réessayer.");
                }
            } else {
                System.out.println("Veuillez entrer un nombre entier.");
                scanner.nextLine(); // Consomme la ligne invalide
                choix = -1;
            }
        } while (choix != 0);
    }

    /**
     * @param conn connection a la database
     */
    private Entreprise authenticateCompany(Connection conn) {
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
                    // Création de l'objet appEntreprise.Entreprise avec les informations de la base de données
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

    /**
     * @param entreprise l entreprise connecte
     * @param conn connection a la database
     */
    private void encoderNouvelleOffreStage(Connection conn, Entreprise entreprise) {

        Scanner scanner = new Scanner(System.in);
        System.out.print("\n Entrez le semestre auquel le stage se déroulera : ");
        String semestre_stage = scanner.nextLine();
        System.out.print("\n Entrez la description de l'offre : ");
        String description = scanner.nextLine();

        OffreStage nouvelleOffre = new OffreStage();
        nouvelleOffre.setEntreprise(entreprise);
        nouvelleOffre.setDescription(description);
        nouvelleOffre.setSemestre_stage(semestre_stage); // Set the ID of the company offering the internship

        String query = "SELECT * FROM projet.encoderOffreStage(?,?,?)";
        try (PreparedStatement preparedStatement = conn.prepareStatement(query)) {
            preparedStatement.setString(1, nouvelleOffre.getEntreprise().getId_entreprise());
            preparedStatement.setString(2, nouvelleOffre.getSemestre_stage());
            preparedStatement.setString(3, nouvelleOffre.getDescription());


            // verifie si on a modifié + d'une colonne
            try (ResultSet generatedKeys = preparedStatement.executeQuery()) {
                if (generatedKeys.next()) {
                    String codeOffre = generatedKeys.getString(1);
                    System.out.println("\nOffre de stage avec le code " +codeOffre+ " encodée avec succès !  ");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Erreur lors de l'encodage de l'offre de stage.");
        }

    }

    /**
     * @param conn connection a la database
     */
    private void voirMotClesDisponibles(Connection conn) {
        String sqlQuery = "SELECT id_mot_cle , mot FROM projet.mots_cles mc";
        try (Statement statement = conn.createStatement();
             ResultSet resultSet = statement.executeQuery(sqlQuery)) {

            // Parcourir les résultats du ResultSet
            int i = 0;
            while (resultSet.next()) {
                i++;
                int idMotCle = resultSet.getInt("id_mot_cle");
                String mot = resultSet.getString("mot");
                //affichage des mots clés
                MotsCles motsCles = new MotsCles(idMotCle, mot);
                System.out.println("Mot clé " + motsCles.getIdMotCle() + " : " + motsCles.getMot());
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * @param entreprise l entreprise connecte
     * @param conn connection a la database
     */
    private void ajouterMotCleAOffre(Connection conn, Entreprise entreprise) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("\n Entrez le code de l'offre que vous voulez ajouter un mot clé :  ");
        String codeOffre = scanner.nextLine();
        System.out.print("\n Entrez le mot clé : ");
        String motCle = scanner.nextLine();

        String sqlQuery = "SELECT * FROM projet.ajoutMotCleAUneOffre(?,?,?)";
        try (PreparedStatement preparedStatement = conn.prepareStatement(sqlQuery)) {
            preparedStatement.setString(1, entreprise.getId_entreprise());
            preparedStatement.setString(2, codeOffre);
            preparedStatement.setString(3, motCle);
            System.out.println("\n ");
            try (ResultSet generatedKeys = preparedStatement.executeQuery()) {
                if (generatedKeys.next()) {
                    System.out.println("\n Mot Clé : " + motCle + " ajouté à l'offre " + codeOffre + " avec succès !");
                }
            }
        } catch (SQLException e) {
            System.out.println("Erreur lors de l'ajout d'un mot clé à une offre de stage.");
            e.printStackTrace();
        }

    }

    /**
     * @param entreprise l entreprise connecte
     * @param conn connection a la database
     */
    private void voirOffresStage(Connection conn, Entreprise entreprise) {
        String sqlQuery = "SELECT * FROM projet.afficher_offres_par_entreprise(?)";
        try (PreparedStatement preparedStatement = conn.prepareStatement(sqlQuery)) {
            preparedStatement.setString(1, entreprise.getId_entreprise());
            try (ResultSet resultSet = preparedStatement.executeQuery()) {

                while (resultSet.next()) {
                    String code_stage = resultSet.getString("code_stage");
                    String description = resultSet.getString("description");
                    String semestreStage = resultSet.getString("semestre_stage");
                    String etat = resultSet.getString("etat");
                    int nbrCandidaturesAttente = resultSet.getInt("nbr_candidatures_en_attente");
                    String nomEtudiant = resultSet.getString("nom_etudiant");

                    //affichage des offres

                    System.out.println("__________________Offre " + code_stage + "______________________");
                    System.out.println("Offre de Stage de code : " + code_stage);
                    System.out.println(" Description : " + description);
                    System.out.println(" Semetres : " + semestreStage);
                    System.out.println(" Etat de l'offre : " + etat);
                    System.out.println("Nombre de candidatures en attente : " + nbrCandidaturesAttente);
                    System.out.println("nom de l'etudiant : " + nomEtudiant);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * @param entreprise l entreprise connecte
     * @param conn connection a la database
     */
    private void voirLesCandidaturesPourUneOffre(Connection conn, Entreprise entreprise) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("\n Entrez le code de l'offre que vous voulez verifier les candidatures :  ");
        String codeOffre = scanner.nextLine();

        String sqlQuery = "SELECT * FROM projet.getCandidaturesPourOffre(?,?)";
        try (PreparedStatement preparedStatement = conn.prepareStatement(sqlQuery)) {
            preparedStatement.setString(1, entreprise.getId_entreprise());
            preparedStatement.setString(2, codeOffre);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                int i = 0;
                while (resultSet.next()) {
                    i++;
                    String mailEtudiant = resultSet.getString("mail_etudiant");
                    String etat = resultSet.getString("etat");
                    String nomEtudiant = resultSet.getString("nom_etudiant");
                    String motivationEtudiant = resultSet.getString("motivation_etudiant");

                    //affichage des offres

                    System.out.println("__________________ Candidature  " + i + " ______________________");
                    System.out.println(" Nom appEtudiant.Etudiant : " + nomEtudiant);
                    System.out.println(" E-mail etudiant : " + mailEtudiant);
                    System.out.println(" Motivation : " + motivationEtudiant);
                    System.out.println(" Etat de la candidature : " + etat);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * @param entreprise l entreprise connecte
     * @param conn connection a la database
     */
    private void selectionnerEtudiantPouroffre(Connection conn, Entreprise entreprise) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("\n Entrez le code de l'offre :  ");
        String codeOffre = scanner.nextLine();
        System.out.print("\n Entrez l'email de l'etudiant que vous voulez attribuer pour l'offre " + codeOffre + " : ");
        String etudiant = scanner.nextLine();

        String sqlQuery = "select projet.selectionner_etudiant(?,?,?)";
        try (PreparedStatement preparedStatement = conn.prepareStatement(sqlQuery)) {
            preparedStatement.setString(1, entreprise.getId_entreprise());
            preparedStatement.setString(2, codeOffre);
            preparedStatement.setString(3, etudiant);
            try (ResultSet generatedKeys = preparedStatement.executeQuery()) {
                if (generatedKeys.next()) {
                    System.out.println("\nL'etudiant  " + etudiant + " a été accepté pour l'offre " + codeOffre + " avec succès !");
                    System.out.println("Toutes les autres candidatures pour l'offre " + codeOffre + " ont été refuées !");
                }
            }
        } catch (SQLException e) {
            System.out.println("Erreur lors de l'ajout d'un mot clé à une offre de stage.");
            e.printStackTrace();
        }
    }

    /**
     * @param entreprise l entreprise connecte
     * @param conn connection a la database
     */
    private void annulerOffreDeStage(Connection conn, Entreprise entreprise) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("\n Entrez le code de l'offre que vous voulez annuler :  ");
        String codeOffre = scanner.nextLine();
        String sqlQuery = "SELECT projet.annulerOffreDeStage(?,?)";
        try (PreparedStatement preparedStatement = conn.prepareStatement(sqlQuery)) {
            preparedStatement.setString(1, codeOffre);
            preparedStatement.setString(2, entreprise.getId_entreprise());

            try (ResultSet generatedKeys = preparedStatement.executeQuery()) {
                if (generatedKeys.next()) {
                    System.out.println("\nL'offre de stage   " + codeOffre + " a été annulé avec succès !");
                    System.out.println("Toutes les candidatures pour l'offre " + codeOffre + " ont été refuées !");
                }
            }
        } catch (SQLException e) {
            System.out.println("Erreur lors de l'ajout d'un mot clé à une offre de stage.");
            e.printStackTrace();
        }
    }


}
