/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */
/*
   The two statements below are here just so this program will compile.
   You may need to change or remove them on your final code.
*/
#define yywrap() 1
#define YY_SKIP_YYWRAP

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

void concat_string_buf(char* string_value) {
  strcat(string_buf, string_value);
}

void restart_string_buf() {
  string_buf[0] = '\0';
}

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;


/*
 *  Add Your own definitions here
 */

%}

/*
 * Define names for regular expressions here.
 */

/* 
KEYWORDS:
*/

CLASS (?i:class)

INHERITS (?i:inherits)

ISVOID (?i:isvoid)

IF (?i:if)
THEN (?i:then)
ELSE (?i:else)
FI (?i:fi)

WHILE (?i:while)
LOOP (?i:loop)
POOL (?i:pool)

LET (?i:let)
IN (?i:in)

CASE (?i:case)
OF (?i:of)
ESAC (?i:esac)

NEW (?i:new)

NOT (?i:not)

TRUE t(?i:rue)
FALSE f(?i:alse)

DARROW          =>
LE       <=
ASSIGN          <-

MATH_OPERATORS ("+"|"-"|"*"|"/")

NEW_LINE ("\n"|"\f"|"\t"|"\b")
WHITE_SPACES (" "|"\n"|"\f"|"\r"|"\v"|"\t"|"\b")

LITERAL ("("|")"|":"|"{"|"}"|";"|"."|","|"@"|"~"|"="|"<")

CHAR_NOT_IN_COOL_GRAMAR ("#"|"'"|"?"|"!"|"^"|">"|"["|"]")

DIGIT [0-9]

TYPEID  [A-Z][a-zA-Z0-9_]*
OBJECTID  [a-z][a-zA-Z0-9_]*

COMMENTS ["--"]*["\n"]
START_COMMENT "(*"
END_COMMENT "*)"

%x COOL_NESTED_COMMENT
%x COOL_SIMPLE_COMMENT
%x READING_STRING

%%

 /*
  *  Nested comments
  */
<INITIAL>"(*" {
  BEGIN(COOL_NESTED_COMMENT);
}

<INITIAL>" " {}
<INITIAL>"\b" {}
<INITIAL>"\t" {}

<INITIAL>"--" {
  BEGIN(COOL_SIMPLE_COMMENT);
}

<INITIAL>"*)" {
  yylval.error_msg = "Unmatched *)";
  return (ERROR);
}

<INITIAL>\" {
  restart_string_buf();
  BEGIN(READING_STRING);
}


{CHAR_NOT_IN_COOL_GRAMAR} {
    yylval.error_msg = yytext;
    return (ERROR);
}


<READING_STRING>\n {
  yylval.error_msg = "Unterminated string constant";
  BEGIN(INITIAL);
  //curr_lineno += 1;
  return (ERROR);
}

<READING_STRING>\\n {
  concat_string_buf("\n");
}

<READING_STRING>\\t {
  concat_string_buf("\t");
}

<READING_STRING>\\f {
  concat_string_buf("\f");
}

<READING_STRING>\\b {
  concat_string_buf("\b");
}

<READING_STRING>\\0 {
  concat_string_buf("0");
}

<READING_STRING>\\. {
  concat_string_buf(&yytext[1]);
}

<READING_STRING>\0 {
  yylval.error_msg = "String contains null character";
  BEGIN(INITIAL);
  curr_lineno += 1;
  return (ERROR);
}

<READING_STRING><<EOF>> {
  yylval.error_msg = "EOF in string constant";
  BEGIN(INITIAL);
  curr_lineno += 1;
  return (ERROR);
}

<READING_STRING>\" {
  BEGIN(INITIAL);

  //cool_yylval.symbol = (char *) string_buf;

  cool_yylval.symbol = stringtable.add_string((char *) string_buf);

  if (strlen(string_buf) > MAX_STR_CONST) {
    yylval.error_msg = "String constant too long";
    BEGIN(INITIAL);
    return (ERROR);
  }

  return (STR_CONST);
}



<READING_STRING>(.|\n) {

  concat_string_buf(yytext);
}

<COOL_SIMPLE_COMMENT>"\n" {
  curr_lineno++;
  BEGIN(INITIAL);
}

<COOL_SIMPLE_COMMENT>[^\n] {}

<COOL_NESTED_COMMENT>[^\n] {}

<COOL_NESTED_COMMENT>"\n" {
  curr_lineno++;
}

<COOL_NESTED_COMMENT><<EOF>> {

  BEGIN(INITIAL);
  cool_yylval.error_msg = "EOF in comment";

  return (ERROR);
}

<COOL_NESTED_COMMENT>"*)" {
  BEGIN(INITIAL);
}

 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }


 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

{LE}		{ return (LE); }
{ASSIGN}		{ return (ASSIGN); }

{CLASS} {return (CLASS);}

{INHERITS} {return (INHERITS);}

{IF} {return (IF);}
{THEN} {return (THEN);}
{ELSE} {return (ELSE);}
{FI} {return (FI);}
  /*printf("comeco do valor lido %c%c\n", yytext[0], yytext[1]);
  printf("\n~saida funcao: %d\n", cool_yylex());*/
  

{WHILE} {return (WHILE);}
{LOOP} {return (LOOP);}
{POOL} {return (POOL);}

{LET} {return (LET);}
{IN} {return (IN);}

{CASE} {return (CASE);}
{OF} {return (OF);}
{ESAC} {return (ESAC);}

{NEW} {return (NEW);}

{ISVOID} {return (ISVOID);}

{NOT} {return (NOT);}

{TRUE}   { yylval.boolean = 1; return (BOOL_CONST); }
{FALSE}  { yylval.boolean = 0; return (BOOL_CONST); }

{MATH_OPERATORS} {
  char operator_inserted = yytext[0];
  return (operator_inserted);
}

{LITERAL} {
  char literal_inserted = yytext[0];
  return (literal_inserted);
}

{TYPEID} {
  cool_yylval.symbol = idtable.add_string(yytext);
  return (TYPEID);
}

{OBJECTID} {
  cool_yylval.symbol = idtable.add_string(yytext);
  return (OBJECTID);
}
 /*
 * Digits
 */

{DIGIT}+ {
  cool_yylval.symbol = inttable.add_string(yytext);
  return (INT_CONST);
}
 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

.		{
			yylval.error_msg = yytext;
			return (ERROR);
		}

\n {   curr_lineno++; }

%%
