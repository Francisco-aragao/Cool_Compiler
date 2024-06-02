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
#define YYLTYPE int		           /* the type of locations */
#define cool_yylloc curr_lineno	   /* use the curr_lineno from the lexer
				                   for the location of tokens */
extern int node_lineno;		       /* set before constructing a tree node
				                   to whatever you want the line number
				                   for the tree node to be */

/* The default actions for lacations. Use the location of the first
   terminal/non-terminal and set the node_lineno to that value. */
#define YYLLOC_DEFAULT(Current, Rhs, N)		\
  Current = Rhs[1];				            \
  node_lineno = Current;

#define SET_NODELOC (Current)	            \
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
%type <program> program
%type <classes> class_list
%type <class_> class_single

/* OLHANDO PELA GRAMATICA DE COOL, ALGUNS TOKENS PODEM VIR COM *, ENTÃO TEM O CASO DELE SER UNICO OU COMO FECHO KLEENE, por isso coloco como list ou single*/

%type <features> feature_list /* FEATURE = ATRIBUTO OU METODO*/
%type <feature> feature_single

%type <formals> formal_list
%type <formal> formal_single

%type <cases> case_list /* switch cases */
%type <case_> case_single

%type <expressions> method_dispatch_list /* lista de chamada de metodos */

%type <expressions> exp_list
%type <expression> exp_single

/* ************* PRECEDENCIA - PAG 57 DO MANUAL BISON*/

/* comparacoes nao tem precedencia */
%nonassoc LE '<' '='

/* atribuicao tem precedencia a direita (o elemento da direita deve ser atribuido ao da esquerda) */
%right ASSIGN

/* expressoes logicas tem precedencia a esquerda */
%left ISVOID 
%left NOT

/* expressoes aritmeticas tem precedencia a esquerda */
%left '+' '-' 
%left '*' '/' 
%left '~' 
%left '@'

/* chamada de metodo tambem acontece da esquerda pra direita (especialmente se encadeadas) */
%left '.'

%%

/* ***************************** NÃO USAR RECURSAO A DIREITA NAS REGRAS, SÓ A ESQUERDA (PAG 46 BISON) */

/* OLHAR ARQUIVO /src/PA3/cool.tree.cc LÁ TEM AS FUNCOES PRA SEREM USADAS NO BISON - DICA DE QUAIS DECLARACOES FAZER*/

program:
  class_list
{     
    @$ = @1;
    ast_root = program($1);
};

class_list:
  class_single 
{
    $$ = single_Classes($1); /* $$ = valor de retorno*/
    parse_results = $$;
}
| class_list class_single 
{
    $$ = append_Classes($1, single_Classes($2));
    parse_results = $$;
}
| error ';'
{
    yyclearin;
    $$ = NULL;
}; // ignora errors e continua, assim o parser enumera todos os erros

class_single:
  CLASS TYPEID '{' feature_list '}' ';'
{ /* olhar definição função class_: nome é TYPEID, pai (não tem herança) é object, feature é feature_list, filename é nome arquivo*/
    $$ = class_($2, idtable.add_string("Object"), $4, stringtable.add_string(curr_filename));
}
|
    CLASS TYPEID INHERITS TYPEID '{' feature_list '}' ';'
{
    $$ = class_($2, $4, $6, stringtable.add_string(curr_filename));
}
| CLASS TYPEID '{' error '}' ';'
{
    yyclearin;
    $$ = NULL;
}
| CLASS error '{' feature_list '}' ';'
{
    yyclearin;
    $$ = NULL;
}
| CLASS error '{' error '}' ';'
{
    yyclearin;
    $$ = NULL;
};

/* lista de features pode ser vazia, mas uma feature nao pode ser vazia */
feature_list: 
{
    $$ = nil_Features();
}
|
    feature_list feature_single
{
    $$ = append_Features($1, single_Features($2));
}
| error ';'
{
    yyclearin;
    $$ = NULL;
} // ignora errors e continua
;

feature_single:
  OBJECTID '(' formal_list ')' ':' TYPEID '{' exp_single '}' ';'
{
    $$ = method($1, $3, $6, $8); 
}
| OBJECTID ':' TYPEID ';'
{
    $$ = attr($1, $3, no_expr());
}
| OBJECTID ':' TYPEID ASSIGN exp_single ';'
{
    $$ = attr($1, $3, $5); 
};

formal_list:
{
    $$ = nil_Formals(); /* pode ser vazio a lista - é fecho de klenne*/
} 
| formal_single
{
    $$ = single_Formals($1);
}
| formal_list ',' formal_single
{
    $$ = append_Formals($1, single_Formals($3));
};

formal_single: 
  OBJECTID ':' TYPEID
{
    $$ = formal($1, $3);
};

