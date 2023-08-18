import java.sql.*;
import java.util.*;

public class Main {
    private static boolean existePartida(int idPartida, int idJugador, Connection connection) throws SQLException {
        Statement st = connection.createStatement();
        ResultSet rs;

        String sql = "SELECT idpartida from jugadorpartida where idpartida = " + idPartida + " and idJugador = " + idJugador;

        rs = st.executeQuery(sql);
        return rs.next();
    }

    private static boolean existeElJugador(Connection connection, int idJug) throws SQLException {
        Statement st = connection.createStatement();
        ResultSet rs;

        String sql = "SELECT idjugador from jugador where idjugador = " + idJug;

        rs = st.executeQuery(sql);

        int id = -1;
        if (rs.next()) {
            id = rs.getInt(1);
        }

        return id != -1;

    }

    //función para pintar cartas en la consola
    private static <E extends Row> void pintarCartas(Set<E> list) {
        for (E e : list) {
            System.out.print(e.getTopRow());
        }

        System.out.println();
        for (E e : list) {
            System.out.print(e.getTopIdRow());
        }

        System.out.println();
        for (E e : list) {
            System.out.print(e.getMidRow());
        }

        System.out.println();
        for (E e : list) {
            System.out.print(e.getBottomIdRow());
        }

        System.out.println();
        for (E e : list) {
            System.out.print(e.getBottomRow());
        }
    }

    private static void pintarCartaReservada(Set<Carta> list) {
        for (Carta e : list) {
            System.out.print(e.getTopRow());
        }

        System.out.println();
        for (Carta e : list) {
            System.out.print("║░░░┌─────┐░░░║  ");
        }

        System.out.println();
        for (Carta e : list) {
            System.out.print("║░░░└─────┐░░░║  ");
        }

        System.out.println();
        for (Carta e : list) {
            System.out.print("║░░░└─────┘░░░║  ");
        }

        System.out.println();
        for (Carta e : list) {
            System.out.print(e.getBottomRow());
        }
    }

    //pintar gemas del tablero
    private static void pintarGemas(Partida p, Connection connection) throws SQLException {
        PintarColor pc = new PintarColor();
        System.out.println("Gemas: ");
        System.out.print(pc.amarillo + "Doradas: " + pc.b + p.getTablero().getNumGema(p.getIdPartida(), Color.GOLD, connection) + "  ");
        System.out.print(pc.magenta + "Negras: " + pc.b + p.getTablero().getNumGema(p.getIdPartida(), Color.BLACK, connection) + "  ");
        System.out.print(pc.rojo + "Rojas: " + pc.b + p.getTablero().getNumGema(p.getIdPartida(), Color.RED, connection) + ", ");
        System.out.print(pc.verde + "Verdes: " + pc.b + p.getTablero().getNumGema(p.getIdPartida(), Color.GREEN, connection) + "  ");
        System.out.print(pc.azul + "Azules: " + pc.b + p.getTablero().getNumGema(p.getIdPartida(), Color.BLUE, connection) + "  ");
        System.out.print("Blancas: " + p.getTablero().getNumGema(p.getIdPartida(), Color.WHITE, connection) + "  ");
    }

    //Menu principal
    private static int eleccionJuego() {
        Scanner sc = new Scanner(System.in);
        int eleccionJuego = -1;
        do {
            try {
                System.out.println("Que quieres hacer:" + "\n" + "1. Ver el rango de los jugadores");
                System.out.println("2. Crear una partida");
                System.out.println("3. Unirse a una partida");
                System.out.println("4. Salir");
                eleccionJuego = sc.nextInt();
            }catch (Exception e){
                System.out.println("Elección errónea");
                sc.next();
            }
        } while (eleccionJuego < 1 || eleccionJuego > 4);

        return eleccionJuego;
    }

