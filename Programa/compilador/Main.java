package compilador;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.List;

public class Main {
    public static void main(String[] args) {
        if (args.length < 1) {
            System.err.println("Uso: java compilador.Main <archivo_fuente> [carpeta_salida]");
            return;
        }

        String archivoFuente = args[0];
        String salida = args.length > 1 ? args[1] : ".";
        new File(salida).mkdirs();

        System.out.println("==================================================");
        System.out.println("            Compilador proye 1                    ");
        System.out.println("==================================================");
        System.out.println("Analizando: " + archivoFuente);

        try {
            // ==========================================================
            // analisis lexico, generar archivos
            // ==========================================================
            Lexer lexerTokens;
            try (Reader in = new InputStreamReader(new FileInputStream(archivoFuente), StandardCharsets.UTF_8)) {
                lexerTokens = new Lexer(in);
                while (lexerTokens.next_token().sym != sym.EOF) { 
                }
            }

            // Escribe reportes
            escribir(salida + "/tokens.txt", lexerTokens.getTablaSimbolos()::escribirTokens);
            escribir(salida + "/tablas_simbolos.txt", lexerTokens.getTablaSimbolos()::escribirTablas);
            
            List<String> erroresLexicos = lexerTokens.getErrores();
            escribir(salida + "/errores_lexicos.txt", pw -> {
                if (erroresLexicos.isEmpty()) pw.println("Sin errores lexicos.");
                for (String e : erroresLexicos) pw.println(e);
            });

            System.out.println("\nReportes léxicos generados:");
            System.out.println("  - tokens.txt");
            System.out.println("  - tablas_simbolos.txt");
            System.out.println("  - errores_lexicos.txt");

            // ==========================================================
            // analisis sintaxis, gramatica
            // ==========================================================
            
            Reader lectorParser = new InputStreamReader(new FileInputStream(archivoFuente), StandardCharsets.UTF_8);
            Lexer scannerParser = new Lexer(lectorParser);
            parser sintactico = new parser(scannerParser);

            // validacion sintactica
            sintactico.parse();

            System.out.println("\n==================================================");
            System.out.println(" Resultado: puede ser generado ");
            System.out.println("==================================================");

        } catch (Exception e) {
            System.err.println("\n==================================================");
            System.err.println(" Resultado: archivo tiene errores.");
            System.err.println(" revisar consola o reportes ");
            System.err.println("==================================================");
        }
    }

    private static void escribir(String ruta, java.util.function.Consumer<PrintWriter> c) throws IOException {
        try (PrintWriter pw = new PrintWriter(new OutputStreamWriter(new FileOutputStream(ruta), StandardCharsets.UTF_8))) { 
            c.accept(pw); 
        }
    }
}