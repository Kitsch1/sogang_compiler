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

static int yyerror(char * message);
static int yylex(void);

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
                        $$ = newStmtNode(SelectK);
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
                    {
                        $$ = newExpNode(AssignK);
                        $$->child[0] = $1;
                        $$->child[1] = $3;
                    }
                | simple_expr
                    {
                        $$ = $1;
                    }
                ;

var             : identifier
                    {
                        $$ = newExpNode(IdK);
                        $$->attr.name = savedName;
                    }
                | identifier
                    {
                        $$ = newExpNode(IdArrK);
                        $$->attr.name = savedName;
                    }
                 LSB expr RSB
                    {
                        $$ = $2;
                        $$->child[0] = $4;
                    }
                ;

simple_expr     : additive_expr relop additive_expr
                    {
                        $$ = $2;
                        $$->child[0] = $1;
                        $$->child[1] = $3;
                    }
                | additive_expr
                    {
                        $$ = $1;
                    }
                ;

relop           : LEQ
                    {
                        $$ = newExpNode(OpK);
                        $$->attr.op = LEQ;
                    }
                | LT
                    {
                        $$ = newExpNode(OpK);
                        $$->attr.op = LT;
                    }
                | REQ
                    {
                        $$ = newExpNode(OpK);
                        $$->attr.op = REQ;
                    }
                | RT
                    {
                        $$ = newExpNode(OpK);
                        $$->attr.op = RT;
                    }
                | EQ
                    {
                        $$ = newExpNode(OpK);
                        $$->attr.op = EQ;
                    }
                | NEQ
                    {
                        $$ = newExpNode(OpK);
                        $$->attr.op = NEQ;
                    }
                ;

additive_expr   : additive_expr addop term
                    {
                        $$ = $2;
                        $$->child[0] = $1;
                        $$->child[1] = $3;
                    }
                | term
                    {
                        $$ = $1;
                    }
                ;

addop           : PLUS
                    {
                        $$ = newExpNode(OpK);
                        $$->attr.op = PLUS;
                    }
                | MINUS
                    {
                        $$ = newExpNode(OpK);
                        $$->attr.op = MINUS;
                    }
                ;


term            : term mulop factor
                    {
                        $$ = $2;
                        $$->child[0] = $1;
                        $$->child[1] = $3;
                    }
                | factor
                    {
                        $$ = $1;
                    }
                ;

mulop           : TIMES
                    {
                        $$ = newExpNode(OpK);
                        $$->attr.op = TIMES;
                    }
                | OVER
                    {
                        $$ = newExpNode(OpK);
                        $$->attr.op = OVER;
                    }
                ;

factor          : LPAREN epxr RPAREN
                    {
                        $$ = $2;
                    }
                | var
                    {
                        $$ = $1;
                    }
                | call
                    {
                        $$ = $1;
                    }
                | NUM
                    {
                        $$ = newExpNode(ConstK);
                        $$->attr.val = atoi(tokenString);
                    }
                ;

call            : identifier
                    {
                        $$ = newExpNode(CallK);
                        $$->attr.name = savedName;
                    }
                 LPAREN args RPAREN
                    {
                        $$ = $2;
                        $$->child[0] = $4;
                    }
                ;

args            : arg_list      { $$ = $1; }
                | empty         { $$ = $1; }
                ;

arg_list        : arg_list COMMA expr
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
                | expr
                    {
                        $$ = $1;
                    }
                ;

empty           : { $$ = NULL; }
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
{ //return getToken();
    int token;
    do
    {
        token = getToken();
    } while(token == COMMENT);
    return token;
}

TreeNode * parse(void)
{ yyparse();
  return savedTree;
}