    //función para saber las partidas a las que se puede unir un jugador
    private static List<Integer> getPartidas(Connection connection, Jugador jugador) throws SQLException {
        Statement st = connection.createStatement();
        ResultSet rs;
        List<Integer> partidas = new ArrayList<>();

        //comprobamos las partidas en las que está el jugador.
        String sql = "SELECT idpartida from jugadorpartida where idjugador = " + jugador.getId();
        rs = st.executeQuery(sql);

        while (rs.next()){
            //comprobamos que la partida no ha acabado
            String game = "SELECT gameIsOver(" + rs.getInt(1) + ")";
            Statement s = connection.createStatement();
            ResultSet rs1;
            rs1 = s.executeQuery(game);
            rs1.next();
            int gameOver = rs1.getInt(1);
            //si la partida no ha acabado la metemos en la lista
            if(gameOver < 1){
                partidas.add(rs.getInt(1));
            }
        }

        return partidas;
    }

    private static boolean existeGema(String gema) {
        return gema.equalsIgnoreCase("BLUE") || gema.equalsIgnoreCase("RED") || gema.equalsIgnoreCase("GREEN") || gema.equalsIgnoreCase("WHITE") || gema.equalsIgnoreCase("BLACK");
    }

    //elección de la accion del jugador
    private static void eleccion(int eleccion, Connection connection, Partida partida, Jugador jugador) throws SQLException {
        Scanner sc = new Scanner(System.in);
        //para confirmar que quiere hacer la accion, si es la accion de ver sus cartas reservadas o para salir de la partida no hace falta confirmar
        int election = 0;
        if(eleccion != 7 && eleccion != 8) {
            System.out.println("Estas seguro que quieres hacer la elección " + eleccion + "?");
            System.out.println("-1 si no quieres realizar la accion, cualquier tecla para seguir....");
            try {
                election = sc.nextInt();
            } catch (Exception e) {
                sc.next();
            }
        }

        //cogemos las cartas del tablero.
        List<Carta> c1 = new ArrayList<>(partida.getTablero().getCartaslvl1());
        List<Carta> c2 = new ArrayList<>(partida.getTablero().getCartaslvl2());
        List<Carta> c3 = new ArrayList<>(partida.getTablero().getCartaslvl3());

        //comprobamos que el jugador quiere hacer la accion
        if(jugador != null && election != -1) {
            if (eleccion == 1) {
                String gema = "";
                do {
                    //Mientras no nos de una gema valida le volveremos a preguntar
                    try {
                        System.out.println("Que gema quieres coger, Blue, White, Red, Black, Green: ");
                        gema = sc.next();
                    } catch (Exception e) {
                        System.out.println("Elección errónea");
                    }
                } while (!existeGema(gema));
                //ejecutamos la accion
                jugador.accTake2g(partida.getIdPartida(), Color.valueOf(gema.toUpperCase()), connection);
            } else if (eleccion == 2) {
                String gema1 = "", gema2 = "", gema3 = "";
                do {
                    //Mientras no nos de una gema valida le volveremos a preguntar
                    try {
                        System.out.println("Elige las gemas: ");
                        System.out.println("Que gema quieres coger, Blue, White, Red, Black, Green:");
                        gema1 = sc.next();
                        System.out.println("Que gema quieres coger, Blue, White, Red, Black, Green:");
                        gema2 = sc.next();
                        System.out.println("Que gema quieres coger, Blue, White, Red, Black, Green:");
                        gema3 = sc.next();
                    } catch (Exception e) {
                        System.out.println("Elección errónea");
                    }
                } while (!existeGema(gema1) || !existeGema(gema2) || !existeGema(gema3));
                //ejecutamos la accion
                jugador.accTake3g(partida.getIdPartida(), Color.valueOf(gema1.toUpperCase()), Color.valueOf(gema2.toUpperCase()), Color.valueOf(gema3.toUpperCase()), connection);
            } else if (eleccion == 3) {//cogemos la posición de la carta.
                int pos = getPosicionCarta(sc, c1, c2, c3);
                //Dependiendo la posición de la carta será de un nivel u otro, por eso deberemos coger-la de la lista que toca.
                String carta;
                carta = getCarta(pos, c1, c2, c3);
                jugador.accHold(partida.getIdPartida(), carta, connection);
            } else if (eleccion == 4) {
                byte nivel = -1;
                while (nivel < 1 || nivel > 3) {
                    try {
                        System.out.println("De que nivel quieres la carta: ");
                        nivel = sc.nextByte();
                    } catch (Exception e) {
                        System.out.println("Elección errónea");
                        sc.next();
                    }
                }
                jugador.accBlindHold(partida.getIdPartida(), nivel, connection);
            } else if (eleccion == 5) {
                int ele = 0;
                do {
                    try {
                        System.out.println("1. Para una carta de tu mano. ");
                        System.out.println("2. Para una carta de la mesa. ");
                        ele = sc.nextInt();
                    } catch (Exception e) {
                        System.out.println("Elección errónea");
                        sc.next();
                    }
                } while (ele < 1 || ele > 2);
                String carta = "";
                //para comprar de la mano o del tablero
                if (ele == 1) {
                    System.out.println("Elige: ");
                    //le mostramos las cartas que tiene reservadas para que elija alguna
                    for (Carta c : jugador.getMano()) {
                        if (c.isReservada()) {
                            System.out.print(c.getId() + ", ");
                        }
                    }
                    System.out.println();
                    try {
                        carta = sc.next();
                    } catch (Exception e) {
                        System.out.println("Elección errónea");
                    }
                } else {
                    //comprar una carta del tablero
                    int pos = getPosicionCarta(sc, c1, c2, c3);
                    //cogemos el ID de la carta de la posición que nos ha pedido el jugador.
                    carta = getCarta(pos, c1, c2, c3);
                }
                jugador.accBuy(partida.getIdPartida(), carta, connection);
            } else if (eleccion == 6) {
                System.out.println("Accion pasar");
                jugador.accPass(partida.getIdPartida(), connection);
            } else if (eleccion == 7) {
                //mostramos las cartas que tiene reservadas
                Set<Carta> cartas = new HashSet<>();
                for (Carta c : jugador.getMano()) {
                    if (c.isReservada()) {
                        cartas.add(c);
                    }
                }
                pintarCartas(cartas);
            }
        }
    }

