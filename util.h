/**************************************************/
/* FILE: util.h                                   */
/* Utility functions for the TINY Compiler        */
/* Compiler Construction: Principle and Practice  */
/* Based on Kenneth C. Louden codes               */
/* 2019 Compiler Project1 by Taehoon Kim          */
/**************************************************/

#ifndef _UTIL_H_
#define _UTIL_H_

/* prints a token and its lexeme to the listing file */
void printToken(TokenType, const char* );

/* creates a new statement node for syntax tree construction */
TreeNode * newStmtNode(StmtKind);

/* creates a new expression node for syntax tree construction*/
TreeNode * newExpNode(ExpKind);

/* creates a new declaration node for syntax tree construction */
TreeNode * newDeclNode(/*DeclKind*/);

/* allcates and makes a new copy of an existing string */
char * copyString(char *);

/* prints a syntax tree to the
* listing file using indentation to indicate subtrees */
void printTree(TreeNode*);

#endif