/* switch cases */
case_list: 
{ 
    $$ = nil_Cases();  /* lista de case vazia */
}                                          
| case_list case_single 
{ 
    $$ = append_Cases($1, single_Cases($2));   // unir varios cases
};

case_single:
  OBJECTID ':' TYPEID DARROW exp_single ';' // comparacao de um unico case
{
    $$ = branch($1, $3, $5);
};

/* lista de chamada de metodos */
method_dispatch_list: 
{ 
    $$ = nil_Expressions(); 
}
| exp_single 
{ 
    $$ = single_Expressions($1); 
}
| method_dispatch_list ',' exp_single 
{ 
    $$ = append_Expressions($1, single_Expressions($3));
}
| method_dispatch_list error ';'
{
    yyclearin;
    $$ = NULL;
};

/* lista de expressoes */
exp_list:
  exp_single ';' 
{ 
    $$ = single_Expressions($1); 
}
| exp_list exp_single ';' 
{ 
    $$ = append_Expressions($1, single_Expressions($2));
}
| exp_list error ';'
{
    yyclearin;
    $$ = NULL;
}
| exp_list error
{
    yyclearin;
    $$ = NULL;
}
| error
{
    yyclearin;
    $$ = NULL;
};

/* todos os casos de expressoes unicas */
exp_single: 
  OBJECTID ASSIGN exp_single
{
    $$ = assign($1, $3);
}
| exp_single '@' TYPEID '.' OBJECTID '(' method_dispatch_list ')'
{
    $$ = static_dispatch($1, $3, $5, $7);
}
| exp_single '.' OBJECTID '(' method_dispatch_list ')'
{
    $$ = dispatch($1, $3, $5);
}
| OBJECTID '(' method_dispatch_list ')'
{
    $$ = dispatch(object(idtable.add_string("self")), $1, $3);
}
| IF exp_single THEN exp_single ELSE exp_single FI
{
    $$ = cond($2, $4, $6);
}
| WHILE exp_single LOOP exp_single POOL
{
    $$ = loop($2, $4);
}
| '{' exp_list '}'
{
    $$ = block($2);
}
| OBJECTID ':' TYPEID ',' exp_single
{
    $$ = let($1, $3, no_expr(), $5);
}
| OBJECTID ':' TYPEID IN exp_single
{
    $$ = let($1, $3, no_expr(), $5);
}
| LET OBJECTID ':' TYPEID ',' exp_single
{
    $$ = let($2, $4, no_expr(), $6);
}
| OBJECTID ':' TYPEID ASSIGN exp_single ',' exp_single
{
    $$ = let($1, $3, $5, $7);
}
| OBJECTID ':' TYPEID ASSIGN exp_single IN exp_single
{
    $$ = let($1, $3, $5, $7);
}
| LET OBJECTID ':' TYPEID ASSIGN exp_single ',' exp_single
{
    $$ = let($2, $4, $6, $8);
}
| LET OBJECTID ':' TYPEID IN exp_single
{
    $$ = let($2, $4, no_expr(), $6);
}
| LET OBJECTID ':' TYPEID ASSIGN exp_single IN exp_single
{
    $$ = let($2, $4, $6, $8);
}
| CASE exp_single OF case_list ESAC
{
    $$ = typcase($2, $4);
}
| NEW TYPEID
{
    $$ = new_($2);
}
| ISVOID exp_single
{
    $$ = isvoid($2);
}
| exp_single '+' exp_single
{
    $$ = plus($1, $3);
}
| exp_single '-' exp_single
{
    $$ = sub($1, $3);
}
| exp_single '*' exp_single
{
    $$ = mul($1, $3);
}
| exp_single '/' exp_single
{
    $$ = divide($1, $3);
}
| '~' exp_single
{
    $$ = neg($2);
}
| exp_single LE exp_single
{
    $$ = leq($1, $3);
}
| exp_single '<' exp_single
{
    $$ = lt($1, $3);
}
| exp_single '=' exp_single
{
    $$ = eq($1, $3);
}
| NOT exp_single
{
    $$ = comp($2);
}
| '(' exp_single ')'
{
    $$ = $2;
}
| OBJECTID
{
    $$ = object($1);
}
| INT_CONST
{
    $$ = int_const($1);
}
| STR_CONST
{
    $$ = string_const($1);
}
| BOOL_CONST 
{
    if ($1) $$ = bool_const(true); else $$ = bool_const(false);
}
| error
{
    yyclearin;
    $$ = NULL;
};

/* end of grammar */
%%

    /* This function is called automatically when Bison detects a parse error. */
    void yyerror(char *s)
{
    extern int curr_lineno;

    cerr << "\"" << curr_filename << "\", line " << curr_lineno << ": "
         << s << " at or near ";
    print_cool_token(yychar);
    cerr << endl;
    omerrs++;

    if (omerrs > 50)
    {
        fprintf(stdout, "More than 50 errors\n");
        exit(1);
    }
}
