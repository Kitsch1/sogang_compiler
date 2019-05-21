/****************************************************/
/* File: cm.y                                       */
/* The C Minus Yacc/Bison specification file        */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/
%{
#define YYPARSER /* distinguishes Yacc output from other code files */

#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"

#define YYSTYPE TreeNode *
static char * savedName; /* for use in assignments */
static int savedLineNo;  /* ditto */
static TreeNode * savedTree; /* stores syntax tree for later return */

%}

/* need to add tokens */

%token  IF ELSE INT RETURN VOID WHILE
%token  ID NUM
%token  SEMI
%left   COMMA
%right  ASSIGN
%left   EQ NEQ
%left   LT LEQ RT REQ
%left   TIMES OVER
%left   PLUS MINUS
%right  LPAREN RPAREN LSB RSB


%% /* Grammar for C Minus. Need to add */

program     : decl_list
                { savedTree = $1; }
            ;

decl_list   : decl_list decl_list
            | decl
            ;

decl        : var_decl
            | fun_decl
            ;

var_decl    : type_spec ID SEMI
            | type_spec ID LSB NUM RSB SEMI
            ;

type_spec   : INT
            | VOID
            ;

fun_decl    : type_spec ID LPAREN params RPAREN compound-stmt
            ;
            
params      : param-list
            | void
            ;

%%

int yyerror(char * message)
{ fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
  fprintf(listing,"Current token: ");
  printToken(yychar,tokenString);
  Error = TRUE;
  return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the TINY scanner
 */
static int yylex(void)
{ return getToken(); }

TreeNode * parse(void)
{ yyparse();
  return savedTree;
}

