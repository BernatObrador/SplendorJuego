import java.sql.*;
import java.util.*;

public class Partida {
    private int idPartida;
    private Set<Noble> nobles = new LinkedHashSet<>();
    private Tablero tablero;
    private Set<Jugador> jugadores = new LinkedHashSet<>();

    //para crear una partida nueva
    public Partida(int puntuacion, List<Jugador> ids, Connection connection) throws SQLException {
        String nuevoIdPart = "SELECT idpartida + 1 from partida order by idpartida desc limit 1";
        Statement st = connection.createStatement();
        ResultSet idPartNew = st.executeQuery(nuevoIdPart);
        idPartNew.next();
        //Si no hay ninguna partida creada nos crea la partida 1
        try {
            this.idPartida = idPartNew.getInt("idPartida + 1");
        }catch (Exception e){
            this.idPartida = 1;
        }
        Collections.shuffle(ids);
        crearPartida(ids, puntuacion, connection);

        this.tablero = new Tablero(this.idPartida, getDarreraAccio(connection, false), getDarreraAccio(connection, true), connection);
        actualizarNobles(connection);
    }

    //unirse a una partida
    public Partida(int idPartida, Connection connection) throws SQLException {
        this.idPartida = idPartida;
        this.tablero = new Tablero(this.idPartida, getDarreraAccio(connection, false), getDarreraAccio(connection, true), connection);
        actualizarNobles(connection);
        actualizarJugadores(connection);
    }

    //actualizar los jugadores de una partida
    public void actualizarJugadores(Connection connection) throws SQLException{
        Statement st = connection.createStatement();
        ResultSet rs;
        String sql = "SELECT idJugador from jugadorpartida where idpartida = " + this.idPartida + " order by orden";
        rs = st.executeQuery(sql);

        while (rs.next()){
            int id = rs.getInt(1);
            this.jugadores.add(new Jugador(id, this,connection));
        }
    }

    //actualizar los nobles de una partida
    public void actualizarNobles(Connection connection) throws SQLException {
        Set<Noble> nobles = new LinkedHashSet<>();
        Statement st = connection.createStatement();
        ResultSet rs;
        String sql = "SELECT idnoble from noblepartida where idpartida = " + this.idPartida + " and idjugador IS NULL";
        rs = st.executeQuery(sql);

        while (rs.next()){
            nobles.add(new Noble(rs.getInt(1), connection));
        }
        this.nobles = nobles;
    }

    //saber la última accion o turno de una partida(false para turno, true para el jugador)
    public int getDarreraAccio(Connection connection, boolean fTurnoTJugador) throws SQLException {
        CallableStatement stmt;
        stmt = connection.prepareCall("{CALL GetDarreraAccioPrt(?, ?, ?)}");
        stmt.setInt(1,this.idPartida);
        stmt.registerOutParameter(2, java.sql.Types.INTEGER);
        stmt.registerOutParameter(3, java.sql.Types.INTEGER);
        stmt.execute();

        if(!fTurnoTJugador) {
            return stmt.getInt(3);
        } else {
            return stmt.getInt(2);
        }
    }

    //saber la accion siguiente de un jugador y un turno.
    public int getAccioSeguent(Connection connection, int idJugActual, int turnoActual) throws SQLException{
        CallableStatement stmt;
        stmt = connection.prepareCall("{CALL getAccioSeguent(?, ?, ?, ?, ?)}");

        stmt.setInt(1, this.idPartida);
        stmt.setInt(2, idJugActual);
        stmt.setInt(3, turnoActual);
        stmt.registerOutParameter(4, java.sql.Types.INTEGER);
        stmt.registerOutParameter(5, java.sql.Types.INTEGER);

        stmt.execute();
        return stmt.getInt(4);
    }

    //para crear partidas
    private void crearPartida(List<Jugador> ids, int puntuacion, Connection connection) throws SQLException {
        int numJug = ids.size();
        CallableStatement c = connection.prepareCall("{CALL crearprt(?, ?, ?, ?, ?, ?, ?, ?)}");
        c.setInt(1, idPartida);
        c.setInt(2, 1);
        c.setInt(3, puntuacion);
        c.setInt(4, 30);
        c.setInt(5, ids.get(0).getId());
        c.setInt(6, ids.get(1).getId());
        if(numJug < 3) {
            c.setInt(7, -1);
        } else {
            c.setInt(7, ids.get(2).getId());
        }
        if(numJug == 4) {
            c.setInt(7, ids.get(3).getId());
        } else {
            c.setInt(8, -1);
        }
        c.execute();
    }

    public int getIdPartida() {
        return idPartida;
    }

    public Set<Noble> getNobles() {
        return nobles;
    }

    public Tablero getTablero() {
        return tablero;
    }

    public Set<Jugador> getJugadores() {
        return jugadores;
    }
}
