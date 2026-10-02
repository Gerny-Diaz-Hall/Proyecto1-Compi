package compilador;
import java_cup.runtime.Symbol;

%%

%public
%class Lexer
%unicode
%line
%column
%cup

%{
    /* Tablas de simbolos y lista de tokens encontrados */
    private final TablaSimbolos tablaSimbolos = new TablaSimbolos();

    /* Errores lexicos encontrados (el scanner no se detiene)*/
    private final java.util.List<String> errores = new java.util.ArrayList<>();

    public TablaSimbolos getTablaSimbolos() { return tablaSimbolos; }
    public java.util.List<String> getErrores() { return errores; }

    private static final TablaSimbolos.Tipo RESERVADA = TablaSimbolos.Tipo.RESERVADAS;
    private static final TablaSimbolos.Tipo IDENT     = TablaSimbolos.Tipo.IDENTIFICADORES;
    private static final TablaSimbolos.Tipo LITERAL   = TablaSimbolos.Tipo.LITERALES;
    private static final TablaSimbolos.Tipo OPERADOR  = TablaSimbolos.Tipo.OPERADORES;

    /* Crea el token, lo registra en su tabla y lo entrega al parser */
    private Symbol tok(int id, String nombre, TablaSimbolos.Tipo tabla) {
        tablaSimbolos.registrar(tabla, nombre, yytext(), yyline + 1, yycolumn + 1);
        return new Symbol(id, yyline + 1, yycolumn + 1, yytext());
    }

    /* Reporta un error lexico y continua */
    private void error(String mensaje) {
        errores.add("Error lexico en linea " + (yyline + 1) + ", columna " + (yycolumn + 1)
                    + ": " + mensaje + " -> '" + yytext().replace("\n", "\\n").replace("\r", "") + "'");
    }
%}

/* ------------------------------- Macros ------------------------------- */

ESPACIO      = [ \t\r\n\f\uFEFF]+

LETRA        = [a-zA-Z_]
DIGITO       = [0-9]
ID           = {LETRA}({LETRA}|{DIGITO})*

