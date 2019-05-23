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
static int savedLength;
static int savedLineNo;  /* ditto */
static TreeNode * savedTree; /* stores syntax tree for later return */

%}

/* need to add tokens */

%token  IF ELSE INT RETURN VOID WHILE

%token  ID NUM

%token  SEMI

/**/

%left   COMMA
%right  ASSIGN
%left   EQ NEQ
%left   LT LEQ RT REQ
%left   TIMES OVER
%left   PLUS MINUS
%right  LPAREN RPAREN LBRACE RBRACE LSB RSB


/* $$ is result */
/* $n is n'th term in sytanx rule */
%% /* Grammar for C Minus. Need to add */

program         : decl_list
                    { savedTree = $1; }
                ;

decl_list       : decl_list decl
                    {
                        YYSTYPE t = $1;
                        if(t != NULL)
                        {
                            while(t->sibling != NULL)
                            {
                                t = t->sibling;
                            }
                            t->sibling = $2;
                            $$ = $1;
                        }
                        else
                        {
                            $$ = $2;
                        }
                    }
                | decl
                    {
                        $$ = $1;
                    }
                ;

decl            : var_decl
                    {
                        $$ = $1;
                    }
                | fun_decl
                    {
                        $$ = $1;
                    }
                ;

identifier      : ID
                    {
                        savedName = copyString(tokenString);
                    }
                ;

arr_len         : NUM
                    {
                        savedLength = atoi(tokenString);
                    }
                ;

var_decl        : type_spec identifier SEMI
                    {
                        $$ = newDeclNode(VarK);
                        $$->attr.name = savedName;
                        $$->child[0] = $1;
                    }
                | type_spec identifier LSB arr_len RSB SEMI
                    {
                        $$ = newDeclNode(ArrK);
                        $$->attr.arrayVar.name = savedName;
                        $$->attr.arrayVar.length = savedLength;
                        $$->child[0] = $1;
                    }
                ;

type_spec       : INT
                    {
                        $$ = newTypeNode(IntegerK);
                        $$->attr.type = Integer;
                    }
                | VOID
                    {
                        $$ = newTypeNode(VoidK);
                        $$->attr.type = Void;
                    }
                ;

fun_decl        : type_spec ID LPAREN params RPAREN compound-stmt
                ;
            
params          : param-list
                | void
                ;

param_list      : param_list COMMA param
                | param
                ;

param           : type_spec ID
                | type_spec LSB RSB
                ;

compound_stmt   : LBRACE local_decl stmt_list RBRACE
                ;

local_decl      : local_decl var_decl
                | empty
                ;

stmt_list       : stmt_list stmt
                | empty
                ;

stmt            : expr_stmt
                | compound_stmt
                | selection_stmt
                | iteration_stmt
                | return_stmt
                ;

expr_stmt       : expr SEMI
                | SEMI
                ;

selection_stmt  : IF LPAREN expr RPAREN stmt
                | IF LPAREN expr RPAREN stmt ELSE stmt
                ;

iteration_stmt  : WHILE LPAREN expr RPAREN stmt
                ;

return_stmt     : RETURN SEMI
                | RETURN expr SEMI
                ;

expr            : var ASSIGN expr
                | simple_expr
                ;

var             : ID
                | ID LSB expr RSB
                ;

simple_expr     : additive_expr relop additive_expr
                | additive_expr
                ;

relop           : LEQ
                | LT
                | REQ
                | RT
                | EQ
                | NEQ
                ;

additive_expr   : additive_expr addop term | term
                ;

addop           : PLUS
                | MINUS
                ;


term            : term mulop factor
                | factor
                ;

mulop           : TIMES
                | OVER
                ;

factor          : LPAREN epxr RPAREN
                | var
                | call
                | NUM
                ;

call            : ID LPAREN args RPAREN
                ;

args            : arg_list
                | empty
                ;

arg_list        : arg_list COMMA expr
                | expr
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

