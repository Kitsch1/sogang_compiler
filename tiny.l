/****************************************************/
/* File: tiny.l                                     */
/* Lex specification for TINY                       */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/
/* Need to add comment handling                     */

%{
#include "globals.h"
#include "util.h"
#include "scan.h"
/* lexeme of identifier or reserved words */
%}

%option noyywrap

identifier  {letter}+ 
number 	    {digit}+
letter	    [a-zA-Z]
digit       [0-9]
newline     \n
whitespace  [ \t\b]+

%%

"else"          {return ELSE;}
"if"		{return IF;}
"int"		{return INT;}
"return"	{return RETURN;}
"void"		{return VOID;}
"while"		{return WHILE;}
"+"		{return PLUS;}
"-"		{return MINUS;}
"*"		{return TIMES;}
"/"		{return OVER;}
"<"		{return LT;}
"<="		{return LEQ;}
">"		{return RT;}
">="		{return REQ;}
"=="		{return EQ;}
"!="		{return NEQ;}
"="		{return ASSIGN;}
";"		{return SEMI;}
","		{return COMMA;}
"("		{return LPAREN;}
")"		{return RPAREN;}
"["		{return LSB;}
"]"		{return RSB;}
"{"		{return LBRACE;}
"}"		{return RBRACE;}
{number}        {return NUM;}
{identifier}    {return ID;}
{newline}       {lineno++;}
{whitespace}    {/* skip whitespace */}
"/*"		{ register int c;
		  for(;;)
		  { while ( (c = input()) != '*' && c != EOF){
			if(c == '\n') lineno++;
		    }
		    if(c == '*')
		    { while ( (c = input()) == '*' );
		      if (c=='\n') lineno++;
		      if ( c == '/') //break; /* End of Comment */
					{
						return COMMENT;
					}
		    }
		    if(c == EOF )
		    {
		      return COM_ERROR;
		    }
		  }
		}
.               {return ERROR;}

%%

TokenType getToken(void)
{ static int firstTime = TRUE;
  TokenType currentToken;
  if (firstTime)
  { firstTime = FALSE;
    lineno++;
    yyin = source;
    yyout = listing;
  }
  currentToken = yylex();
  strncpy(tokenString,yytext,MAXTOKENLEN);
  if (TraceScan) {
    fprintf(listing,"\t\t%d\t",lineno);
    printToken(currentToken,tokenString);
  }
  return currentToken;
}