/* Literales SIN signo: el "-" es un token aparte que maneja la gramatica  */
ENTERO       = {DIGITO}+
FLOTANTE     = {DIGITO}+"."{DIGITO}+
CARACTER     = "'"[^'\r\n]"'"
CADENA       = \"[^\"\r\n]*\"

/* Comentarios: linea = | ... fin de linea ;  bloque = ¡ ... ! */
COMENT_LINEA      = "|"[^\r\n]*
COMENT_BLOQUE     = \u00A1[^!]*"!"
COMENT_SIN_CERRAR = \u00A1[^!]*

/* Simbolos especiales del lenguaje (glifo -> codigo unicode) */
BLOQUE_ABRE   = \u00BF":"       /* ¿:  */
BLOQUE_CIERRA = ":?"             /* :?  */
INDICE_ABRE   = \u0283":"        /* ʃ:  */
INDICE_CIERRA = ":"\u0285        /* :ʅ  */
PAREN_ABRE    = \u0454":"        /* є:  */
PAREN_CIERRA  = ":"\u044D        /* :э  */
ASIGNACION    = \u0370           /* Ͱ   */
FIN_SENT      = \u00BB           /* »   */
OP_AND        = \u03BB           /* λ   */
OP_OR         = \u03B8           /* θ   */
OP_NOT        = \u03A3           /* Σ   */

%%

/* ------------------------------- Reglas ------------------------------- */


{ESPACIO}            { /* se ignora */ }
{COMENT_LINEA}       { /* se ignora */ }
{COMENT_BLOQUE}      { /* se ignora */ }
{COMENT_SIN_CERRAR}  { error("comentario multilinea sin cerrar (falta '!')"); }

/* ---- Palabras reservadas ---- */
"val"        { return tok(sym.VAL,       "VAL",       RESERVADA); }
"int"        { return tok(sym.INT,       "INT",       RESERVADA); }
"float"      { return tok(sym.FLOAT,     "FLOAT",     RESERVADA); }
"boolean"    { return tok(sym.BOOLEAN,   "BOOLEAN",   RESERVADA); }
"char"       { return tok(sym.CHAR,      "CHAR",      RESERVADA); }
"string"     { return tok(sym.STRING,    "STRING",    RESERVADA); }
"void"       { return tok(sym.VOID,      "VOID",      RESERVADA); }
"principal"  { return tok(sym.PRINCIPAL, "PRINCIPAL", RESERVADA); }
"true"       { return tok(sym.TRUE,      "TRUE",      RESERVADA); }
"false"      { return tok(sym.FALSE,     "FALSE",     RESERVADA); }
"if"         { return tok(sym.IF,        "IF",        RESERVADA); }
"elif"       { return tok(sym.ELIF,      "ELIF",      RESERVADA); }
"else"       { return tok(sym.ELSE,      "ELSE",      RESERVADA); }
"while"      { return tok(sym.WHILE,     "WHILE",     RESERVADA); }
"for"        { return tok(sym.FOR,       "FOR",       RESERVADA); }
"return"     { return tok(sym.RETURN,    "RETURN",    RESERVADA); }
"break"      { return tok(sym.BREAK,     "BREAK",     RESERVADA); }
"read"       { return tok(sym.READ,      "READ",      RESERVADA); }
"write"      { return tok(sym.WRITE,     "WRITE",     RESERVADA); }

/* ---- Identificadores y literales ---- */
{ID}         { return tok(sym.IDENTIFICADOR,    "IDENTIFICADOR",    IDENT);   }
{FLOTANTE}   { return tok(sym.LITERAL_FLOTANTE, "LITERAL_FLOTANTE", LITERAL); }
{ENTERO}     { return tok(sym.LITERAL_ENTERO,   "LITERAL_ENTERO",   LITERAL); }
{CARACTER}   { return tok(sym.LITERAL_CARACTER, "LITERAL_CARACTER", LITERAL); }
{CADENA}     { return tok(sym.LITERAL_CADENA,   "LITERAL_CADENA",   LITERAL); }

/* ---- Operadores aritmeticos ---- */
"++"         { return tok(sym.INC,     "INC",     OPERADOR); }
"--"         { return tok(sym.DEC,     "DEC",     OPERADOR); }
"+"          { return tok(sym.SUMA,    "SUMA",    OPERADOR); }
"-"          { return tok(sym.RESTA,   "RESTA",   OPERADOR); }
"*"          { return tok(sym.MULT,    "MULT",    OPERADOR); }
"//"         { return tok(sym.DIV_ENT, "DIV_ENT", OPERADOR); }
"/"          { return tok(sym.DIV,     "DIV",     OPERADOR); }
"%"          { return tok(sym.MOD,     "MOD",     OPERADOR); }
"^"          { return tok(sym.POT,     "POT",     OPERADOR); }

/* ---- Operadores relacionales ---- */
"<="         { return tok(sym.MENOR_IG,  "MENOR_IG",  OPERADOR); }
">="         { return tok(sym.MAYOR_IG,  "MAYOR_IG",  OPERADOR); }
"=="         { return tok(sym.IGUAL,     "IGUAL",     OPERADOR); }
"!="         { return tok(sym.DIFERENTE, "DIFERENTE", OPERADOR); }
"<"          { return tok(sym.MENOR,     "MENOR",     OPERADOR); }
">"          { return tok(sym.MAYOR,     "MAYOR",     OPERADOR); }

/* ---- Operadores logicos ---- */
{OP_AND}     { return tok(sym.AND, "AND", OPERADOR); }
{OP_OR}      { return tok(sym.OR,  "OR",  OPERADOR); }
{OP_NOT}     { return tok(sym.NOT, "NOT", OPERADOR); }

/* ---- Delimitadores y simbolos especiales ---- */
{ASIGNACION}     { return tok(sym.ASIGNACION,    "ASIGNACION",    OPERADOR); }
{FIN_SENT}       { return tok(sym.FIN_SENT,      "FIN_SENT",      OPERADOR); }
","              { return tok(sym.COMA,          "COMA",          OPERADOR); }
{BLOQUE_ABRE}    { return tok(sym.BLOQUE_ABRE,   "BLOQUE_ABRE",   OPERADOR); }
{BLOQUE_CIERRA}  { return tok(sym.BLOQUE_CIERRA, "BLOQUE_CIERRA", OPERADOR); }
{INDICE_ABRE}    { return tok(sym.INDICE_ABRE,   "INDICE_ABRE",   OPERADOR); }
{INDICE_CIERRA}  { return tok(sym.INDICE_CIERRA, "INDICE_CIERRA", OPERADOR); }
{PAREN_ABRE}     { return tok(sym.PAREN_ABRE,    "PAREN_ABRE",    OPERADOR); }
{PAREN_CIERRA}   { return tok(sym.PAREN_CIERRA,  "PAREN_CIERRA",  OPERADOR); }

/* ---- Errores lexicos (modo panico: se reporta, se descarta y se sigue) ---- */
\"[^\"\r\n]*          { error("cadena sin cerrar (falta '\"' en la misma linea)"); }
"'"[^'\r\n]*"'"?      { error("literal de caracter mal formado (debe tener exactamente 1 caracter)"); }
[^]                   { error("simbolo no reconocido por el lenguaje"); }
