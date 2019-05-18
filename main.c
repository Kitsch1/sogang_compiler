/******************************************************/
/* File : main.c                                      */
/* Main program for TINY Compiler                     */
/* Based on Compiler Construction code by Louden      */
/* 2019 Compiler Prj by Taehoon Kim                   */
/******************************************************/

#include "globals.h"

/* set NO_PARSE to TRUE to get a scanner-only compiler */
#define NO_PARSE TRUE

/* set NO_ANALYZE to TRUE to get a parser-only compiler */
#define NO_ANALYZE TRUE

/* set NO_CODE to TRUE to get a compiler that does not
 * generate code
 */
#define NO_CODE TRUE

/* At proj1, I think util.h and scan.h should be added */
#include "util.h"
#if NO_PARSE
/* #include "scan.h" */
#else
#include "parse.h"
#if !NO_ANALYZE
#include "analyze.h"
#if !NO_CODE
#include "cgen.h"
#endif
#endif
#endif

/* allocate global variables */
int lineno = 0;
FILE * source; // analyzed source code
FILE * listing; // how to print lexical analyzing result
FILE * code;

/* allocate and set tracing flags */
int EchoSource = FALSE;
int TraceScan = TRUE;
int TraceParse = FALSE;
int TraceAnalyze = FALSE;
int TraceCode = FALSE;

int Error = FALSE;

int main( int argc, char * argv[] )
{ TreeNode * syntaxTree;
  char pgm[20]; /* source code file name */
  if (argc != 2)
  	{ fprintf(stderr,"usage: %s <filename>\n",argv[0]);
	  exit(1);
	}
  strcpy(pgm,argv[1]);
  if (strchr (pgm,'.') == NULL)
  	strcat(pgm,".tny");
  source = fopen(pgm,"r");
  if (source == NULL)
  { fprintf(stderr,"File %s not found\n",pgm);
    exit(1);
  }
  listing = stdout; /* send listing to screen */
  fprintf(listing,"\tline number\t\ttoken\t\tlexeme\n");
  fprintf(listing,"---------------------------------------------------------------\n");
#if NO_PARSE
  while (getToken()!=ENDFILE);
#else
  syntaxTree = parse();
  if (TraceParse) {
    fprintf(listing,"\nSyntax tree:\n");
    printTree(syntaxTree);
  }
#if !NO_ANALYZE
  if (!Error)
  { fprintf(listing,"\nBuilding Symbol Table...\n");
    buildSymtab(syntaxTree);
    fprintf(listing,"\nChecking Types...\n");
    typeCheck(syntaxTree);
    fprintf(listing,"\nType Checking Finished\n");
  }
#if !NO_CODE
  if (!Error)
  { char * codefile;
    int fnlen = strcspn(pgm,".");
    codefile = (char*)calloc(fnlen+4, sizeof(char));
    strncpy(codefile,pgm,fnlen);
    strcat(codefile,".tm");
    code = fopen(codefile,"w");
    if (code == NULL)
    { printf("Unable to open %s\n",codefile);
      exit(1);
    }
    codeGen(syntaxTree,codefile);
    fclose(code);
  }
#endif
#endif
#endif
  return 0;
}
