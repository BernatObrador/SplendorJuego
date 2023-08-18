import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class Noble implements Row{
    private final int id;
    private final String topRow = "╔═════════════╗  ";
    private String topIdRow = "║             ║  ";
    private final String midRow = "║             ║  ";
    private String bottomIdRow = "║ ";
    private final String bottomRow = "╚═════════════╝  ";

    public Noble(int id, Connection connection) throws SQLException {
        PintarColor p = new PintarColor();
        this.id = id;

        Statement st = connection.createStatement();
        ResultSet rs;

        //miramos cuantos colores tiene el noble.
        String sql = "SELECT count(*) from costenobles where idnoble = " + id;
        rs = st.executeQuery(sql);
        rs.next();
        int numeroDeColores = rs.getInt(1);

        sql = "SELECT coste, idcolor from costenobles where idnoble = " + id;
        rs = st.executeQuery(sql);
        int countColor = 0;

        for (int j = 0, x = 2; j < numeroDeColores; j++, x += 2) {
            rs.next();
            String color = rs.getString(2);
            //tenemos que verificar el color, ya que tenemos tanto Black como Blue, y los dos empiezan por B
            switch (color){
                case "Black" -> color = "N";
                case "Green" -> color = "G";
                case "Red" -> color = "R";
                case "Blue" -> color = "B";
                case "White" -> color = "W";
            }
            String coste = rs.getInt(1) + p.elegirColor(color) + p.b;
            //countColor sirve para calcular la longitud real, ya que cada vez que usamos la clase pintar, se alarga la longitud del string
            countColor += 9;
            bottomIdRow += coste + " ";
        }
        for (int i = bottomIdRow.length(); i < 14 + countColor; i++) {
            bottomIdRow += " ";
        }

        bottomIdRow += "║  ";
    }

    public int getId() {
        return id;
    }

    public String getTopRow() {
        return topRow;
    }

    public String getTopIdRow() {
        return topIdRow;
    }

    public String getMidRow() {
        return midRow;
    }

    public String getBottomIdRow() {
        return bottomIdRow;
    }

    public String getBottomRow() {
        return bottomRow;
    }
}