    //posicion de la carta en las listas.
    private static int getPosicionCarta(Scanner sc, List<Carta> c1, List<Carta> c2, List<Carta> c3) {
        //mientras la eleccion sea menor que 1, o la eleccion sea mayor que la suma de todas las cartas del tablero, seguiremos pidiendo una posición
        int pos = -1;
        while (pos < 1 || pos > (c1.size() + c2.size() + c3.size())) {
            try {
                System.out.println("Posición del tablero de la carta: ");
                pos = sc.nextInt();
            } catch (Exception e) {
                System.out.println("Elección errónea");
                sc.next();
            }
        }
        return pos;
    }

    //función para saber que carta escoge el jugador del tablero.
    private static String getCarta(int pos, List<Carta> c1, List<Carta> c2, List<Carta> c3) {
        String carta;
        if (pos <= c1.size()) {
            carta = c1.get(pos - 1).getId();
        } else if (pos <= (c1.size() + c2.size())) {
            //aquí nos aseguramos de que la posición sea correcta, ya que en la lista solo tenemos 4 posiciones.
            pos -= c1.size();
            carta = c2.get(pos - 1).getId();
        } else {
            //aquí nos aseguramos de que la posición sea correcta, ya que en la lista solo tenemos 4 posiciones.
            pos -= (c1.size() + c2.size());
            carta = c3.get(pos - 1).getId();
        }
        return carta;
    }


    private static void eleccion(){
        System.out.println("Que elección quieres hacer: ");
        System.out.println("1. Coger 2 gemas");
        System.out.println("2. Coger 3 gemas");
        System.out.println("3. Reservar una carta del tablero");
        System.out.println("4. Reservar una carta a ciegas");
        System.out.println("5. Comprar una carta");
        System.out.println("6. Pasar");
        System.out.println("7. Ver tus cartas reservadas");
        System.out.println("8. Salir de la partida");
    }

    private static void pintarTablero(Partida partida, Connection connection) throws SQLException {
        System.out.println("-------------------------------------------------------------------");
        System.out.println("Tablero");
        System.out.println("Nobles: ");
        partida.actualizarNobles(connection);
        pintarCartas(partida.getNobles());
        System.out.println();

        //actualizamos el tablero
        partida.getTablero().actualizarTablero(partida.getIdPartida(), partida.getDarreraAccio(connection, false), partida.getDarreraAccio(connection, true), connection);
        System.out.println("Cartas: ");
        System.out.println("Nivel 1: ");
        pintarCartas(partida.getTablero().getCartaslvl1());
        System.out.println();
        System.out.println("Nivel 2:");
        pintarCartas(partida.getTablero().getCartaslvl2());
        System.out.println();
        System.out.println("Nivel 3:");
        pintarCartas(partida.getTablero().getCartaslvl3());

        //mostramos las gemas
        System.out.println();
        pintarGemas(partida, connection);
        System.out.println();
        System.out.println("-------------------------------------------------------------------");
    }

