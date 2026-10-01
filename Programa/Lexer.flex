package compilador;
import java_cup.runtime.*; // Necesario para interactuar con CUP

%%

%class Lexer
%unicode
%cup
%line
%column
%public

/* Expresiones regulares básicas */
Digito = [0-9]
/* Investigando, a lo que entendi se tiene que poner [a-zA-Z]
Porque si se pone [a-z][A-Z] el programa va a entender que obligatoriamente
va una letra minúscula y el segundo obligatoriamente mayúscula
Por eso el [a-zA-Z]*/
Letra = [a-zA-Z]
Entero = {Digito}+

Flotante = {Entero}\.{Entero}
Identificador = {Letra} ({Letra} | {Digito} | "_")*
Espacio = [ \t\r\n]+

/* Comentarios de una y múltiples líneas */
ComentarioLinea = "~" [^\r\n]*

ComentarioMulti = "i~" ~"~!"

%%

/* 1. Ignorar espacios y comentarios */
{Espacio}         { /* Ignorar */ }
{ComentarioLinea} { /* Ignorar */ }
{ComentarioMulti} { /* Ignorar */ }

/* 2. Palabras reservadas */
"val"     { return new Symbol(sym.VAL, yyline, yycolumn, yytext()); }
"if"      { return new Symbol(sym.IF, yyline, yycolumn, yytext()); }
"elif"    { return new Symbol(sym.ELIF, yyline, yycolumn, yytext()); }
"else"    { return new Symbol(sym.ELSE, yyline, yycolumn, yytext()); }
"while"   { return new Symbol(sym.WHILE, yyline, yycolumn, yytext()); }
"for"     { return new Symbol(sym.FOR, yyline, yycolumn, yytext()); }
"read"    { return new Symbol(sym.READ, yyline, yycolumn, yytext()); }
"write"   { return new Symbol(sym.WRITE, yyline, yycolumn, yytext()); }
"return"  { return new Symbol(sym.RETURN, yyline, yycolumn, yytext()); }
"break"   { return new Symbol(sym.BREAK, yyline, yycolumn, yytext()); }
"main"    { return new Symbol(sym.MAIN, yyline, yycolumn, yytext()); }
"void"    { return new Symbol(sym.VOID, yyline, yycolumn, yytext()); }

/* 3. Tipos de datos y booleanos */
"int"     { return new Symbol(sym.INT, yyline, yycolumn, yytext()); }
"float"   { return new Symbol(sym.FLOAT, yyline, yycolumn, yytext()); }
"boolean" { return new Symbol(sym.BOOLEAN, yyline, yycolumn, yytext()); }
"char"    { return new Symbol(sym.CHAR, yyline, yycolumn, yytext()); }
"string"  { return new Symbol(sym.STRING, yyline, yycolumn, yytext()); }
"true"    { return new Symbol(sym.TRUE, yyline, yycolumn, yytext()); }
"false"   { return new Symbol(sym.FALSE, yyline, yycolumn, yytext()); }

/* 4. Símbolos de agrupación y terminación estrictos */
"<~"      { return new Symbol(sym.ASIGNACION, yyline, yycolumn, yytext()); }
"»"       { return new Symbol(sym.FIN_EXPRESION, yyline, yycolumn, yytext()); }
"є:"      { return new Symbol(sym.PAR_ABRE, yyline, yycolumn, yytext()); }
":э"      { return new Symbol(sym.PAR_CIERRA, yyline, yycolumn, yytext()); }
"f:"      { return new Symbol(sym.INDICE_ABRE, yyline, yycolumn, yytext()); }
":)"      { return new Symbol(sym.INDICE_CIERRA, yyline, yycolumn, yytext()); }
"¿:"      { return new Symbol(sym.BLOQUE_ABRE, yyline, yycolumn, yytext()); }
":?"      { return new Symbol(sym.BLOQUE_CIERRA, yyline, yycolumn, yytext()); }
"["       { return new Symbol(sym.CORCHETE_ABRE, yyline, yycolumn, yytext()); }
"]"       { return new Symbol(sym.CORCHETE_CIERRA, yyline, yycolumn, yytext()); }
","       { return new Symbol(sym.COMA, yyline, yycolumn, yytext()); }
";"       { return new Symbol(sym.PUNTO_COMA, yyline, yycolumn, yytext()); }

/* 5. Operadores aritméticos, relacionales y lógicos */
"+"       { return new Symbol(sym.SUMA, yyline, yycolumn, yytext()); }
"-"       { return new Symbol(sym.RESTA, yyline, yycolumn, yytext()); }
"*"       { return new Symbol(sym.MULT, yyline, yycolumn, yytext()); }
"/"       { return new Symbol(sym.DIV, yyline, yycolumn, yytext()); }
"//"      { return new Symbol(sym.DIV_ENTERA, yyline, yycolumn, yytext()); }
"mod"     { return new Symbol(sym.MOD, yyline, yycolumn, yytext()); }
"pot"     { return new Symbol(sym.POT, yyline, yycolumn, yytext()); }
"++"      { return new Symbol(sym.INC, yyline, yycolumn, yytext()); }
"--"      { return new Symbol(sym.DEC, yyline, yycolumn, yytext()); }
"<"       { return new Symbol(sym.MENOR, yyline, yycolumn, yytext()); }
"<="      { return new Symbol(sym.MENOR_IGUAL, yyline, yycolumn, yytext()); }
">"       { return new Symbol(sym.MAYOR, yyline, yycolumn, yytext()); }
">="      { return new Symbol(sym.MAYOR_IGUAL, yyline, yycolumn, yytext()); }
"=="      { return new Symbol(sym.IGUAL, yyline, yycolumn, yytext()); }
"!="      { return new Symbol(sym.DIFERENTE, yyline, yycolumn, yytext()); }
"λ"       { return new Symbol(sym.AND, yyline, yycolumn, yytext()); }
"θ"       { return new Symbol(sym.OR, yyline, yycolumn, yytext()); }
"Σ"       { return new Symbol(sym.NOT, yyline, yycolumn, yytext()); }

/* 6. Variables y Literales */
{Identificador} { return new Symbol(sym.IDENTIFICADOR, yyline, yycolumn, yytext()); }
{Entero}        { return new Symbol(sym.LITERAL_ENTERO, yyline, yycolumn, yytext()); }
{Flotante}      { return new Symbol(sym.LITERAL_FLOTANTE, yyline, yycolumn, yytext()); }
\"[^\"]*\"      { return new Symbol(sym.LITERAL_CADENA, yyline, yycolumn, yytext()); }
'[^']'          { return new Symbol(sym.LITERAL_CARACTER, yyline, yycolumn, yytext()); }

/* 7. Manejo de errores léxicos (Modo Pánico) */
[^] { 
    System.err.println("Error léxico en la línea " + (yyline+1) + ", columna " + (yycolumn+1) + ": Caracter no reconocido '" + yytext() + "'");
    /* Imprime el error y continúa con el siguiente token, cumpliendo la recuperación solicitada */
}
