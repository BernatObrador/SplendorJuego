import java.sql.*;
import java.util.LinkedHashSet;
import java.util.Set;


public class Jugador {
    private final int id;
    private String nombre;
    private int puntuacion = 0;
    private Partida partidaActual;

    private Set<Carta> mano = new LinkedHashSet<>();
    private Set<Noble> manoNoble = new LinkedHashSet<>();

    public Jugador(int id, Connection connection)throws SQLException {
        this.id = id;
        Statement st = connection.createStatement();
        ResultSet rs;
        //cogemos el nombre y la puntuación del jugador
        String sql = "SELECT nombre from jugador where idjugador = " + id;
        rs = st.executeQuery(sql);
        rs.next();
        this.nombre = rs.getString(1);
    }

    //para crear un jugador con una partida actual asignada.
    public Jugador(int id, Partida partidaActual, Connection connection) throws SQLException {
        this.id = id;
        Statement st = connection.createStatement();
        ResultSet rs;
        String sql = "SELECT nombre, rango from jugador where idjugador = " + id;
        rs = st.executeQuery(sql);
        rs.next();
        this.nombre = rs.getString(1);
        this.puntuacion = rs.getInt(2);
        this.partidaActual = partidaActual;
        actualizarMano(connection);
        actualizarNobles(connection);
        actualizarPuntuacion(connection);
    }

    //actualizar la mano de los nobles del jugador
    public void actualizarNobles(Connection connection) throws SQLException {
        Set<Noble> manoNoble = new LinkedHashSet<>();
        Statement st = connection.createStatement();
        ResultSet rs;
        String sql = "SELECT idnoble from noblepartida where idpartida = " + this.partidaActual.getIdPartida() + " and idJugador = " + this.id;
        rs = st.executeQuery(sql);

        while (rs.next()){
            manoNoble.add(new Noble(rs.getInt(1), connection));
        }
        this.manoNoble = manoNoble;
    }

    //actualizar la puntuación de una partida del jugador
    public void actualizarPuntuacion(Connection connection) throws SQLException {
        Statement st = connection.createStatement();
        ResultSet rs;
        String sql = "SELECT GetPuntJgdrAcc(" + partidaActual.getIdPartida() + ", " + this.id + ", " + getDarreraAccioJugador(connection) + ")";
        rs = st.executeQuery(sql);
        rs.next();
        this.puntuacion = rs.getInt(1);
    }

    //saber las gemas de un color que tiene el jugador
    public int getGemas(Connection connection, Color color) throws SQLException {
        Statement st = connection.createStatement();
        ResultSet rs;

        String sql = "SELECT GetNumGemColAcc( '" + color.toString() + "' ," + partidaActual.getIdPartida() + ", " + this.id + ", " + getDarreraAccioJugador(connection) + ")";
        rs = st.executeQuery(sql);
        rs.next();
        return rs.getInt(1);
    }

    //actualizar la mano de cartas del jugador
    public void actualizarMano(Connection connection) throws SQLException {
        Set<Carta> mano = new LinkedHashSet<>();
        Statement st = connection.createStatement();
        ResultSet rs;
        String sql = "SELECT cj.idCarta, cj.reservada from cartajugador as cj inner join carta as c on c.idcarta = cj.idcarta where cj.idpartida = " + partidaActual.getIdPartida() + " and cj.idjugador = "
                + this.id + " and turno = " + getDarreraAccioJugador(connection) + " order by c.idcolor";
        rs = st.executeQuery(sql);

        while (rs.next()){
            mano.add(new Carta(rs.getString(1), rs.getBoolean(2)));
        }
        this.mano = mano;
    }

    //Nos devolverá la última accion que ha tenido el jugador en su partida actual
    public int getDarreraAccioJugador(Connection connection) throws SQLException {
        if(partidaActual.getIdPartida() > -1) {
            Statement st = connection.createStatement();
            ResultSet rs;
            String sql = "select turno from accion where idjugador = " + this.id + " and idpartida = " + this.partidaActual.getIdPartida() + " order by turno desc limit 1";
            rs = st.executeQuery(sql);
            rs.next();
            return rs.getInt(1);
        }
        return -1;
    }

    //accion de comprar una carta
    public void accBuy(int idPartida, String idCarta, Connection connection) throws SQLException {
        CallableStatement cstmt = connection.prepareCall("{CALL novaaccbuy(?, ?)}");
        cstmt.setInt(1, idPartida);
        cstmt.setString(2, idCarta);
        cstmt.execute();
    }

    //accion de reservar una carta del tablero
    public void accHold(int idPartida, String idCarta, Connection connection) throws SQLException{
        CallableStatement cstmt = connection.prepareCall("{CALL novaacchold(?, ?)}");
        cstmt.setInt(1, idPartida);
        cstmt.setString(2, idCarta);
        cstmt.execute();
    }

    //accion de reservar una carta a ciegas
    public void accBlindHold(int idPartida, byte nivel, Connection connection) throws SQLException {
        CallableStatement cstmt = connection.prepareCall("{CALL novaaccblindhold(?, ?)}");
        cstmt.setInt(1, idPartida);
        cstmt.setByte(2, nivel);
        cstmt.execute();
    }

    //accion de coger 2 gemas del mismo color
    public void accTake2g(int idPartida, Color color, Connection connection) throws SQLException {
        CallableStatement cstmt = connection.prepareCall("{CALL novaacctake2g(?, ?)}");
        cstmt.setInt(1, idPartida);
        cstmt.setString(2, color.toString());
        cstmt.execute();
    }

    //accion de coger 3 gemas, cada una de distinto color
    public void accTake3g(int idPartida, Color color, Color color2, Color color3, Connection connection) throws SQLException {
        CallableStatement cstmt = connection.prepareCall("{CALL novaacctake3g(?, ?, ?, ?)}");
        cstmt.setInt(1, idPartida);
        cstmt.setString(2, color.toString());
        cstmt.setString(3, color2.toString());
        cstmt.setString(4, color3.toString());
        cstmt.execute();
    }

    //accion de pasar
    public void accPass(int idPartida, Connection connection) throws SQLException {
        CallableStatement cstmt = connection.prepareCall("{CALL novaaccPass(?)}");
        cstmt.setInt(1, idPartida);
        cstmt.execute();
    }

    public int getId() {
        return id;
    }

    public String getNombre() {
        return nombre;
    }

    public int getPuntuacion() {
        return puntuacion;
    }

    public Partida getPartidaActual() {
        return partidaActual;
    }

    public Set<Carta> getMano() {
        return mano;
    }

    public void setPartidaActual(Partida partidaActual) {
        this.partidaActual = partidaActual;
    }

    public Set<Noble> getManoNoble() {
        return manoNoble;
    }
}