    //para mirar si el ID del jugador que nos pasa existe
    private static int asignarId(Scanner sc, Connection connection, Jugador jugador, int id) throws SQLException {
        while (!existeElJugador(connection, id) && id != jugador.getId()) {
            try {
                System.out.println("Id erróneo");
                System.out.println("Introduce un Id: ");
                id = sc.nextInt();
            }catch (Exception E){
                System.out.println("Elección errónea");
                sc.next();
            }
        }
        return id;
    }

    private static void mostrarJugadores(Connection connection) throws SQLException {
        System.out.println("Lista de jugadores y sus puntos:");

        String sql = "SELECT nombre, rango from jugador order by rango desc";
        Statement s = connection.createStatement();
        ResultSet result = s.executeQuery(sql);

        while (result.next()) {
            String nombre = result.getString(1);
            int rango = result.getInt(2);
            System.out.println("Nombre: " + nombre + " rango: " + rango);
        }
    }

    private static void crearPartida(Connection connection, Jugador jugador) throws SQLException {
        Scanner sc = new Scanner(System.in);
        int numJug = 0, puntosPartida = 0;

        //las partidas tienen que ser mínimo de 2 jugadores máximo de 4
        do {
            try {
                System.out.println("De cuantos jugadores sera la partida? (Máximo 4, mínimo 2)");
                numJug = sc.nextInt();
            } catch (Exception e) {
                System.out.println("Elección errónea");
                sc.next();
            }
        } while (numJug < 2 || numJug > 4);

        do {
            try {
                System.out.println("La partida sera de 15 o 20 puntos?");
                puntosPartida = sc.nextInt();
            } catch (Exception e) {
                System.out.println("Elección errónea");
                sc.next();
            }
        } while (puntosPartida != 15 && puntosPartida != 20);

        //iniciamos la lista de los ids que jugaran la partida
        int id2 = -1, id3 = -1, id4 = -1;
        List<Jugador> ids = new ArrayList<>();
        ids.add(jugador);

        //Según la cantidad de jugadores que haya elegido el jugador, crearemos la partida con más jugadores o menos.
        switch (numJug) {
            case 4:
                try {
                    System.out.println("Introduce un Id: ");
                    id4 = sc.nextInt();
                } catch (Exception E) {
                    System.out.println("Elección errónea");
                    sc.next();
                }
                //verificamos que existe el ID de jugador que nos ha introducido y que no sea el mismo id que el suyo
                id4 = asignarId(sc, connection, jugador, id4);
                //creamos el nuevo jugador y lo añadimos a la lista de ids
                Jugador j4 = new Jugador(id4, connection);
                ids.add(j4);
            case 3:
                try {
                    System.out.println("Introduce un Id: ");
                    id3 = sc.nextInt();
                } catch (Exception E) {
                    System.out.println("Elección errónea");
                    sc.next();
                }
                id3 = asignarId(sc, connection, jugador, id3);
                Jugador j3 = new Jugador(id3, connection);
                ids.add(j3);

            case 2:
                try {
                    System.out.println("Introduce un Id: ");
                    id2 = sc.nextInt();
                } catch (Exception E) {
                    System.out.println("Elección errónea");
                    sc.next();
                }
                id2 = asignarId(sc, connection, jugador, id2);
                Jugador j2 = new Jugador(id2, connection);
                ids.add(j2);
        }
        // creamos la partida nueva.
        Partida partida = new Partida(puntosPartida, ids, connection);
        System.out.println("Partida " + partida.getIdPartida() + " creada");
    }

