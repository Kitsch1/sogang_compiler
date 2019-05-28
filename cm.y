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
                | type_spec identifier
                    {
                        $$ = newDeclNode(ArrK);
                        $$->attr.arrayVar.name = savedName;
                        $$->child[0] = $1;
                    }
                 LSB arr_len
                    {
                        $$ = $3;
                        $$->attr.arrayVar.length = savedLength;
                    }
                 RSB SEMI
                    {
                        $$ = $6;
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

fun_decl        : type_spec identifier
                    {
                        $$ = newDeclNode(FuncK);
                        $$->attr.name = savedName;
                    }
                 LPAREN params RPAREN compound_stmt
                    {
                        $$ = $3;
                        $$->child[0] = $1;
                        $$->child[1] = $5;
                        $$->child[2] = $7;
                    }
                ;
            
params          : param-list
                    {
                        $$ = $1;
                    }
                | VOID
                    {
                        $$ = newTypeNode(VoidK);
                        $$->attr.type = Void;
                    }
                ;

param_list      : param_list COMMA param
                    {
                        YYSTYPE t = $1;
                        if(t != NULL)
                        {
                            while(t->sibling)
                            {
                                t = t->sibling;
                            }
                            t->sibling = $3;
                            $$ = $1;
                        }
                        else $$ = $3;
                    }
                | param
                    {
                        $$ = $1;
                    }
                ;

param           : type_spec identifier
                    {
                        $$ = newDeclNode(VarK);
                        $$->attr.name = savedName;
                        $$->child[0] = $1;
                    }
                | type_spec identifier LSB RSB
                    {
                        $$ = newDeclNode(ArrK);
                        $$->attr.arrayVar.name = savedName;
                        $$->attr.arrayVar.length = -1;
                    }
                ;

compound_stmt   : LBRACE local_decl stmt_list RBRACE
                    {
                        $$ = newStmtNode(CompK);
                        $$->child[0] = $2;
                        $$->child[1] = $3;
                    }
                ;

local_decl      : local_decl var_decl
                    {
                        YYSTYPE t = $1;
                        if(t != NULL)
                        {
                            while(t->sibling)
                            {
                                t = t->sibling;
                            }
                            t->sibling = $2;
                            $$ = $1;
                        }
                        else $$ = $2;
                    }
                | empty
                    {
                        $$ = $1;
                    }
                ;

stmt_list       : stmt_list stmt
                    {
                        YYSTYPE t = $1;
                        if(t != NULL)
                        {
                            while(t->sibling)
                            {
                                t = t->sibling;
                            }
                            t->sibling = $2;
                            $$ = $1;
                        }
                        else $$ = $2;
                    }
                | empty
                    {
                        $$ = $1;
                    }
                ;

stmt            : expr_stmt         { $$ = $1; }
                | compound_stmt     { $$ = $1; }
                | selection_stmt    { $$ = $1; }
                | iteration_stmt    { $$ = $1; }
                | return_stmt       { $$ = $1; }
                ;

expr_stmt       : expr SEMI         { $$ = $1; }
                | SEMI              { $$ = NULL; }
                ;

selection_stmt  : IF LPAREN expr RPAREN stmt
                    {
                        $$ = newStmtNode(SelectK);
                        $$->child[0] = $3;
                        $$->child[1] = $5;
                    }
                | IF LPAREN expr RPAREN stmt ELSE stmt
                    {
                        $$ = newSttmtNode(SelectK);
                        $$->child[0] = $3;
                        $$->child[1] = $5;
                        $$->child[2] = $7;
                    }
                ;

iteration_stmt  : WHILE LPAREN expr RPAREN stmt
                    {
                        $$ = newStmtNode(IterK);
                        $$->child[0] = $3;
                        $$->child[1] = $5;
                    }
                ;

return_stmt     : RETURN SEMI
                    {
                        $$ = newStmtNode(RetK);
                    }
                | RETURN expr SEMI
                    {
                        $$ = newStmtNode(RetK);
                        $$->child[0] = $2;
                    }
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

