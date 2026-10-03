package compilador;

import java.io.*;
import java.nio.charset.StandardCharsets;

public class Main {
    public static void main(String[] args) {
        String archivoFuente = (args.length > 0) ? args[0] : "prueba.txt";

        System.out.println("==================================================");
        System.out.println("                  compilador                      ");
        System.out.println("==================================================");
        System.out.println("Archivo a analizar: " + archivoFuente);

        try {
            // 1. Instancia analizador léxico
            Reader lector = new InputStreamReader(new FileInputStream(archivoFuente), StandardCharsets.UTF_8);
            Lexer scanner = new Lexer(lector);

            // 2. Instancia analizador sintáctico
            parser sintactico = new parser(scanner);

            // 3. Ejecuta análisis sintáctico
            sintactico.parse();

            System.out.println("\n==================================================");
            System.out.println(" res: bien");
            System.out.println(" cumple gramatica");
            System.out.println("==================================================");

        } catch (Exception e) {
            System.err.println("\n==================================================");
            System.err.println(" res: nel, ta malo");
            System.err.println(" Revisa reportes de recuperacion");
            System.err.println("==================================================");
            e.printStackTrace();
        }
    }
}