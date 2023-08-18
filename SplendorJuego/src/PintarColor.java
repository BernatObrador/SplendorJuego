public class PintarColor {
    String b = "\u001B[0m"; //borrar
    String negro = "\u001B[30m";
    String rojo = "\033[31m";
    String verde = "\033[32m";
    String amarillo = "\033[33m";
    String azul = "\033[34m";
    String magenta = "\033[35m";
    String celeste = "\033[36m";
    String blanco = "\033[37m";

    String fRojo = "\033[41m";
    String fVerde = "\033[42m";
    String fAmarillo = "\033[43m";
    String fAzul = "\033[44m";
    String fMagenta = "\033[45m";
    String fCeleste = "\033[46m";
    String fGris = "\033[47m";

    public String elegirColor(String c){
        PintarColor p = new PintarColor();
        switch (c){
            case "N" -> c = p.magenta + c;
            case "G" -> c = p.verde + c;
            case "B" -> c = p.azul + c;
            case "W" -> c = p.blanco + c;
            case "R" -> c = p.rojo + c;
        }
        return c;
    }

}
