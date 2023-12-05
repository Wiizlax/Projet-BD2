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
            conn = DriverManager.getConnection(url, "postgres", "mdp"); //ton mdp postgres
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

            System.out.print("Choix : ");
            choix = scanner.nextInt();

            switch (choix) {
                case 0 -> System.out.println("Au revoir !");
                default -> System.out.println("Choix invalide. Veuillez réessayer.");
            }
        } while (choix != 0);
    }

}