    public static Partida unirsePartida(Connection connection, Jugador jugador) throws SQLException {
        Scanner sc = new Scanner(System.in);
        //unirse a una partida----------------------------
        int idPartida = -1;
        //Comprobamos que la partida existe y que el jugador esté en esa partida
        while (!existePartida(idPartida, jugador.getId(), connection)) {
            try {
                System.out.println("Partidas que puedes unirte: ");
                //mostramos las partidas a las que se puede unir
                System.out.println(getPartidas(connection, jugador));
                idPartida = sc.nextInt();
            } catch (Exception e) {
                System.out.println("Elección errónea");
                sc.next();
            }
        }
        //creamos la partida
        return new Partida(idPartida, connection);
    }

    private static void jugarPartida(Connection connection, Jugador jugador, Partida partida) throws SQLException {
        Scanner sc = new Scanner(System.in);
        int turnoActual;
        int idJugActual;
        int idNext;

        //Miramos si la partida aún sigue en juego
        String game = "SELECT gameIsOver(" + partida.getIdPartida() + ")";
        Statement s = connection.createStatement();
        ResultSet rs = s.executeQuery(game);
        rs.next();
        int gameOver = rs.getInt(1);

        //Mientras game over sea menor o igual a 0 seguiremos la partida, ya que gameOver adoptara el ID del jugador ganador cuando acabe la partida. (el cual no puede ser 0)
        //PARTIDA--------------------------------------------------
        int eleccion = -1;
        while (gameOver <= 0) {
            //salir de la partida actual
            if (eleccion == 8) {
                break;
            }
            //haremos esperar al jugador asta que llegue su turno.
            System.out.println("Esperando a tu turno.....");
            do {
                //comprobamos que el ID del próximo jugador sea el mismo que el del jugador, para asi poder dejarlo jugar
                turnoActual = partida.getDarreraAccio(connection, false);
                idJugActual = partida.getDarreraAccio(connection, true);
                idNext = partida.getAccioSeguent(connection, idJugActual, turnoActual);
            } while (idNext != jugador.getId());

            //miramos si se ha acabado la partida.
            rs = s.executeQuery(game);
            rs.next();
            gameOver = rs.getInt(1);
            //si se ha acabado salimos del juego
            if (gameOver <= 0) {

                System.out.println("Es tu turno" + "\n");


                //mientras el turno sea el mismo significa que el jugador no ha realizado una acción válida, con lo cual seguirá siendo su turno.
                while (jugador.getId() == idNext) {
                    //salir de la partida actual
                    if (eleccion == 8) {
                        break;
                    }
                    //Actualizamos la mano del jugador
                    jugador.actualizarMano(connection);

                    //mostramos toda la información de la partida
                    pintarTablero(partida, connection);


                    //mostramos las cartas de los jugadores y sus gemas
                    for (Jugador j : partida.getJugadores()) {
                        System.out.println("Cartas del jugador: " + j.getNombre());
                        System.out.println();
                        //actualizamos la puntuación del jugador
                        j.actualizarPuntuacion(connection);
                        System.out.println("Puntuación : " + j.getPuntuacion());
                        System.out.println();
                        //creamos una lista para las cartas reservadas y otra para las compradas
                        Set<Carta> reservadas = new LinkedHashSet<>();
                        Set<Carta> noReservada = new LinkedHashSet<>();
                        //actualizamos la mano del jugador
                        j.actualizarMano(connection);
                        System.out.println("Gemas: ");
                        PintarColor pc = new PintarColor();
                        //mostramos las gemas del jugador
                        System.out.print(pc.amarillo + "Doradas: " + pc.b + j.getGemas(connection, Color.GOLD) + "  ");
                        System.out.print(pc.magenta + "Negras: " + pc.b + j.getGemas(connection, Color.BLACK) + "  ");
                        System.out.print(pc.rojo + "Rojas: " + pc.b + j.getGemas(connection, Color.RED) + "  ");
                        System.out.print(pc.verde + "Verdes: " + pc.b + j.getGemas(connection, Color.GREEN) + "  ");
                        System.out.print(pc.azul + "Azules: " + pc.b + j.getGemas(connection, Color.BLUE) + "  ");
                        System.out.print("Blancas: " + j.getGemas(connection, Color.WHITE) + "  ");
                        System.out.println();
                        System.out.println();
                        int countAzul = 0, countRoja = 0, countNegra = 0, countVerde = 0, countBlanca = 0;
                        for (Carta c : j.getMano()) {
                            if (c.isReservada()) {
                                reservadas.add(c);
                            } else {
                                noReservada.add(c);
                                switch (c.getColor()){
                                    case GREEN -> countVerde++;
                                    case BLACK -> countNegra++;
                                    case RED -> countRoja++;
                                    case BLUE -> countAzul++;
                                    case WHITE -> countBlanca++;
                                }
                            }
                        }
                        System.out.println("Cartas: ");
                        pintarCartaReservada(reservadas);
                        System.out.println();
                        pintarCartas(noReservada);
                        System.out.println();

                        //Mostramos el total de poder de cartas del jugador por cada color
                        System.out.println();
                        System.out.println("Total de color de cartas: ");
                        System.out.print(pc.magenta + "Negras: " + pc.b + countNegra + "  ");
                        System.out.print(pc.rojo + "Rojas: " + pc.b + countRoja + "  ");
                        System.out.print(pc.verde + "Verdes: " + pc.b + countVerde + "  ");
                        System.out.print(pc.azul + "Azules: " + pc.b + countAzul + "  ");
                        System.out.print("Blancas: " + countBlanca + "  ");
                        System.out.println();
                        System.out.println();

                        //mostramos los nobles del jugador
                        j.actualizarNobles(connection);
                        System.out.println("Nobles: ");
                        pintarCartas(j.getManoNoble());
                        System.out.println();
                        System.out.println("-------------------------------------------------------------------");
                    }

                    //pedimos que accion quiere hacer
                    do {
                        try {
                            eleccion();
                            eleccion = sc.nextInt();
                        } catch (Exception e) {
                            System.out.println("Elección errónea");
                            sc.next();
                        }
                    } while (eleccion <= 0 || eleccion >= 9);

                    //mientras el jugador quiera ver sus cartas reservadas no volveremos a mostrar el tablero.
                    while (eleccion == 7) {
                        //ejecutamos la accion
                        eleccion(eleccion, connection, partida, jugador);
                        System.out.println();

                        try {
                            eleccion();
                            eleccion = sc.nextInt();
                        } catch (Exception e) {
                            System.out.println("Elección errónea");
                            sc.next();
                        }
                    }

                    //ejecutamos la accion
                    eleccion(eleccion, connection, partida, jugador);

                    //miramos cuál es el siguiente jugador.
                    turnoActual = partida.getDarreraAccio(connection, false);
                    idJugActual = partida.getDarreraAccio(connection, true);
                    idNext = partida.getAccioSeguent(connection, idJugActual, turnoActual);
                }

                //miramos si se ha acabado la partida.
                rs = s.executeQuery(game);
                rs.next();
                gameOver = rs.getInt(1);

                //si la partida ha acabado le sumara 50 puntos al jugador ganador.
                String addPoints = "SELECT addPuntos(" + partida.getIdPartida() + ")";
                rs = s.executeQuery(addPoints);
                rs.next();
            }
        }
        if(gameOver == jugador.getId()){
            System.out.println(
                    """
                            ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
                            ██ ███ █▄ ▄██ ▀██ ██
                            ██ █ █ ██ ███ █ █ ██
                            ██▄▀▄▀▄█▀ ▀██ ██▄ ██""");
        } else if (gameOver > 0  && gameOver != jugador.getId()){
            System.out.println(
                    """
                            ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
                            ██ ▄▄ █ ▄▄▀██ ▄▀▄ ██ ▄▄▄████ ▄▄▄ ██ ███ ██ ▄▄▄██ ▄▄▀██
                            ██ █▀▀█ ▀▀ ██ █ █ ██ ▄▄▄████ ███ ███ █ ███ ▄▄▄██ ▀▀▄██
                            ██ ▀▀▄█ ██ ██ ███ ██ ▀▀▀████ ▀▀▀ ███▄▀▄███ ▀▀▀██ ██ ██
                            ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀""");
        }
    }

