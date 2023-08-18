import java.sql.*;
import java.util.LinkedHashSet;
import java.util.Set;


public class Tablero {
    private Set<Carta> cartaslvl1 = new LinkedHashSet<>();
    private Set<Carta> cartaslvl2 = new LinkedHashSet<>();
    private Set<Carta> cartaslvl3 = new LinkedHashSet<>();

    public Tablero(int idPartida, int torn, int idJugador, Connection connection) throws SQLException {
       actualizarTablero(idPartida, torn, idJugador, connection);
    }

    //actualizar las cartas del tablero de una partida
    public void actualizarTablero(int idPartida,  int turno, int idJugador, Connection connection) throws SQLException {
        Set<Carta> cartaslvl1 = new LinkedHashSet<>();
        Set<Carta> cartaslvl2 = new LinkedHashSet<>();
        Set<Carta> cartaslvl3 = new LinkedHashSet<>();
        Statement st = connection.createStatement();
        ResultSet rs;

        //cartas nivel 1
        String sql = "SELECT ct.idCarta from cartatablero as ct inner join carta as c on c.idCarta = ct.idCarta where c.nivel = " +
                1 + " and ct.idPartida = " + idPartida + " and ct.turno = " + turno + " and idjugador = " + idJugador + " order by ct.idCarta";

        rs = st.executeQuery(sql);

        while (rs.next()){
            cartaslvl1.add(new Carta(rs.getString(1)));
        }

        //cartas nivel 2
        sql = "SELECT ct.idCarta from cartatablero as ct inner join carta as c on c.idCarta = ct.idCarta where c.nivel = " +
                2 + " and ct.idPartida = " + idPartida + " and ct.turno = " + turno + " and idjugador = " + idJugador + " order by ct.idCarta";

        rs = st.executeQuery(sql);

        while (rs.next()){
            cartaslvl2.add(new Carta(rs.getString(1)));
        }

        //cartas nivel 3
        sql = "SELECT ct.idCarta from cartatablero as ct inner join carta as c on c.idCarta = ct.idCarta where c.nivel = " +
                3 + " and ct.idPartida = " + idPartida + " and ct.turno = " + turno + " and idjugador = " + idJugador + " order by ct.idCarta";

        rs = st.executeQuery(sql);

        while (rs.next()){
            cartaslvl3.add(new Carta(rs.getString(1)));
        }

        this.cartaslvl1 = cartaslvl1;
        this.cartaslvl2 = cartaslvl2;
        this.cartaslvl3 = cartaslvl3;
    }

    //saber el número de gemas de un color de una partida.
    public int getNumGema(int idPartida, Color color, Connection connection) throws SQLException {
        Statement st = connection.createStatement();
        ResultSet rs;
        String sql = "SELECT GemasDisponiblesTablero(" + idPartida + ", '" + color.toString() + "')";
        rs = st.executeQuery(sql);
        rs.next();
        return rs.getInt(1);
    }

    public Set<Carta> getCartaslvl1() {
        return cartaslvl1;
    }

    public Set<Carta> getCartaslvl2() {
        return cartaslvl2;
    }

    public Set<Carta> getCartaslvl3() {
        return cartaslvl3;
    }
}
