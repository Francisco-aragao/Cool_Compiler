#ifndef _AST_PARSE_H
#define _AST_PARSE_H
//
// See copyright.h for copyright notice and limitation of liability
// and disclaimer of warranty provisions.
//
#include "copyright.h"

#ifndef _COOL_H_
#define _COOL_H_

#include "cool-io.h"

/* a type renaming */
typedef int Boolean;
class Entry;
typedef Entry *Symbol;

Boolean copy_Boolean(Boolean);
void assert_Boolean(Boolean);
void dump_Boolean(ostream &,int,Boolean);

Symbol copy_Symbol(Symbol);
void assert_Symbol(Symbol);
void dump_Symbol(ostream &,int,Symbol);

#endif
#include "tree.h"
typedef class Program_class *Program;
typedef class Class__class *Class_;
typedef class Feature_class *Feature;
typedef class Formal_class *Formal;
typedef class Expression_class *Expression;
typedef class Case_class *Case;
typedef list_node<Class_> Classes_class;
typedef Classes_class *Classes;
typedef list_node<Feature> Features_class;
typedef Features_class *Features;
typedef list_node<Formal> Formals_class;
typedef Formals_class *Formals;
typedef list_node<Expression> Expressions_class;
typedef Expressions_class *Expressions;
typedef list_node<Case> Cases_class;
typedef Cases_class *Cases;
/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_AST_YY_AST_TAB_H_INCLUDED
# define YY_AST_YY_AST_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int ast_yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    PROGRAM = 258,                 /* PROGRAM  */
    CLASS = 259,                   /* CLASS  */
    METHOD = 260,                  /* METHOD  */
    ATTR = 261,                    /* ATTR  */
    FORMAL = 262,                  /* FORMAL  */
    BRANCH = 263,                  /* BRANCH  */
    ASSIGN = 264,                  /* ASSIGN  */
    STATIC_DISPATCH = 265,         /* STATIC_DISPATCH  */
    DISPATCH = 266,                /* DISPATCH  */
    COND = 267,                    /* COND  */
    LOOP = 268,                    /* LOOP  */
    TYPCASE = 269,                 /* TYPCASE  */
    BLOCK = 270,                   /* BLOCK  */
    LET = 271,                     /* LET  */
    PLUS = 272,                    /* PLUS  */
    SUB = 273,                     /* SUB  */
    MUL = 274,                     /* MUL  */
    DIVIDE = 275,                  /* DIVIDE  */
    NEG = 276,                     /* NEG  */
    LT = 277,                      /* LT  */
    EQ = 278,                      /* EQ  */
    LEQ = 279,                     /* LEQ  */
    COMP = 280,                    /* COMP  */
    INT = 281,                     /* INT  */
    STR = 282,                     /* STR  */
    BOOL = 283,                    /* BOOL  */
    NEW = 284,                     /* NEW  */
    ISVOID = 285,                  /* ISVOID  */
    NO_EXPR = 286,                 /* NO_EXPR  */
    OBJECT = 287,                  /* OBJECT  */
    NO_TYPE = 288,                 /* NO_TYPE  */
    STR_CONST = 289,               /* STR_CONST  */
    INT_CONST = 290,               /* INT_CONST  */
    ID = 291,                      /* ID  */
    LINENO = 292                   /* LINENO  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEMPTY -2
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define PROGRAM 258
#define CLASS 259
#define METHOD 260
#define ATTR 261
#define FORMAL 262
#define BRANCH 263
#define ASSIGN 264
#define STATIC_DISPATCH 265
#define DISPATCH 266
#define COND 267
#define LOOP 268
#define TYPCASE 269
#define BLOCK 270
#define LET 271
#define PLUS 272
#define SUB 273
#define MUL 274
#define DIVIDE 275
#define NEG 276
#define LT 277
#define EQ 278
#define LEQ 279
#define COMP 280
#define INT 281
#define STR 282
#define BOOL 283
#define NEW 284
#define ISVOID 285
#define NO_EXPR 286
#define OBJECT 287
#define NO_TYPE 288
#define STR_CONST 289
#define INT_CONST 290
#define ID 291
#define LINENO 292

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 22 "ast.y"

  int lineno;
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

#line 158 "ast.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE ast_yylval;


int ast_yyparse (void);


#endif /* !YY_AST_YY_AST_TAB_H_INCLUDED  */
#endif
