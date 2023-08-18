
public class Carta implements Row{
    private final String id;
    private boolean reservada;
    private Color color;
    private final String topRow = "╔═════════════╗  ";
    private String topIdRow;
    private final String midRow = "║             ║  ";
    private String bottomIdRow = "║ ";
    private final String bottomRow = "╚═════════════╝  ";

    public Carta(String idCarta) {
        PintarColor p = new PintarColor();
        this.id = idCarta;
        int countColor = 0;
        this.color = getColorCarta(idCarta.charAt(1));
        int numeroDeColores = (this.id.length() - 2) / 2;
        String c = p.elegirColor(String.valueOf(idCarta.charAt(1)));
        //le asignamos la fila topId a la carta, cogiendo los 2 primeros caracteres de su id, los cuales son la puntuación y el color de la carta.
        this.topIdRow = "║ " + idCarta.charAt(0) + "         " + c + p.b+ " ║  ";


        for (int j = 0, x = 2; j < numeroDeColores; j++, x += 2) {
            String coste = idCarta.charAt(x) + p.elegirColor(String.valueOf(idCarta.charAt(x + 1))) + p.b;
            countColor += 9;
            bottomIdRow += coste + " ";
        }
        for (int i = bottomIdRow.length(); i < 14 + countColor; i++) {
            bottomIdRow += " ";
        }

        bottomIdRow += "║  ";

    }

    //para crear una carta que puede estar reservada
    public Carta(String idCarta, boolean reservada) {
        PintarColor p = new PintarColor();
        this.reservada = reservada;
        this.id = idCarta;
        //le asignamos el color
        this.color = getColorCarta(idCarta.charAt(1));
        int countColor = 0;
        int numeroDeColores = (this.id.length() - 2) / 2;
        String c = p.elegirColor(String.valueOf(idCarta.charAt(1)));
        //le asignamos la fila topId a la carta, cogiendo los 2 primeros caracteres de su id, los cuales son la puntuación y el color de la carta.
        this.topIdRow = "║ " + idCarta.charAt(0) + "         " + c + p.b+ " ║  ";


        for (int j = 0, x = 2; j < numeroDeColores; j++, x += 2) {
            String coste =idCarta.charAt(x) + p.elegirColor(String.valueOf(idCarta.charAt(x + 1))) + p.b;
            countColor += 9;
            bottomIdRow += coste + " ";
        }
        for (int i = bottomIdRow.length(); i < 14 + countColor; i++) {
            bottomIdRow += " ";
        }

        bottomIdRow += "║  ";

    }

    private Color getColorCarta(char c){
        if(c == 'N'){
            return Color.BLACK;
        } else if(c == 'B'){
            return Color.BLUE;
        } else if(c == 'W'){
            return Color.WHITE;
        } else if (c == 'R'){
            return Color.RED;
        } else {
            return Color.GREEN;
        }
    }

    public Color getColor() {
        return color;
    }

    public String getId() {
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

    public boolean isReservada() {
        return reservada;
    }

    @Override
    public String toString() {
        return id + ", ";
    }
}