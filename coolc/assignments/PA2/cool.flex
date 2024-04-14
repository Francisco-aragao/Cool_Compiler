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
IF ("if"|"IF")
THEN ("THEN"|"then")
ELSE ("else"|"ELSE")
FI ("fi"|"FI")

WHILE ("while"|"WHILE")
LOOP ("loop"|"LOOP")
POOL ("pool"|"POOL")

LET ("let"|"LET")
IN ("in"|"IN")

CASE ("case"|"CASE")
OF ("of"|"OF")
ESAC ("esac"|"ESAC")

NEW ("new"|"NEW")

ISVOID ("isvoid"|"ISVOID")

NOT ("not"|"NOT")

TRUE ("true")
FALSE ("false")


DARROW          =>
LESSEQUAL <=
ASSING <-

MATH_OPERATORS ("+"|"-"|"*"|"/")

WHITE_SPACE (" "|"\t")

LITERALS ("")


%%

 /*
  *  Nested comments
  */


 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


{IF} {return (IF);}

{THEN} {return (THEN);}
{ELSE} {return (ELSE);}
{FI} {
  /*printf("comeco do valor lido %c%c\n", yytext[0], yytext[1]);
  printf("\n~saida funcao: %d\n", cool_yylex());*/
  return (FI);}

[A-Z][0-9a-zA-Z_]* {
  cool_yylval.symbol = idtable.add_string(yytext);
  return (TYPEID);
}
 /*
 * Digits
 */

[0-9]+ {
  cool_yylval.symbol = inttable.add_string(yytext);
  return (INT_CONST);
}
 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


%%
