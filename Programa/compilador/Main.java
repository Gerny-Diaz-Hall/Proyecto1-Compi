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

            // validacion sintactica (modo panico: reporta y continua)
            try {
                sintactico.parse();
            } catch (Exception e) {
                // error irrecuperable: ya quedo registrado en erroresSintacticos
            }

            List<String> erroresSintacticos = sintactico.erroresSintacticos;
            escribir(salida + "/errores_sintacticos.txt", pw -> {
                if (erroresSintacticos.isEmpty()) pw.println("Sin errores sintacticos.");
                for (String e : erroresSintacticos) pw.println(e);
            });
            System.out.println("  - errores_sintacticos.txt");

            boolean valido = erroresLexicos.isEmpty() && erroresSintacticos.isEmpty();
            System.out.println("\n==================================================");
            System.out.println(valido
                ? " Resultado: el archivo SI puede ser generado por la gramatica"
                : " Resultado: el archivo NO puede ser generado por la gramatica ("
                  + erroresLexicos.size() + " lexicos, " + erroresSintacticos.size() + " sintacticos)");
            System.out.println("==================================================");

        } catch (Exception e) {
            System.err.println("Error al procesar el archivo: " + e.getMessage());
        }
    }

    private static void escribir(String ruta, java.util.function.Consumer<PrintWriter> c) throws IOException {
        try (PrintWriter pw = new PrintWriter(new OutputStreamWriter(new FileOutputStream(ruta), StandardCharsets.UTF_8))) { 
            c.accept(pw); 
        }
    }
}