package compilador;

import java.io.PrintWriter;
import java.util.*;

/**
 * TablaSimbolos - Guarda TODOS los tokens encontrados por el scanner y los distribuye en 4 tablas.
 *
 * OBJETIVO : cumplir los puntos (b) y (c) del proyecto: archivo de tokens (token + lexema) e
 *            indicar en que tabla de simbolos va cada token y que informacion se almacena.
 * ENTRADA  : llamadas a registrar(...) desde el scanner (una por cada token reconocido).
 * SALIDA   : escribirTokens(...) y escribirTablas(...) con los reportes en texto.
 *
 * TABLAS (y la informacion que guarda cada una):
 *  1. RESERVADAS     : palabras reservadas (val, int, if, ...)
 *                      guarda: lexema, token, ocurrencias, lineas donde aparece.
 *  2. IDENTIFICADORES: nombres de variables y funciones.
 *                      guarda: lexema, primera linea, ocurrencias, lineas. (El tipo de dato y el
 *                      ambito se completan en la fase semantica, no en el scanner.)
 *  3. LITERALES      : constantes enteras, flotantes, caracteres y cadenas.
 *                      guarda: lexema (valor), tipo de literal (token), ocurrencias, lineas.
 *  4. OPERADORES     : operadores y simbolos especiales (+, <=, lambda, bloques, indices, ...).
 *                      guarda: lexema, token, ocurrencias, lineas.
 */
public class TablaSimbolos {

    /** Las cuatro tablas disponibles. */
    public enum Tipo {
        RESERVADAS("TABLA DE PALABRAS RESERVADAS", "lexema, token, ocurrencias, lineas"),
        IDENTIFICADORES("TABLA DE IDENTIFICADORES", "lexema, primera linea, ocurrencias, lineas (tipo/ambito: fase semantica)"),
        LITERALES("TABLA DE LITERALES", "lexema (valor), tipo de literal, ocurrencias, lineas"),
        OPERADORES("TABLA DE OPERADORES Y SIMBOLOS", "lexema, token, ocurrencias, lineas");

        public final String titulo, informacion;
        Tipo(String titulo, String informacion) { this.titulo = titulo; this.informacion = informacion; }
    }

    /** Una fila de una tabla de simbolos (un lexema distinto). */
    public static class Entrada {
        public final String lexema, token;
        public final int primeraLinea;
        public int ocurrencias = 0;
        public final TreeSet<Integer> lineas = new TreeSet<>();
        Entrada(String lexema, String token, int linea) { this.lexema = lexema; this.token = token; this.primeraLinea = linea; }
    }

    /** Un token tal como aparece en el codigo fuente (para el archivo de tokens). */
    public static class Registro {
        public final int linea, columna;
        public final String token, lexema;
        public final Tipo tabla;
        Registro(int l, int c, String t, String lx, Tipo tb) { linea = l; columna = c; token = t; lexema = lx; tabla = tb; }
    }

    private final Map<Tipo, LinkedHashMap<String, Entrada>> tablas = new EnumMap<>(Tipo.class);
    private final List<Registro> tokens = new ArrayList<>();

    public TablaSimbolos() { for (Tipo t : Tipo.values()) tablas.put(t, new LinkedHashMap<>()); }

    /** Registra un token en la lista general y en la tabla indicada. */
    public void registrar(Tipo tabla, String token, String lexema, int linea, int columna) {
        tokens.add(new Registro(linea, columna, token, lexema, tabla));
        Entrada e = tablas.get(tabla).computeIfAbsent(lexema, k -> new Entrada(lexema, token, linea));
        e.ocurrencias++;
        e.lineas.add(linea);
    }

    public List<Registro> getTokens() { return tokens; }
    public Map<Tipo, LinkedHashMap<String, Entrada>> getTablas() { return tablas; }

    /** Archivo de tokens: una linea por token (linea:columna, token, lexema, tabla). */
    public void escribirTokens(PrintWriter out) {
        out.println("LINEA:COL\tTOKEN\tLEXEMA\tTABLA DE SIMBOLOS");
        for (Registro r : tokens)
            out.println(r.linea + ":" + r.columna + "\t" + r.token + "\t" + r.lexema + "\t" + r.tabla.name());
        out.println();
        out.println("Total de tokens: " + tokens.size());
    }

    /** Reporte de las cuatro tablas. */
    public void escribirTablas(PrintWriter out) {
        for (Tipo t : Tipo.values()) {
            out.println("==== " + t.titulo + " ====");
            out.println("Informacion almacenada: " + t.informacion);
            for (Entrada e : tablas.get(t).values()) {
                String col = (t == Tipo.IDENTIFICADORES) ? "primera linea " + e.primeraLinea : "token " + e.token;
                out.println("  " + e.lexema + "\t| " + col + " | ocurrencias " + e.ocurrencias + " | lineas " + e.lineas);
            }
            out.println();
        }
    }
}