    private static void juego(Connection connection, Jugador jugador, int eleccionJuego) throws SQLException {

        //si la elección es 4 simplemente salimos del programa
        while (eleccionJuego != 4) {
            if (eleccionJuego == 1) {
                //mostramos los jugadores y sus puntos
                mostrarJugadores(connection);
            } else if (eleccionJuego == 2) {
                //Creamos una partida----------------------------------------------
                crearPartida(connection, jugador);
            } else {
                //Creamos la partida, y luego se la asignamos al jugador
                Partida partida = unirsePartida(connection, jugador);
                jugador.setPartidaActual(partida);
                //jugamos la partida.
                jugarPartida(connection,jugador,partida);
            }
            //volvemos a pedir al usuario que accion quiere realizar.
            eleccionJuego = eleccionJuego();
        }

    }

    private static Jugador inicioSesion(Connection connection) throws SQLException {
        Scanner sc = new Scanner(System.in);
        //Inicio de sesión.
        Jugador jugador = null;
        //Mientras el usuario no introduzca un usuario y contraseña válidos se los seguiremos preguntando,
        System.out.println("Bienvenido a : ");
        System.out.println(
                """
                        ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
                        ░░░      ░░░░░░░░░░░░   ░░░░░░░░░░░░░░░░░░░░░░░░░░░   ░░░░░░░░░░░░░░░░░░░░
                        ▒   ▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
                        ▒▒   ▒▒▒▒▒▒▒  ▒   ▒▒▒   ▒▒▒▒   ▒▒▒▒▒   ▒   ▒▒▒▒▒▒▒▒   ▒▒▒▒▒   ▒▒▒▒▒  ▒
                        ▓▓▓▓   ▓▓▓▓▓  ▓▓   ▓▓   ▓▓  ▓▓▓   ▓▓▓   ▓▓   ▓▓   ▓   ▓▓▓   ▓▓   ▓▓▓   ▓▓▓
                        ▓▓▓▓▓▓▓   ▓▓  ▓▓▓   ▓   ▓         ▓▓▓   ▓▓   ▓  ▓▓▓   ▓▓   ▓▓▓▓   ▓▓   ▓▓▓
                        ▓   ▓▓▓▓   ▓   ▓   ▓▓   ▓  ▓▓▓▓▓▓▓▓▓▓   ▓▓   ▓  ▓▓▓   ▓▓▓   ▓▓   ▓▓▓   ▓▓▓
                        ███      ███   ██████   ███     ████    ██   ██   █   █████   █████    ███
                        ████████████   ███████████████████████████████████████████████████████████""");

        String usuario = "", contrasenya = "";
        while (jugador == null) {

            try {
                System.out.println("Con que usuario vas a jugar: ");
                usuario = sc.next();
                System.out.println("Contraseña para " + usuario);
                contrasenya = sc.next();
            } catch (Exception e){
                System.out.println("Elección errónea");
            }

            //comprobamos si el usuario del jugador existe
            String comprobarId = "SELECT idjugador FROM jugador WHERE nombre = '" + usuario + "' AND contrasenya = SHA1( '" + contrasenya + "')";
            ResultSet existeId = null;
            try {
                Statement s = connection.createStatement();
                existeId = s.executeQuery(comprobarId);
            } catch (Exception e){
                System.out.println("Valores erroneous");
            }

            //cogemos el ID del usuario y creamos un nuevo jugador si existe.
            if(existeId != null) {
                if (existeId.next()) {
                    jugador = new Jugador(existeId.getInt("idjugador"), connection);
                }
            }
        }
        return jugador;
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        String ip = "localhost";
        try {
            System.out.println("A que ip te vas a conectar, por ejemplo localhost o otra ip (usa ipconfig en el terminal de windows para saber tu ip)");
            ip = sc.next();
        } catch (Exception e){
            System.out.println("Valor erróneo");
        }

        String url = "jdbc:mysql://" + ip + ":3306/splendor2";
        String user = "root";
        String password = "";

        try {
            // Establecer la conexión con la base de datos
            Connection connection = DriverManager.getConnection(url, user, password);

            //inicio de sesión para crear el objeto de jugador
            Jugador jugador = inicioSesion(connection);

            //Funcion que tiene toda la accion del juego
            juego(connection, jugador, eleccionJuego());

            //cuando salga de la función juego habra salido del programa
            System.out.println("ADIOS!");

            // Cerrar la conexión
            connection.close();

        } catch (SQLException e) {
            System.out.println("ERROR");
            System.out.println(e.getMessage());
        }
    }
}