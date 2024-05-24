/*
 *  cool.y
 *              Parser definition for the COOL language.
 *
 */
%{
#include "cool-io.h"		//includes iostream
#include "cool-tree.h"
#include "stringtab.h"
#include "utilities.h"

/* Locations */
#define YYLTYPE int		   /* the type of locations */
#define cool_yylloc curr_lineno	   /* use the curr_lineno from the lexer
				      for the location of tokens */
extern int node_lineno;		   /* set before constructing a tree node
				      to whatever you want the line number
				      for the tree node to be */

/* The default actions for lacations. Use the location of the first
   terminal/non-terminal and set the node_lineno to that value. */
#define YYLLOC_DEFAULT(Current, Rhs, N)		\
  Current = Rhs[1];				\
  node_lineno = Current;

#define SET_NODELOC (Current)	\
  node_lineno = Current;

extern char *curr_filename;

void yyerror(char *s);        /*  defined below; called for each parse error */
extern int yylex();           /*  the entry point to the lexer  */

/************************************************************************/
/*                DONT CHANGE ANYTHING IN THIS SECTION                  */

Program ast_root;	      /* the result of the parse  */
Classes parse_results;        /* for use in semantic analysis */
int omerrs = 0;               /* number of errors in lexing and parsing */
%}

/* A union of all the types that can be the result of parsing actions. */
%union {
  Boolean boolean;
  Symbol symbol;
  Program program;
  Class_ class_;
  Classes classes;
  Feature feature; 
  Features features;
  Formal formal;
  Formals formals;
  Case case_;
  Cases cases;
  Expression expression;
  Expressions expressions;
  char *error_msg;
}

/* 
   Declare the terminals; a few have types for associated lexemes.
   The token ERROR is never used in the parser; thus, it is a parse
   error when the lexer returns it.

   The integer following token declaration is the numeric constant used
   to represent that token internally.  Typically, Bison generates these
   on its own, but we give explicit numbers to prevent version parity
   problems (bison 1.25 and earlier start at 258, later versions -- at
   257)
*/
%token CLASS 258 ELSE 259 FI 260 IF 261 IN 262 
%token INHERITS 263 LET 264 LOOP 265 POOL 266 THEN 267 WHILE 268
%token CASE 269 ESAC 270 OF 271 DARROW 272 NEW 273 ISVOID 274
%token <symbol>  STR_CONST 275 INT_CONST 276 
%token <boolean> BOOL_CONST 277
%token <symbol>  TYPEID 278 OBJECTID 279 
%token ASSIGN 280 NOT 281 LE 282 ERROR 283

/*  DON'T CHANGE ANYTHING ABOVE THIS LINE, OR YOUR PARSER WONT WORK       */
/**************************************************************************/
 
   /* Complete the nonterminal list below, giving a type for the semantic
      value of each non terminal. (See section 3.6 in the bison 
      documentation for details). */

/* Declare types for the grammar's non-terminals. */


/* OLHAR ARQUIVO /src/PA3/cool.tree.cc LÁ TEM AS FUNCOES PRA SEREM USADAS NO BISON - DICA DE QUAIS DECLARACOES FAZER*/
/* MANUAL COOL TAMBÉM TEM DICAS DE GRAMATICAS*/
%type <program> program
%type <classes> class_list
%type <class_> class_single

/* You will want to change the following line. */

/* OLHANDO PELA GRAMATICA DE COOL, ALGUNS TOKENS PODEM VIR COM *, ENTÃO TEM O CASO DELE SER UNICO OU COMO FECHO KLEENE, por isso coloco como list ou single*/

%type <features> feature_list /* FEATURE = ATRIBUTO OU METODO*/
%type <feature> feature_single

%type <formals> formal_list
%type <formal> formal_single

%type <expressions> exp_list
%type <expression> exp_single

/* Precedence declarations go here. */

/* ************* COLOCAR PRECEDENCIA DEPOIS - PAG 57 DO MANUAL BISON*/

%%

/* ***************************** NÃO USAR RECURSAO A DIREITA NAS REGRAS, SÓ A ESQUERDA (PAG 46 BISON) */

/* OLHAR ARQUIVO /src/PA3/cool.tree.cc LÁ TEM AS FUNCOES PRA SEREM USADAS NO BISON - DICA DE QUAIS DECLARACOES FAZER*/

/* 
   Save the root of the abstract syntax tree in a global variable.
*/
program	: 
  class_list	
    { /* make sure bison computes location information */
			  @$ = @1; /* @$ refere a regra <program> e @1 refere ao primeiro componente da regra, que no caso é: <class_list>*/
			  ast_root = program($1); 
    }
  ;

class_list
	: class_single			/* single class */
		{ 
      $$ = single_Classes($1); /* $$ = valor de retorno*/
      parse_results = $$; 
    }
	| class_list class_single	/* several classes */
		{ 
      $$ = append_Classes($1,single_Classes($2)); 
      parse_results = $$; 
    }
	;

/* If no parent is specified, the class inherits from the Object class. */
class_single	
  : CLASS TYPEID '{' feature_list '}' ';' { /* olhar definição função class_: nome é TYPEID, pai (não tem herança) é object, feature é feature_list, filename é nome arquivo*/
      $$ = class_($2,idtable.add_string("Object"),$4, stringtable.add_string(curr_filename)); 
  }
	| 
  CLASS TYPEID INHERITS TYPEID '{' feature_list '}' ';' 	{ /*nesse caso, class_: nome é TYPEID, pai é prox TYPEID, feature é feature_list, filnema é nome arq*/
      $$ = class_($2,$4,$6,stringtable.add_string(curr_filename)); 
    }
	;

/* Feature list may be empty, but no empty features in list. */
feature_list  :	/* empty */
    {  $$ = nil_Features(); }
  | 
  feature_list feature_single {
      $$ = append_Features($1,single_Features($2)); 
      /* parse_results = $$;  NÃO SEI SE DEVE MANTER ISSO OU NÃO*/ 
  }
  ;

feature_single :
  OBJECTID '(' formal_list ')' ':' TYPEID '{' exp_single ';' {
    $$ = method($1, $3, $6, $8); // method: nome é OBJECTID, formal é formal_list, return é TYPEID, exp é exp_single
  }
  | 
  OBJECTID ':' TYPEID { 

  }
  |
  OBJECTID ':' TYPEID ASSIGN exp_single {

  }
  ;

formal_list :
  { $$ = nil_Formals();} /* pode ser vazio a lista - é fecho de klenne*/
  | formal_single 
    {
      $$ = single_Formals($1);
    }
  | formal_list ',' formal_single 
    {
      $$ = append_Formals($1,single_Formals($3)); 
    }
  ;

formal_single :
  OBJECTID ':' TYPEID ';' 
    { 
      $$ = formal($1, $3);
    }
  ;

exp_list : 
  {

  }
  ;

exp_single :
  {

  }
  ;


/* end of grammar */
%%

/* This function is called automatically when Bison detects a parse error. */
void yyerror(char *s)
{
  extern int curr_lineno;

  cerr << "\"" << curr_filename << "\", line " << curr_lineno << ": " \
    << s << " at or near ";
  print_cool_token(yychar);
  cerr << endl;
  omerrs++;

  if(omerrs>50) {fprintf(stdout, "More than 50 errors\n"); exit(1);}
}

