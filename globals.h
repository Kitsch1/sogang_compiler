/***********************************************/
/* File: globals.h                             */
/* Global types and vars for TINY Compiler     */
/* must come before other include files        */
/* Based on Compiler Construction code         */
/* 2019 Compiler Prj1 by Taehoon Kim           */
/***********************************************/

#ifndef _GLOBALS_H_
#define _GLOBALS_H_

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#ifndef YYPARSER
#include "cm.tab.h"
#define ENDFILE 0
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

/* MAXRESERVED : the number of reserved words */
#define MAXRESERVED 6

typedef int TokenType;

// typedef enum
// 	/* book-keeping tokens */
// 	{ENDFILE,ERROR,COM_ERROR,COMMENT,
// 	/* reserved words */
// 	ELSE,IF,INT,RETURN,VOID,WHILE,
// 	/* multicharacter tokens */
// 	ID,NUM,
// 	/* special symbols */
// 	PLUS,MINUS,TIMES,OVER,LT,LEQ,RT,REQ,EQ,NEQ,ASSIGN,SEMI,
// 	COMMA,LPAREN,RPAREN,LSB,RSB,LBRACE,RBRACE
// 	} TokenType;

extern FILE* source; /* source code text file */
extern FILE* listing; /* listing output text file */
extern FILE* code; /* code text file for TM simulator */

extern int lineno; /* source line number for listing */

/******** syntax tree for parsing ********/

typedef enum {StmtK,ExpK,DeclK,TypeK} NodeKind;
typedef enum {CompK,SelectK,IterK,RetK} StmtKind; /* need to change */
typedef enum {AssignK,OpK,ConstK,IdK,IdArrK,CallK} ExpKind; /* need to change */
typedef enum {VarK,FuncK,ArrK} DeclKind; /* Array needed? */
typedef enum {VoidK,IntegerK} TypeKind;

/* ExpType is used for type checking */
typedef enum {Void,Integer} ExpType; /* No boolean? */

#define MAXCHILDREN 3

typedef struct _arrayVar
{
	char *name;
	int length;
} arrayVar;

typedef struct treeNode
{
	struct treeNode *child[MAXCHILDREN];
	struct treeNode *sibling;
	int lineno;
	NodeKind nodekind;
	union {
		StmtKind stmt;
		ExpKind exp;
		DeclKind decl;
		TypeKind type;
	} kind;
	union {
		TokenType op;
		ExpType type;
		int val;
		char *name;
		arrayVar arr;
	} attr;
	ExpType type; /* for type checking of exps */
} TreeNode;

/******** Flags for tracing ********/

/* Echosource = TRUE causes the source program to
 * be echoed to the listing file with line numbers
 * during parsing
 */
extern int EchoSource;

/* TraceScan = TRUE causes token information to be
 * printed to the listing file as each token is
 * recognized by the scanner
 */
extern int TraceScan;

/* TraceParse = TRUE causes the syntax tree to be
 * printed to the listing file in linearized form
 * (using indents for children)
 */
extern int TraceParse;

/* TraceAnalyze = TRUE causes symbol table inserts
 * and lookups to be reported to the listing file
 */
extern int TraceAnalyze;

/* TraceCode = TRUE causes comments to be written
 * to the TM code file as code is generated
 */
extern int TraceCode;

/* Error = TRUE prevents further passes if an error occurs */
extern int Error;
#endif
