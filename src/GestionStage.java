import java.sql.*;
import java.util.Scanner;

public class GestionStage {

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
            conn= DriverManager.getConnection(url,"postgres","mdp"); // password = votre password postgres
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
/*
        try {
            PreparedStatement ps = conn.prepareStatement("INSERT INTO" + "exercice.utilisateurs VALUES(DEFAULT, ?, ?);");
            ps.setString(1,"Damas");
            ps.setString(2,"Christophe");
            ps.executeUpdate();
            ps.setString(1,"Ferneeuw");
            ps.setString(2,"Stéphanie");
            ps.executeUpdate();
        } catch (SQLException se) {
            System.out.println("Erreur lors de l’insertion !");
            se.printStackTrace();
            System.exit(1);
        }


        try {
            Statement s = conn.createStatement();
            try (ResultSet rs = s.executeQuery("SELECT nom" +
                    "FROM exercice.utilisateurs;")) {
                while (rs.next()) {
                    System.out.println(rs.getString(1));
                }
            }
        } catch (SQLException se) {
            se.printStackTrace();
            System.exit(1);
        }

        System.out.println("Entrez vos nom et prénom:");
        String nom=scanner.nextLine();
        String prenom=scanner.nextLine();
        try {
            Statement s = conn.createStatement();
            s.executeUpdate("INSERT INTO exercice.utilisateurs "+
                    "VALUES (DEFAULT, '"+nom+"', '"+prenom+"');");
        } catch (SQLException se) {
            System.out.println("Erreur lors de l’insertion !");
            se.printStackTrace();
            System.exit(1);
        }

*/
    }
}
