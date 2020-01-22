%{
	#define _GNU_SOURCE	
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "lex.yy.c"

	typedef enum {false,true } bool;
	
	typedef struct node
	{
		int count;
		char *token;
		struct node *left;
		struct node *right;	
		char *var;
		char *label;
		char *labelTrue;
		char *labelFalse;
		char *SCOPE;
		
		
	} node;
	
    
	typedef struct Function
	{
		char * name;
		int argumentNum;
		struct Args* args; 
		char *returnType; 
		bool findreturn;


		
    } Function; 

	typedef struct Args
	{
		char* name;
		char* length;
		char* type;
	}Args;	
	
	
	typedef struct Varibles
	{	
		char *name;
		char *type;
		char *value;
		char * length;
		int isArg;
	}Var; 
	
	typedef struct ScopeN 
	{	
		char *name;
		Var * var;
		int VaribleCount; 
		int Fcount; 
		Function ** func;
		struct ScopeN * nextScope;
		struct ScopeN * preScope;

	}ScopeN; 
	
	int yylex();
	int yyerror(char *e);
	static int mainc=0;
	static int t=0;
	static int lab=1;
	static int line=0;
	static node* start;
	static int scope=0;
	node* makeNode(char* token, node *left, node *right);
 	Args * makeArguments(node *,int *); 
 	Args* functionArguments(ScopeN *,node *tree,int * count); 
 	ScopeN* makeScope(char *);
 	ScopeN* final_Scope(ScopeN * scopes); 
	ScopeN* globalScope=NULL;
 	void semantic(node *tree,ScopeN * scope); 
 	char* expressionType(node *,ScopeN*); 
 	void addFunction(char*,Args* ,node*,int,ScopeN*); 
 	void addVarible(Args* ,int,int,ScopeN*);  
 	void pushScopes(ScopeN* ,char*);
 	char* functionInScopes(node * tree,ScopeN * curScope,int* countParams); 			 
 	char* findVarible(node * tree,ScopeN * curScope);
	int popParameters(Args * args,int count);
	void make3AC(node*);
	void addScope(node*, char*, char*, char*,char*, char*);
	void addScope2(node*, char* ,char*, char*, char*,char*);
	char* newVarible();
	char* newLabel();
	char* cutStr(char*des,char*src);
	char* generate(char*,char*,char*,char*,char*);
	char * space(char*);
	char *strReplac(const char*, const char*, const char*);
	
%}
%union
{
    struct node *node;
    char *string;
}



%token <string> COMMENT WHILE IF ELSE FOR DO 
%token <string> BOOL STRING CHARPTR CHAR INT INTPTR VOID RETURN
%token <string> AND REF EQL ASSING OR BIGGEREQL BIGGER SMALLEREQL SMALLER NOTEQL NOT
%token <string> DIV PLUS MINUS MUL VAR
%token <string> STRVal REALVal CHARVal NULLL
%token <string> MAIN ID 
%token <string> DECIMAL_INTVal HEX_INTVal TRUEVal FALSEVal REAL REALPTR FUNC DEREFRENCE 
%token <string>	QUOTE DOUBLE_QUOTES BEGIN_COMMENT END_COMMENT 

%left NOTEQL SMALLER SMALLEREQL BIGGEREQL BIGGER OR AND EQL
%left PLUS MINUS RETURN
%left MUL DIV
%left ';' ASSING
%right NOT '}'

%nonassoc ID
%nonassoc '('
%nonassoc IF
%nonassoc ELSE 


%type <node> ADRS_EXP STATES BLOCK POINTERS EXP_LIST FUNCCALL
%type <node> EXP LEFT_ASSIGN ASSIGN_STATE BLOCK1 
%type <node> STATE TYPE TYPE_ID IDS DECEL FUNCCALL_EXP 
%type <node> BODY PARAM_LIST PARAMS PROCEDURE PROCEDURES
%type <node> MAIN_FUNC PROGRAM START DECELS 
%%
 
START:		CMNT PROGRAM 					{start = $2;semantic($2,globalScope);make3AC($2);}; 

PROGRAM:	PROCEDURES MAIN_FUNC				{$$=makeNode("CODE",$1,$2);};

CMNT: 		COMMENT CMNT 					{;}|;

MAIN_FUNC:  	FUNC VOID MAIN '(' ')' CMNT '{' BODY '}'	{$$=makeNode("MAIN",makeNode("ARGS",NULL,$8),NULL);};
		/*|FUNC VOID MAIN '(' PARAMS')' CMNT '{' BODY '}'	{$$=makeNode("MAIN",makeNode("ARGS",makeNode("ARGSM",NULL,$5),$9),NULL);}
						|FUNC TYPE MAIN  '(' ')' CMNT '{' BODY '}'	{$$=makeNode("TYPEM",$2,NULL);}*/
											
				
PROCEDURES: 	PROCEDURES  PROCEDURE 				{$$=makeNode("procedures",$1,$2);}
		| 						{$$=NULL;};

PROCEDURE: 	FUNC TYPE ID '(' PARAMS ')' CMNT '{' BODY '}'	{$$=makeNode("FUNC",makeNode($3,makeNode(" ",NULL,NULL),
											    makeNode("ARGS",$5,makeNode("TYPE",$2,NULL))),
											    makeNode("",$9,NULL));};

PARAMS: 	PARAM_LIST 					{$$=$1;}
		| 						{$$=NULL;};

PARAM_LIST: 	TYPE_ID IDS 					{$$=makeNode("(",$1,makeNode("",$2,makeNode(")",NULL,NULL)));}
		|PARAM_LIST ';' CMNT  PARAM_LIST 		{$$=makeNode("expr_list",$1,makeNode("",$4,NULL));} ;


BODY:		CMNT PROCEDURES DECELS STATES 			{$$=makeNode("BODY", makeNode(" ",$2,NULL),
										   makeNode(" ",$3,makeNode(" ",$4,makeNode(" ",NULL,NULL))));};

DECELS:		DECELS DECEL  					{$$=makeNode("",$1,$2);} 
		| 						{$$=NULL;};

DECEL: 		VAR TYPE_ID IDS CMNT ';' CMNT 			{$$=makeNode("var", $2,$3);}
		|STRING IDS CMNT ';' CMNT			{$$=makeNode("var", makeNode("string",NULL, NULL),$2);}
		
		
		;


IDS:		ID ',' IDS 					{$$=makeNode($1, makeNode(" ", $3, NULL),NULL);}
		|ID 						{$$=makeNode($1, NULL, NULL);} 
		|ID '[' DECIMAL_INTVal ']' ',' IDS		{$$=makeNode($1,makeNode(" ", $6, NULL),NULL);}
		|ID '[' DECIMAL_INTVal ']' 			{$$=makeNode($1,NULL,NULL);}
		|ID ASSING EXP					{$$=makeNode("=",makeNode($1,NULL,NULL),$3);};
		
	
TYPE_ID: 	BOOL 						{$$=makeNode("boolean", NULL, NULL);}
		|STRING '[' DECIMAL_INTVal ']'			{$$=makeNode("string", makeNode("[",makeNode("$3",NULL,NULL),NULL), NULL);}
		|CHAR						{$$=makeNode("char", NULL, NULL);}
		|INT						{$$=makeNode("int", NULL, NULL);}
		|REAL						{$$=makeNode("real", NULL, NULL);}
		|INTPTR						{$$=makeNode("int*", NULL, NULL);}
		|CHARPTR					{$$=makeNode("char*", NULL, NULL);}
		|REALPTR					{$$=makeNode("real*", NULL, NULL);};

TYPE: 		BOOL 						{$$=makeNode("boolean", NULL, NULL);}
 		|STRING 					{$$=makeNode("string", NULL, NULL);}
		|CHAR 						{$$=makeNode("char", NULL, NULL);}
		|INT 						{$$=makeNode("int", NULL, NULL);}
		|REAL 						{$$=makeNode("real", NULL, NULL);}
		|INTPTR 					{$$=makeNode("int*", NULL, NULL);}
		|CHARPTR 					{$$=makeNode("char*", NULL, NULL);}
		|REALPTR 					{$$=makeNode("real*", NULL, NULL);}
		|VOID						{$$=makeNode("void", NULL, NULL);};
	
STATES: 	STATES STATE 					{$$=makeNode("stmnts",$1,$2);
								if(strcmp($2->token, "if") == 0||strcmp($2->token, "for") == 0||
								strcmp($2->token, "if-else") == 0||strcmp($2->token, "while") == 0)
								{ 
									if($$->count==0) {
										addScope($2,NULL,NULL,newLabel(),NULL,NULL); 
										$$->count=1;}}   } 
		| 						{$$=NULL;};

BLOCK:		STATE 						{$$=$1;
								if(strcmp($1->token, "if") == 0||
								   strcmp($1->token, "for") == 0||
								   strcmp($1->token, "if-else") == 0||
								   strcmp($1->token, "while") == 0)
								 	addScope($1,NULL,NULL,newLabel(),NULL,NULL);}
		|DECEL 						{$$=$1;}
		|PROCEDURE 					{$$=$1;} 
		|';' 						{$$=makeNode("",NULL,NULL);};

BLOCK1:		'{' PROCEDURES CMNT DECELS STATES '}' CMNT	{$$=makeNode("{",$2,makeNode("", $4,makeNode("", $5,("}",NULL,NULL))));};

STATE:		IF '(' EXP ')'  BLOCK 				{$$=makeNode("if",makeNode("(", $3,makeNode(")",NULL,NULL)),$5);
								addScope($3,NULL,NULL,NULL,newLabel(),NULL);}%prec IF
		|IF '(' EXP ')' BLOCK ELSE BLOCK		{$$=makeNode("if-else",makeNode("", $3,makeNode("",NULL,NULL)),
										     makeNode("",$5,makeNode("",$7,NULL)));
								addScope($3,NULL,NULL,NULL,newLabel(),NULL);
								addScope($3,NULL,NULL,NULL,NULL,newLabel());}
		|WHILE CMNT '(' EXP ')' BLOCK  			{$$=makeNode("while",makeNode("(", $4,makeNode(")",NULL,NULL)),$6);
								addScope($$,NULL,NULL,NULL,newLabel(),NULL);
								addScope($$,NULL,NULL,NULL,NULL,newLabel());}
		|FOR CMNT '(' ASSIGN_STATE ';' EXP ';' ASSIGN_STATE ')' BLOCK 
					{$$= makeNode("for",makeNode("(",makeNode("",$4,$6),makeNode("",$8,makeNode(")",NULL,NULL))),$10);
					addScope($$,NULL,NULL,NULL,newLabel(),NULL);
					addScope($$,NULL,NULL,NULL,NULL,newLabel());}
		
		|ASSIGN_STATE ';' CMNT 				{$$=makeNode("assmnt_stmnt",$1,NULL);}
		|EXP ';' CMNT 					{$$=$1;}
		|RETURN EXP ';' CMNT 				{$$=makeNode("return",$2,NULL);}
		|BLOCK1						{$$=$1;}
		|DO CMNT '{' BLOCK '}' WHILE  '(' EXP ')' ';'   {$$=makeNode("do-while",makeNode("(", $8 ,makeNode(")",NULL,NULL)),$4);
								addScope($$,NULL,NULL,NULL,newLabel(),NULL);
								addScope($$,NULL,NULL,NULL,NULL,newLabel());};

ASSIGN_STATE:	LEFT_ASSIGN ASSING EXP 				{$$=makeNode("=",$1,$3);};

LEFT_ASSIGN: 	ID '[' EXP ']' 					{$$=makeNode($1, makeNode("[",$3,makeNode("]",NULL,NULL)), NULL);} 
		|ID 						{$$=makeNode($1,NULL,NULL);}
		|ADRS_EXP 					{$$=$1;}
		|POINTERS					{$$=$1;} 
		;

EXP:  		'(' EXP ')' 				{$$=makeNode("(",$2,makeNode(")",NULL,NULL));}
   	 	|EXP EQL EXP 				{$$=makeNode("==",$1,$3);}
		|EXP NOTEQL EXP 			{$$=makeNode("!=",$1,$3);}
		|EXP BIGGEREQL EXP 			{$$=makeNode(">=",$1,$3);}
		|EXP BIGGER EXP 			{$$=makeNode(">",$1,$3);}
		|EXP SMALLEREQL EXP 			{$$=makeNode("<=",$1,$3);}
		|EXP SMALLER EXP 			{$$=makeNode("<",$1,$3);}
		|EXP AND EXP 				{$$=makeNode("&&",$1,$3);
							 addScope($1,NULL,NULL,NULL,newLabel(),NULL);}
		|EXP OR EXP 				{$$=makeNode("||",$1,$3);
							addScope($1,NULL,NULL,NULL,NULL,newLabel());}
		|EXP PLUS EXP 				{$$=makeNode("+",$1,$3);}
		|EXP MINUS EXP 				{$$=makeNode("-",$1,$3);}
		|EXP MUL EXP 				{$$=makeNode("*",$1,$3);}
		|EXP DIV EXP 				{$$=makeNode("/",$1,$3);}
		|NOT EXP 				{$$=makeNode("!",$2,NULL);}
		|ADRS_EXP 				{$$=$1;}
		|POINTERS 				{$$=$1;}		
		|FUNCCALL CMNT 				{$$=$1;}		
		|DECIMAL_INTVal 			{$$=makeNode($1,makeNode("INT",NULL,NULL),NULL);}
		|HEX_INTVal 				{$$=makeNode($1,makeNode("HEX", NULL, NULL),NULL);}
		|CHARVal 				{$$=makeNode($1,makeNode("CHAR", NULL, NULL),NULL);}
		|REALVal 				{$$=makeNode($1,makeNode("REAL", NULL, NULL),NULL);}
		|STRVal 				{$$=makeNode($1,makeNode("STRING", NULL, NULL),NULL);}
		|FALSEVal  				{$$=makeNode($1,makeNode("BOOLEAN", NULL, NULL),NULL);}
		|TRUEVal 				{$$=makeNode($1,makeNode("BOOLEAN", NULL, NULL),NULL);}
		|'|' ID '|' 				{$$=makeNode("|",makeNode($2,NULL,NULL),makeNode("|",NULL,NULL));}
		|ID '[' EXP ']' 			{$$=makeNode("identifier",makeNode($1,makeNode("[",$3,makeNode("]",NULL,NULL)),NULL),NULL);}
		|ID 					{$$=makeNode("identifier",makeNode($1,NULL,NULL),NULL);}
		|NULLL 					{$$=makeNode("null",NULL,NULL);};

ADRS_EXP: 	REF ID 					{$$=makeNode("&",makeNode($2,NULL,NULL),NULL);}
		|REF '(' ID ')' 			{$$=makeNode("&",makeNode("(",makeNode($3,NULL,NULL),NULL),makeNode(")",NULL,NULL));}
		|REF ID '[' EXP ']' 
			{$$=makeNode("&", makeNode($2,makeNode("[",$4,makeNode("]",NULL,NULL)),NULL),NULL);}
		|REF '(' ID '[' EXP ']' ')' 
			{$$=makeNode("&",makeNode("(",makeNode($3,makeNode("[",$5,makeNode("]",NULL,NULL)),NULL),makeNode(")",NULL,NULL)),NULL);};

POINTERS: 	MUL ID 					{$$=makeNode("POINTER",makeNode($2,NULL,NULL),NULL);
							addScope($$,"",cutStr("*",$2),NULL,NULL,NULL);}
		| MUL '(' EXP ')' 			{$$=makeNode("POINTER",makeNode("(",$3,NULL),makeNode(")",NULL,NULL));
							addScope($$,$3->SCOPE,cutStr("*",$3->var),NULL,NULL,NULL);}
		| MUL ID '[' EXP ']' 			{$$=makeNode($1, makeNode($2,makeNode("[",$4,makeNode("]",NULL,NULL)),NULL), NULL);};

EXP_LIST: 	EXP ',' EXP_LIST 			{$$=makeNode("",$1,makeNode(",",$3,NULL));} 
		|EXP 					{$$=makeNode("",$1,NULL);}
		| 					{$$=NULL;};

FUNCCALL_EXP:	'(' EXP_LIST ')' 			{$$=$2;};

FUNCCALL: 	ID FUNCCALL_EXP 			{$$=makeNode("Call func",makeNode($1,NULL,NULL),makeNode("ARGS",$2,NULL));};
%%



int main()
{
	int ans= yyparse();
	FILE * f=fopen("output.txt","w+");
	if(ans==0)
	{
	printf(" The Syntax and Semantics Are Valid\n\n"); 
	}
	fprintf(f,"%s",start->SCOPE);
	/*printf("%s",start->SCOPE);*/
	return ans;	

	
	/*int res = yyparse();
	if(res==0)
		printf("Successs ,the Syntax and Semantics are correct\n\n"); 
	return res;	*/
}

void addVarible(Args * arguments,int countvars,int isArg,ScopeN * curScope){
	if(countvars==0)
	return;
	Var* tmp;
	ScopeN * scopes=curScope;

	if(scopes->var==NULL)
	{ 
		scopes->var=(Var*) malloc(sizeof(Var)*countvars);
	}
	else
	{
		tmp=scopes->var;
		scopes->var=(Var*) malloc(sizeof(Var)*(scopes->VaribleCount+countvars));
		for(int i=0;i<scopes->VaribleCount;i++)
		{
			for(int j=0;j<countvars;j++)
			{
				if(strcmp(tmp[i].name,arguments[j].name)==0 )
				{
					printf("ERROR , cannot be the same varible %s in same scope\n",tmp[i].name);
					ScopeN * t=scopes->preScope;
					while(t->preScope!=NULL && t->preScope->Fcount==0)
						t=t->preScope;
					exit(1);
				}
			}
			scopes->var[i]=tmp[i];	
		}
	}
	for(int j=0;j<countvars;j++)
	{

		scopes->var[scopes->VaribleCount].name=arguments[j].name;
		scopes->var[scopes->VaribleCount].value=NULL;
		scopes->var[scopes->VaribleCount].isArg=isArg;
		scopes->var[scopes->VaribleCount].length=arguments[j].length;
		scopes->var[(scopes->VaribleCount)++].type=arguments[j].type;
	}

}

char * expressionType(node * tree,ScopeN* curScope){
	char* msg=(char*)malloc(sizeof(char)*7);
	msg="";
	if(strcmp(tree->token,"null")==0)
		msg="NULL";
	else
	if(tree->left!=NULL){
		if(strcmp(tree->left->token,"INT")==0)
			msg= "int";
		if(strcmp(tree->left->token,"HEX")==0)
			msg= "hex";
		if(strcmp(tree->left->token,"CHAR")==0)
			msg= "char";
		if(strcmp(tree->left->token,"REAL")==0)
			msg= "real";
		if(strcmp(tree->left->token,"STRING")==0)
			msg= "string";
		if(strcmp(tree->left->token,"BOOLEAN")==0)
			msg= "boolean";
		if(strcmp(tree->token,"!")==0){
			if(strcmp(expressionType(tree->left,curScope),"boolean")==0)
				msg="boolean";
			else{
				printf("ERROR, you cannot use operator ! only on boolean type\n");
				exit(1);
			}
		}
		if(strcmp(tree->token,"|")==0){
			if(strcmp(expressionType(tree->left,curScope),"string")==0){
				msg="int";
			}
			else{ 
				printf("ERROR, you can use operator | only on string type in function %s",globalScope->func[globalScope->Fcount-1]->name);
				exit(1);
			}
		}
		if(strcmp(tree->token,"==")==0||strcmp(tree->token,"!=")==0)
		{
			if(strcmp(expressionType(tree->left,curScope),expressionType(tree->right,curScope))==0&&strcmp(expressionType(tree->right,curScope),"string")!=0)
			msg="boolean";
			else{
				printf("ERROR, you cannot use operator %s between %s and %s \n",tree->token,expressionType(tree->left,curScope),expressionType(tree->right,curScope));
				exit(1);
			}
		}

		if(strcmp(tree->token,">=")==0||strcmp(tree->token,">")==0||strcmp(tree->token,"<=")==0||strcmp(tree->token,"<")==0)
		{
			if((strcmp(expressionType(tree->left,curScope),"int")==0||strcmp(expressionType(tree->left,curScope),"real")==0)&&(strcmp(expressionType(tree->right,curScope),"int")==0||strcmp(expressionType(tree->right,curScope),"real")==0))
			msg="boolean";
			else{
				printf("ERROR, you cannot use operator %s between %s and %s \n",tree->token,expressionType(tree->left,curScope),expressionType(tree->right,curScope));
				exit(1);
			}
		}

		if(strcmp(tree->token,"&&")==0||strcmp(tree->token,"||")==0)
		{

			if(strcmp(expressionType(tree->left,curScope),expressionType(tree->right,curScope))==0&&strcmp(expressionType(tree->right,curScope),"boolean")==0)
			msg="boolean";
			else{
				printf("ERROR, you cannot use operator %s between %s and %s \n",tree->token,expressionType(tree->left,curScope),expressionType(tree->right,curScope));
				exit(1);
			}
			

		}
		if(strcmp(tree->token,"-")==0||strcmp(tree->token,"+")==0)
		{
			
			if((strcmp(expressionType(tree->left,curScope),"int")==0||strcmp(expressionType(tree->left,curScope),"real")==0)&&(strcmp(expressionType(tree->right,curScope),"int")==0||strcmp(expressionType(tree->right,curScope),"real")==0))
			{
				if(strcmp(expressionType(tree->left,curScope),expressionType(tree->right,curScope))==0&&strcmp(expressionType(tree->left,curScope),"int")==0){
					
					msg="int";
				}
				else{
				
					msg="real";
				}
			}

			if(strcmp(expressionType(tree->right,curScope),"int")==0&&(strcmp(expressionType(tree->left,curScope),"char*")==0||strcmp(expressionType(tree->right,curScope),"int*")==0||strcmp(expressionType(tree->right,curScope),"real*")==0)){
				
				msg=expressionType(tree->left,curScope);
				
			}
			else if(strcmp(msg,"")==0)
			{
				printf("ERROR, you cannot use operator %s between %s and %s \n",tree->token,expressionType(tree->left,curScope),expressionType(tree->right,curScope));
				exit(1);
			}

		}
		if(strcmp(tree->token,"*")==0||strcmp(tree->token,"/")==0)
		{
			if((strcmp(expressionType(tree->left,curScope),"int")==0||strcmp(expressionType(tree->left,curScope),"real")==0)&&(strcmp(expressionType(tree->right,curScope),"int")==0||strcmp(expressionType(tree->right,curScope),"real")==0))
			{
				
				if(strcmp(expressionType(tree->left,curScope),expressionType(tree->right,curScope))==0&&strcmp(expressionType(tree->left,curScope),"int")==0)
				msg="int";
				else
				msg="real";
			}
			else 
			{
				printf("ERROR, you cannot use operator %s between %s and %s \n\n",tree->token,expressionType(tree->left,curScope),expressionType(tree->right,curScope));
				exit(1);
			}
		}
		if(strcmp(tree->token,"&")==0)
		{
			if(strcmp(tree->left->token,"(")==0)
				msg=expressionType(tree->left->left,curScope);
			else{
				msg=expressionType(tree->left,curScope);
				
				}
			if(strcmp(msg,"char")==0)
			msg="char*";
			else
			if(strcmp(msg,"int")==0)
			msg="int*";
			else
			if(strcmp(msg,"real")==0)
			msg="real*";
			else
			{
				printf("ERROR, you cannot use operator  %s on %s \n",tree->token,msg);
				exit(1);
			}
		}
		if(strcmp(tree->token,"POINTER")==0)
		{
			if(strcmp(tree->left->token,"(")==0)
				msg=expressionType(tree->left->left,curScope);
			else
				msg=expressionType(tree->left,curScope);
			
			if(strcmp(msg,"char*")==0)
			msg="char";
			else
			if(strcmp(msg,"int*")==0)
			msg="int";
			else
			if(strcmp(msg,"real*")==0)
			msg="real";
			else
			{
				printf("ERROR, you cannot use %s on %s \n",tree->token,msg);
				exit(1);
			}
		}
		if(strcmp(tree->token,"(")==0)
			msg=expressionType(tree->left,curScope);
		if(strcmp(tree->token,"Call func")==0)
			msg=functionInScopes(tree,curScope,NULL);
		
	}
	if(strcmp(msg,"")==0)
		msg=findVarible(tree,curScope);

	return msg;
}


ScopeN* makeScope(char* name)
{	

	ScopeN *newScope = (ScopeN*)malloc(sizeof(ScopeN));
	newScope->name=name;
	newScope->var=NULL;
	newScope->VaribleCount=0;
	newScope->func=NULL;
	newScope->Fcount=0;
	newScope->nextScope=NULL;
	newScope->preScope=NULL;
	
	return newScope;
}



void addFunction(char * name,Args * arguments,node *returnType, int argumentNum,ScopeN * curScope){
	Function** tmp;
	ScopeN * scopes = curScope;
	for(int i=0;i<argumentNum;i++)
		for(int j=0;j<argumentNum;j++)
	if(i!=j && strcmp(arguments[j].name,arguments[i].name)==0 )
	{
		printf("ERROR, there are the same arguments %s in function %s\n",arguments[i].name,name);
		exit(1);
	}
	if(scopes->func==NULL)
	{ 
		
		scopes->func=(Function**) malloc(sizeof(Function*));
	}
	else 
	{
		
		tmp=scopes->func;
		scopes->func=(Function**) malloc(sizeof(Function*)*(scopes->Fcount+1));
		for(int i=0;i<scopes->Fcount;i++)
		{
				
				if(strcmp(tmp[i]->name,name)==0 )
				{
					
					printf("ERROR, there's already function %s in the same scope \n",tmp[i]->name);
					exit(1);
				}
				scopes->func[i]=tmp[i];
		}
	}	
		scopes->func[scopes->Fcount]=(Function*) malloc(sizeof(Function));
		scopes->func[scopes->Fcount]->name=name;
		scopes->func[scopes->Fcount]->args=arguments;
		if(returnType==NULL){
			scopes->func[scopes->Fcount]->returnType=NULL;
		}
		else{
		if(strcmp(returnType->token,"string")==0)
			{
				printf("ERORR,return type function %s cannot be string\n",name);
				exit(1);
			}
		scopes->func[scopes->Fcount]->returnType=returnType->token;
		}
		
		scopes->func[scopes->Fcount]->argumentNum=argumentNum;
		scopes->func[scopes->Fcount]->findreturn=false;
		++(scopes->Fcount); 

}




node* makeNode (char *token, node *left, node *right)
{
	node *newnode = (node*)malloc(sizeof(node));
	newnode->left=left;
	newnode->right=right;
	newnode->token=token;
	return newnode;
}

int yyerror(char *e)
{
	int yydebug=1;
	fflush(stdout);
	fprintf(stderr,"Error %s at line %d\n" ,e,yylineno);
	fprintf(stderr, "Does not accept '%s'\n",yytext);
	
	return 0;
}

ScopeN* final_Scope(ScopeN * scopes)
{
	ScopeN * curScope=scopes;
	if(curScope!=NULL)
	while(curScope->nextScope!=NULL)
		curScope=curScope->nextScope;
	return curScope;
}



void semantic(node *tree,ScopeN * curScope){
	
	if(strcmp(tree->token, "=") == 0 )
	{
		if(!(strcmp(expressionType(tree->right,curScope),"NULL")==0&& (strcmp(expressionType(tree->left,curScope),"real*")==0||
strcmp (expressionType( tree->left, curScope),"int*")==0||strcmp(expressionType(tree->left,curScope),"char*")==0)))
		if(strcmp(expressionType(tree->left,curScope),expressionType(tree->right,curScope))!=0)
		{
			printf("ERORR, you cannot assign  %s to %s in  %s\n",expressionType(tree->right,curScope),expressionType(tree->left,curScope),globalScope->func[globalScope->Fcount-1]->name);
			exit(1);
		}
	}
	else if(strcmp(tree->token, "var") == 0)
	{
		int VaribleCount=0;
		Args * var=makeArguments(tree,&VaribleCount);
		addVarible(var,VaribleCount,0,curScope);
	}
	else if(strcmp(tree->token, "if") == 0)
	{
		if(strcmp(expressionType(tree->left->left,curScope),"boolean")!=0)
		{
			printf("ERROR, the condition in if has to be boolean\n");
			exit(1);
		}

		if(strcmp(tree->right->token,"{")!=0)
		{
			pushScopes(curScope,tree->token);
			if (tree->left) 
				semantic(tree->left,final_Scope( curScope->nextScope));
	
			if (tree->right)
				semantic(tree->right,final_Scope( curScope->nextScope));
        	scope--;
			return;
		}
		
	}
	else if(strcmp(tree->token, "while") == 0)
	{
		
		if(strcmp(expressionType(tree->left->left,curScope),"boolean")!=0)
		{
			printf("ERROR, the condition in while has to be boolean\n");
			exit(1);
		}

		if(strcmp(tree->right->token,"{")!=0)
		{
			pushScopes(curScope,tree->token);
			if (tree->left) 
				semantic(tree->left,final_Scope( curScope->nextScope));
	
			if (tree->right)
				semantic(tree->right,final_Scope( curScope->nextScope));
        	scope--;
			return;
		}
		
		
		
	}
	else if(strcmp(tree->token, "do-while") == 0)
	{
		
		if(strcmp(expressionType(tree->left->left,curScope),"boolean")!=0)
		{
			printf("ERROR, the condition in do-while has to be boolean\n");
			exit(1);
		}

		if(strcmp(tree->right->token,"{")!=0)
		{
			pushScopes(curScope,tree->token);
			if (tree->left) 
				semantic(tree->left,final_Scope( curScope->nextScope));
	
			if (tree->right)
				semantic(tree->right,final_Scope( curScope->nextScope));
        	scope--;
			return;
		}
		
		
		
	}
			else if(strcmp(tree->token, "for") == 0)
	{

	 if(strcmp(expressionType(tree->left->left->right,curScope),"boolean")!=0)
		{
			printf("ERROR, the condition in for has to be boolean\n");
			exit(1);
		}

		semantic(tree->left->left->left,curScope);

		semantic(tree->left->right->left,curScope);

		if(strcmp(tree->right->token,"{")!=0)
		{

			pushScopes(curScope,tree->token);

			if (tree->left) 
				semantic(tree->left,final_Scope( curScope->nextScope));
	
			if (tree->right)
				semantic(tree->right,final_Scope( curScope->nextScope));
        	scope--;
			return;
		}

		
		
	}
	
	else if(strcmp(tree->token, "FUNC") == 0 )
	{
		
        int count=0;
		Args * arg=makeArguments(tree->left->right->left,&count);
		addFunction(tree->left->token,arg,tree->left->right->right->left,count,curScope);
		pushScopes(curScope,tree->token);
		addVarible(arg,count,1,final_Scope(curScope));
	if (tree->left) 
		semantic(tree->left,final_Scope( curScope->nextScope));
	
	if (tree->right)
		semantic(tree->right,final_Scope( curScope->nextScope));
		if(curScope->func[curScope->Fcount-1]->findreturn==false && tree->left->right->right->left->token!="void")
		{
			printf("ERORR, there is no return in func %s\n",tree->left->token);
			exit(1);
		}
        scope--;		
		return;
	}
	
	
	else if(strcmp(tree->token, "Call func") == 0)
	{
		int count=0;
		functionInScopes(tree,curScope, &count);
		tree->count=count;	
	}
	else if(strcmp(tree->token, "CODE") == 0)
	{
		
		pushScopes(NULL,tree->token);
	if (tree->left) 
		semantic(tree->left,globalScope);
	
	if (tree->right)
		semantic(tree->right,globalScope);
		scope--;
		return;
	}
	/*
	else if(strcmp(tree->left->left->token, "ARGSM") == 0){
			printf("ERROR, main cannot have arguments\n");
			exit(1);
		}*/
	else if((strcmp(tree->token, "MAIN") == 0))
	{
		
        int count=0;
		Args * arg=makeArguments(tree->left->left,&count);
		addFunction(tree->left->token,arg,tree->left->left,count,curScope);
		pushScopes(curScope,tree->token);
		addVarible(arg,count,1,final_Scope(curScope));
		 
		
	if (tree->left) 
		semantic(tree->left,final_Scope( curScope->nextScope));
	
	if (tree->right)
		semantic(tree->right,final_Scope( curScope->nextScope));
		scope--;	
	
		return;
    }

	else if((strcmp(tree->token, "TYPEM") == 0))
		{
			printf("ERROR, main type has to be void\n");
			exit(1);
		}

		
	
	else if(strcmp(tree->token, "if-else") == 0)
	{
		if(strcmp(expressionType(tree->left->left,curScope),"boolean")!=0)
		{
			printf("ERORR, if condition must be of type boolean\n");
			exit(1);
		}

		if(strcmp(tree->right->left->token,"{")!=0)
		{
			
			pushScopes(curScope,tree->token);
			semantic(tree->right->left,final_Scope( curScope->nextScope));
			scope--;
			pushScopes(curScope,tree->token);
			semantic(tree->right->right->left,final_Scope( curScope->nextScope));
        	scope--;
			return;
		}
	}
	
	else if(strcmp(tree->token, "return") == 0)
	{
		
		ScopeN * tmp= curScope;
		int flag=true;
		while(strcmp(tmp->name,"FUNC")!=0&&strcmp(tmp->name,"MAIN")!=0&&strcmp(tmp->name,"CODE")!=0)
		{
			tmp=tmp->preScope;
			flag=false;
		}
		if(flag==false)
		{
			if(strcmp(expressionType(tree->left,curScope),tmp->preScope->func[tmp->preScope->Fcount-1]->returnType))
			{
			printf("ERORR,return type does not match\n");
			printf("%s ,%s %s\n",expressionType(tree->left,curScope),tmp->preScope->func[tmp->preScope->Fcount-1]->returnType,tmp->preScope->func[tmp->preScope->Fcount-1]->name);
			exit(1);
			}
		}
		else
		{
			if(tmp->preScope->func[tmp->preScope->Fcount-1]->returnType!=NULL)
			{
				if(0==strcmp(expressionType(tree->left,curScope),tmp->preScope->func[tmp->preScope->Fcount-1]->returnType))
				{
					tmp->preScope->func[tmp->preScope->Fcount-1]->findreturn=true;
				}
				else
				{
		
					printf("ERORR,return type does not match .");
					printf("function %s return %s and not %s\n",tmp->preScope->func[tmp->preScope->Fcount-1]->name,expressionType(tree->left,curScope),tmp->preScope->func[tmp->preScope->Fcount-1]->returnType);
						
					exit(1);
				}
			}
			else
			{
				printf("ERORR, there cannot be return in main function \n");
				exit(1);
			}  
		}  
	}
	else if(strcmp(tree->token, "{") == 0)
	{
		pushScopes(curScope,tree->token);
		if (tree->left) 
			semantic(tree->left,final_Scope( curScope->nextScope));
		
		if (tree->right)
			semantic(tree->right,final_Scope( curScope->nextScope));
			scope--;
			return;			
	}
	else if(strcmp(tree->token, "identifier") == 0 )
		findVarible(tree->left,curScope);
	if (tree->left) 
		semantic(tree->left,curScope);
	
	if (tree->right)
		semantic(tree->right,curScope);
}
//--------------------------------------semantic

void pushScopes(ScopeN* from,char* name)
{
	ScopeN * point;
	if(globalScope==NULL){
		globalScope=makeScope(name);
	}
	else{
		point=globalScope;
		while(point->nextScope!=NULL){
			point=point->nextScope;
			
		}
		point->nextScope=makeScope(name);
		point->nextScope->preScope=from;
	}
}
//----------------------------------------------------pushScopes

char* functionInScopes(node * tree,ScopeN * curScope,int * countParams)
{
	
	ScopeN* tmp=curScope;
	Args* arguments;
	bool find = false, flag = true;
	while(tmp!=NULL)
	{
		for(int i=0;i<tmp->Fcount;i++)
		if(strcmp(tree->left->token,tmp->func[i]->name)==0)
		{
			find=true;
			flag=true;
			int count=0;
			arguments=functionArguments(curScope,tree->right->left,&count);
			if(count==tmp->func[i]->argumentNum)
			{
				for(int j=0,t=count-1;j<count;j++,t--)
				{
					if(strcmp(arguments[j].type,tmp->func[i]->args[t].type)!=0)
						flag=false;
				}
				if(flag==true)
					if(countParams!= NULL)
						*countParams = popParameters(arguments,count);
					return tmp->func[i]->returnType;
			}
		}
		tmp=tmp->preScope;
	}
	
	printf("ERROR,function %s is undefined ! \n",tree->left->token);
	if(find==true){
		printf("ERROR, there is a function with the same name containing different arguments\n");
		exit(1);
	}
}
//---------------------------------------functionInScopes

char *findVarible(node * tree,ScopeN * curScope)
{
	ScopeN* tmp = curScope;
	if(strcmp(tree->token,"identifier")==0)
		tree=tree->left;
	while(tmp!=NULL)
	{
		
		for(int i=0;i<tmp->VaribleCount;i++)
		if(strcmp(tree->token,tmp->var[i].name)==0)
		{
			
			if(tree->left!=NULL && strcmp(tree->left->token,"[")==0)
			{
				if(strcmp(tmp->var[i].type,"string")==0)
					if(strcmp(expressionType(tree->left->left,curScope),"int")==0)
					{
						return "char";
					}
					else
					{
						printf("ERORR, index in string can be only int \n");
						exit(1);
					}
				else
				{
					printf("ERORR,you can use opertor [ ] only on string type \n");
					exit(1);
				}

			}
			else
			return tmp->var[i].type;

		}
		tmp=tmp->preScope;
	}
	printf("ERORR, varible %s undefined in function %s\n ",tree->token,globalScope->func[globalScope->Fcount-1]->name);
	exit(1);	
}
//------------------------findVarible

Args * makeArguments(node *tree,int *count){//--------------checked
	Args *arr=NULL,arr2[50];
	char* type,*length;
	if(tree!=NULL)
	{
		node * temp1=tree,*tmp=tree;
		do{
		if(strcmp(temp1->token, "")==0)
		{
			tmp=temp1->right->left;
			temp1=temp1->left;
			
			
			if(strcmp(tmp->token, "(")==0||strcmp(tmp->token, "var")==0)
			{
				type=tmp->left->token;
				if(tmp->left->left!=NULL)
					length=tmp->left->left->left->token;
				node * tmptree;
				tmptree=tmp->right->left;
				do{
				arr2[*count].name=tmptree->token;
				arr2[*count].type=type;
				arr2[*count].length=length;
				(*count)++;
				if(tmptree->left==NULL)
					tmptree=NULL;
				else
					tmptree=tmptree->left->left;
				}while(tmptree!=NULL);
			}
		}
		}while(strcmp(temp1->token, "(")!=0&&strcmp(tmp->token, "var")!=0);
		tmp=temp1;
		if(strcmp(tmp->token, "(")==0||strcmp(tmp->token, "var")==0)
		{
			type=tmp->left->token;
			node * tmptree;
			if(strcmp(tmp->token, "var")==0)
			tmptree=tmp->right;
			else
			tmptree=tmp->right->left;
			if(tmp->left->left!=NULL)
			length=tmp->left->left->left->token;
			do{
			arr2[*count].name=tmptree->token;
			arr2[*count].type=type;
			arr2[*count].length=length;
			(*count)++;
			if(tmptree->left==NULL)
				tmptree=NULL;
			else
				tmptree=tmptree->left->left;
			}while(tmptree!=NULL);
		}
		arr=(Args*)malloc(sizeof(Args)*(*count));
		for(int i=0;i<*count;i++)
		{
			for(int j=0;j<*count;j++){
			}
			arr[i].name=arr2[i].name;
			arr[i].type=arr2[i].type;
		}
	}
	return arr;
}


Args* functionArguments(ScopeN * curScope,node *tree,int * count)
{
	Args  *arr=NULL,arr2[50];
	char* type,*length;
	while(tree!=NULL)
	{
		arr2[(*count)++].type=expressionType(tree->left,curScope);
		if(tree->right!=NULL)
			tree=tree->right->left;
		else
			tree=NULL;

	}
	arr=(Args*)malloc(sizeof(Args)*(*count));
	for(int i = 0; i<*count; i++)
		arr[i].type=arr2[i].type;
	return arr;
}


int popParameters(Args * args,int count){
	int size=0;
	for(int i =0;i<count;i++)
	{
		if(strcmp(args[i].type,"int")==0)
			size += 4;
		else if(strcmp(args[i].type,"char")==0)
			size += 1;
		else if(strcmp(args[i].type,"real")==0)
			size += 8;
		else if(strcmp(args[i].type,"string")==0)
			size += atoi(args[i].length);
		else if(strcmp(args[i].type,"boolean")==0)
			size += 4;
		else if(strcmp(args[i].type,"int*")==0)
			size += 4;
		else if(strcmp(args[i].type,"char*")==0)
			size += 4;
		else if(strcmp(args[i].type,"real*")==0)
			size += 4;
	}
	return size;
}

void make3AC(node * tree)
{ 
	if(strcmp(tree->token, "=") == 0 )
	{ 	 
		if(tree->left!=NULL)
			make3AC(tree->left);
		if(tree->right!=NULL)
			make3AC(tree->right);
		addScope(tree,cutStr(tree->right->SCOPE,generate(tree->left->var,"=",tree->right->var,"","")),NULL,NULL,NULL,NULL); 
		return;  
	}
	else if(strcmp(tree->token, "procedures") == 0)
	{  
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL)
			make3AC(tree->right);
		if(tree->left!=NULL) 
			addScope(tree,cutStr(tree->left->SCOPE,tree->right->SCOPE),NULL,NULL,NULL,NULL);
		else addScope(tree,tree->right->SCOPE,NULL,NULL,NULL,NULL);
    		return;
	}
	else if(strcmp(tree->token, "if") == 0)
	{ 
		if(tree->left->left)
			addScope(tree->left->left,NULL,NULL,NULL,NULL,tree->label);
		if(tree->right)
			addScope2(tree->right,NULL,NULL,tree->label,NULL,NULL);
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		addScope(tree,cutStr(tree->left->left->SCOPE,cutStr(space(tree->left->left->label),
				cutStr(space(tree->left->left->labelTrue),cutStr(tree->right->SCOPE,
					space(tree->labelTrue))))),NULL,NULL,NULL,NULL);
		return;
	}
	else if(strcmp(tree->token, "if-else") == 0)
	{ 
		if(tree->right->left)
			addScope(tree->right->left,NULL,NULL,tree->label,NULL,NULL);			
		if(tree->right->right->left)
			addScope2(tree->right->right->left,NULL,NULL,tree->label,NULL,tree->label);
		if(tree->right->left)
			addScope2(tree->right->left,NULL,NULL,tree->label,NULL,tree->label);
		
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		addScope(tree,cutStr(cutStr(tree->left->left->SCOPE,cutStr(space(tree->left->left->labelTrue),
			tree->right->left->SCOPE)),cutStr(cutStr("goto ",cutStr(cutStr(tree->label,"\n"),
			cutStr(space(tree->left->left->labelFalse),tree->right->right->left->SCOPE))),
			space(tree->label))),NULL,NULL,NULL,NULL);
		return;
	}
	else if(strcmp(tree->token, "while") == 0)
	{ 
		if(tree->left->left)
			addScope(tree->left->left,NULL,NULL,NULL,tree->labelFalse,tree->label);
		if(tree->right)
			addScope2(tree->right,NULL,NULL,tree->label,NULL,NULL);
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		addScope(tree,cutStr(cutStr(cutStr(space(tree->labelTrue),tree->left->left->SCOPE),
			space(tree->labelFalse)),cutStr(tree->right->SCOPE,
		   	cutStr(cutStr("\tgoto ",cutStr(tree->labelTrue,"\n")),space(tree->label)))),NULL,NULL,NULL,NULL);
		return ;
	}
	else if(strcmp(tree->token, "do-while") == 0)
	{ 
		if(tree->left->left)
			addScope(tree->left->left,NULL,NULL,NULL,tree->labelFalse,tree->label);
		if(tree->right)
			addScope2(tree->right,NULL,NULL,tree->label,NULL,NULL);
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		addScope(tree,cutStr(cutStr(cutStr(space(tree->labelTrue),tree->left->left->SCOPE),
			space(tree->labelFalse)),cutStr(tree->right->SCOPE,
		   	cutStr(cutStr("\tgoto ",cutStr(tree->labelTrue,"\n")),space(tree->label)))),NULL,NULL,NULL,NULL);
		return ;
	}
	else if(strcmp(tree->token, "stmnts") == 0)
	{  
		if(tree->right!=NULL){
			if(strcmp(tree->right->token, "for") == 0||strcmp(tree->right->token, "if-else") == 0||
			   strcmp(tree->right->token, "while") == 0||strcmp(tree->right->token, "do-while") == 0)
				addScope2(tree->right,NULL,NULL,tree->label,NULL,NULL);
		}
        	if(tree->right!=NULL && tree->left!=NULL){
        		if(strcmp(tree->left->right->token, "if") == 0||strcmp(tree->left->right->token, "for") == 0||
			   strcmp(tree->left->right->token, "if-else") == 0||strcmp(tree->left->right->token, "while") == 0
				||strcmp(tree->left->right->token, "do-while") == 0)
				addScope2(tree->right,NULL,NULL,NULL,tree->left->right->label,NULL);
		}
		if(tree->left!=NULL)
			make3AC(tree->left); 
		if(tree->right!=NULL)
			make3AC(tree->right);
		if(tree->right!=NULL && tree->left!=NULL)
                	if((strcmp(tree->right->token, "while") == 0||strcmp(tree->right->token, "for") == 0||
			    strcmp(tree->right->token, "do-while") == 0 ||
			    strcmp(tree->right->token, "if-else") == 0)&&(strcmp(tree->left->right->token, "if") == 0||
			    strcmp(tree->left->right->token, "for") == 0||strcmp(tree->left->right->token, "if-else") == 0||
			    strcmp(tree->left->right->token, "while") == 0|| strcmp(tree->left->right->token, "do-while") == 0))
                    		addScope(tree,cutStr(tree->left->SCOPE,&tree->right->SCOPE[8]),NULL,NULL,NULL,NULL);
                    	else
				addScope(tree,cutStr(tree->left->SCOPE,tree->right->SCOPE),NULL,NULL,NULL,NULL);
		else if(tree->right!=NULL)
            	{
		        if(strcmp(tree->right->token, "for") == 0||strcmp(tree->right->token, "if-else") == 0||
			   strcmp(tree->right->token, "while") == 0||strcmp(tree->right->token, "do-while") == 0)
		        	addScope(tree,tree->right->SCOPE,NULL,NULL,NULL,NULL);
		        else        
				addScope(tree,cutStr(tree->right->SCOPE ,space(tree->right->label)),NULL,NULL,NULL,NULL);
            	}else
			addScope(tree,"",NULL,NULL,NULL,NULL);	
		return;	
	}
	else if(strcmp(tree->token, "for") == 0)
	{ 
		if(tree->left->left->right)
			addScope(tree->left->left->right,NULL,NULL,NULL,tree->labelFalse,tree->label);
		if(tree->right)
			addScope(tree->right,NULL,NULL,tree->label,NULL,NULL);
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		addScope(tree,cutStr(cutStr(cutStr(tree->left->left->left->SCOPE,space(tree->labelTrue)),
			      tree->left->left->right->SCOPE), cutStr(cutStr(cutStr(space(tree->labelFalse),
			      tree->right->SCOPE),tree->left->right->left->SCOPE),
			      cutStr("\tgoto ",cutStr(tree->labelTrue,cutStr("\n",space(tree->label)))))),NULL,NULL,NULL,NULL);
		return;
	}
  
	if(strcmp(tree->token, "MAIN") == 0)
	{ 
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		addScope(tree,cutStr(" Main:\n",tree->left->right->SCOPE),NULL,NULL,NULL,NULL);
          	return;   
    	}  
	else if(strcmp(tree->token, "FUNC") == 0)
	{
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 	
			make3AC(tree->right);
		char*x;
		asprintf(&x," %s:\n",tree->left->token);
		addScope(tree,cutStr(x,tree->right->left->SCOPE),NULL,NULL,NULL,NULL);
		return;
	}
	else if(strcmp(tree->token, "expr_list") == 0)
	{
		if(tree->left!=NULL) 
			make3AC(tree->left);
 		if(tree->right!=NULL) 
			make3AC(tree->right);
		if(tree->right==NULL) 
			addScope(tree,cutStr(tree->left->SCOPE,
				cutStr("PushParam ",cutStr(tree->left->var,"\n"))),NULL,NULL,NULL,NULL);
		else
			addScope(tree,cutStr(cutStr(tree->left->SCOPE,cutStr
				("PushParam ",cutStr(tree->left->var,"\n"))),tree->right->left->SCOPE),NULL,NULL,NULL,NULL);
	}	
	else if(strcmp(tree->token, "Call func") == 0)
	{ 
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		char * x,*parm=(char*)malloc(sizeof(char));
		if(tree->right->left==NULL)
			strcpy(parm,"");
		else
			parm=tree->right->left->SCOPE;
		addScope(tree,NULL,newVarible(),NULL,NULL,NULL);
		asprintf(&x,"%s%s =  %s()\n‪\tPopParams %d‬‬‬‬\n",parm,tree->var,tree->left->token,tree->count); 
		addScope(tree,x,NULL,NULL,NULL,NULL);
		return;
	}
	else if(strcmp(tree->token, "CODE") == 0)
	{	
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		if(tree->left)
			addScope(tree,cutStr(tree->left->SCOPE,tree->right->SCOPE),NULL,NULL,NULL,NULL);
		else
			addScope(tree,tree->right->SCOPE,NULL,NULL,NULL,NULL);
		tree->SCOPE=strReplac(tree->SCOPE, "\n\n", "\n") ;
		char x='a',*y,*z;

		while (x<='z')
		{
			asprintf(&y,"\n%c",x);
			asprintf(&z,"\n\t%c",x);
			tree->SCOPE=strReplac(tree->SCOPE, y, z);
			x++;
		}
		x='A';
		while (x<='Z')
		{
			asprintf(&y,"\n%c",x);
			asprintf(&z,"\n\t%c",x);
			tree->SCOPE=strReplac(tree->SCOPE, y, z) ;
			x++;
		}
		return;
	}
    	else if(strcmp(tree->token, "BODY") == 0)
	{ 	
		if(tree->left!=NULL) 
			make3AC(tree->left);
		if(tree->right!=NULL)
			make3AC(tree->right);
		if(tree->right->right->left)
		{
			if(tree->right->right->left->SCOPE[strlen(cutStr(tree->right->right->left->SCOPE,"\0"))-2]==':')
				addScope(tree,cutStr(cutStr("\tBeginFunc‬‬\n",
						tree->right->right->left->SCOPE),"EndFunc\n"),NULL,NULL,NULL,NULL);
			else
			{
		   		addScope(tree,cutStr(cutStr("\tBeginFunc‬‬\n",tree->right->right->left
					->SCOPE),"\tEndFunc\n"),NULL,NULL,NULL,NULL);
			}
		}
		else
			addScope(tree,cutStr("\tBeginFunc‬‬\n","\tEndFunc\n"),NULL,NULL,NULL,NULL);
		return;
	}
    	else if(strcmp(tree->token, "MAIN") == 0) 
	{ 	 
		if(tree->left!=NULL) 
			
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		addScope(tree,cutStr("MAIN:\n",tree->left->right->SCOPE),NULL,NULL,NULL,NULL); 
          	return;   
    	} 
	        

	else if(strcmp(tree->token, "return") == 0)
	{
		if(tree->left!=NULL) 	
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		addScope(tree,cutStr(tree->left->SCOPE,generate("return",tree->left->var,"","","")),NULL,NULL,NULL,NULL);
		return;
	}
	else if(strcmp(tree->token, "{") == 0)
	{ 
		if(tree->right->right->left) 
			addScope(tree,NULL,NULL,tree->right->right->left->label,tree->right->right->left->labelTrue,
					tree->right->right->left->labelFalse); 
		if(tree->left!=NULL) 	
			make3AC(tree->left); 
		if(tree->right!=NULL) 	
			make3AC(tree->right);
		if(tree->right->right->left) 
			addScope(tree,tree->right->right->left->SCOPE,tree->right->right->left->var,NULL,NULL,NULL); 
		return;			
	}
	else if(strcmp(tree->token, "}") == 0)
	{ 	
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);        
    	}
	else if(strcmp(tree->token, "assmnt_stmnt") == 0)
	{ 	
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
                addScope(tree,tree->left->SCOPE,tree->left->var,tree->left->label,tree->left->labelTrue,tree->left->labelFalse); 
		return;       
    	}
   	else if(strcmp(tree->token, "+") == 0 || strcmp(tree->token, "*") == 0 ||  strcmp(tree->token, "-") == 0 || 
									strcmp(tree->token, "/") == 0 )
	{ 
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 	
			make3AC(tree->right);
		addScope(tree,NULL,newVarible(),NULL,NULL,NULL);
		addScope(tree,cutStr(cutStr(tree->left->SCOPE,tree->right->SCOPE),
			generate(tree->var,"=",tree->left->var,tree->token,tree->right->var)),NULL,NULL,NULL,NULL);
    		return;
	}
	else if(strcmp(tree->token, "&") == 0)
	{ 
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		if((tree->left->left == NULL))
			addScope(tree,"",cutStr("&",(tree->left->token)),NULL,NULL,NULL);
		else if(strcmp(tree->left->left->token,"[")==0)
		{
			char *x,*fv1,*fv2;
			asprintf(&fv1,"%s",newVarible()); 
			asprintf(&fv2,"%s",newVarible());
			asprintf(&x,"\t%s = &%s\n\t%s = %s + %s\n",fv1,tree->left->token,fv2,fv1,tree->left->left->left->var);
			addScope(tree,cutStr(tree->left->left->left->SCOPE,x),fv2,NULL,NULL,NULL);
		}
		else if (tree->left->left->left==NULL)
			addScope(tree,"",cutStr("&",(tree->left->left->token)),NULL,NULL,NULL);
		else
		{
			char *x,*fv1,*fv2;
			asprintf(&fv1,"%s",newVarible());
			asprintf(&fv2,"%s",newVarible()); 
			asprintf(&x,"\t%s = &%s\n\t%s = %s + %s\n",fv1,tree->left->left->token,fv2,fv1,tree->left->left->left->left->var); 
			addScope(tree,cutStr(tree->left->left->left->left->SCOPE,x),fv2,NULL,NULL,NULL);
		}
		return;
	}
	else if(strcmp(tree->token, "POINTER") == 0 )
	{ 
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		if((tree->left->left == NULL))
			addScope(tree,"",cutStr("*",(tree->left->token)),NULL,NULL,NULL);
		else
		{
			addScope(tree,"",cutStr("*",(tree->left->left->token)),NULL,NULL,NULL);
		}
		return;
	}
	else if(strcmp(tree->token, "==") == 0 || strcmp(tree->token, ">") == 0 || strcmp(tree->token, ">=") == 0 || 
				strcmp(tree->token, "<") == 0 || strcmp(tree->token, "<=") == 0 || strcmp(tree->token, "!=") == 0) 
	{ 
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right); 
		addScope(tree,cutStr(cutStr(tree->left->SCOPE,tree->right->SCOPE),cutStr
				(generate("if",tree->left->var,tree->token,tree->right->var,cutStr("goto ",cutStr(tree->labelTrue,"\n")))
				,cutStr("\tgoto ",cutStr(tree->labelFalse,"\n")))),NULL,NULL,NULL,NULL);
		return;
	}
	else if(strcmp(tree->token, "(") == 0)
	{
		addScope(tree->left,NULL,NULL,NULL,tree->labelTrue,tree->labelFalse);
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL)
			make3AC(tree->right);
		addScope(tree,tree->left->SCOPE,tree->left->var,NULL,NULL,NULL);
		return;
	}
	else if(strcmp(tree->token, "!") == 0)
	{ 
		addScope(tree->left,NULL,NULL,NULL,tree->labelTrue,tree->labelFalse);
		if(tree->left!=NULL) 
			make3AC(tree->left); 	
		if(tree->right!=NULL) 
			make3AC(tree->right);	
		addScope(tree,tree->left->SCOPE,NULL,NULL,NULL,NULL);
		return;
	}
	else if(strcmp(tree->token, "||") == 0) 
	{
		addScope(tree->left,NULL,NULL,NULL,tree->labelTrue,NULL);
		addScope(tree->right,NULL,NULL,NULL,tree->labelTrue,tree->labelFalse);
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		addScope(tree,cutStr(tree->left->SCOPE,cutStr(space(tree->left->labelFalse),
			tree->right->SCOPE)),NULL,NULL,NULL,NULL);
		return;
	}
	else if(strcmp(tree->token, "&&") == 0 )
	{
		addScope(tree->left,NULL,NULL,NULL,NULL,tree->labelFalse);
		addScope(tree->right,NULL,NULL,NULL,tree->labelTrue,tree->labelFalse);
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		addScope(tree,cutStr(tree->left->SCOPE,cutStr(space(tree->left->labelTrue),
				tree->right->SCOPE)),NULL,NULL,NULL,NULL);
		return;
	}
	else if(strcmp(tree->token, "null") == 0 )
	{ 
		if(tree->left!=NULL)
			make3AC(tree->left); 
		if(tree->right!=NULL) 	
			make3AC(tree->right);
		addScope(tree,"",tree->token,NULL,NULL,NULL);
		return;
	}	
	else if(strcmp(tree->token, "identifier") == 0 )
	{ 
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		if(tree->left->left==NULL)
			addScope(tree,"",tree->left->token,NULL,NULL,NULL);
		else
		{
			char *x,*fv1,*fv2; 
			asprintf(&fv1,"%s",newVarible()); 
			asprintf(&fv2,"%s",newVarible()); 
			asprintf(&x,"\t%s = &%s\n\t%s = %s + %s\n",fv1,tree->left->token,fv2,fv1,tree->left->left->left->var); 				
			addScope(tree,cutStr(tree->left->left->left->SCOPE,x),cutStr("*",fv2),NULL,NULL,NULL);
		}
		return;
	}
	else if((tree->left!=NULL)&&(strcmp(tree->left->token,"INT")==0||strcmp(tree->left->token,"HEX")==0||
			strcmp(tree->left->token,"CHAR")==0||strcmp(tree->left->token,"REAL")==0||strcmp(tree->left->token,"STRING")==0||
			strcmp(tree->left->token,"BOOLEAN")==0))
	{
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		if(strcmp(tree->left->token,"STRING")==0)
			addScope(tree,"",tree->token,NULL,NULL,NULL);
		else
			if(strcmp(tree->left->token,"BOOLEAN")==0)
			{
				if(strcmp(tree->token,"true")==0 && tree->labelTrue!=NULL)	
					addScope(tree,cutStr("goto ",cutStr(tree->labelTrue,"\n")),tree->token,NULL,NULL,NULL);
				else if(strcmp(tree->token,"false")==0 && tree->labelFalse!=NULL)
					addScope(tree,cutStr("goto ",cutStr(tree->labelFalse,"\n")),tree->token,NULL,NULL,NULL);
				else
					addScope(tree,tree->token,tree->token,NULL,NULL,NULL);
			}
		else
			addScope(tree,"",tree->token,NULL,NULL,NULL);
		return;
	}
	else if(strcmp(tree->token, "") == 0||strcmp(tree->token, " ") == 0)
	{
		if(tree->left)
			addScope(tree->left,NULL,NULL,tree->label,tree->labelTrue,tree->labelFalse);
		if(tree->right)
			addScope(tree->right,NULL,NULL,tree->label,tree->labelTrue,tree->labelFalse);
		if(tree->left!=NULL) 
			make3AC(tree->left); 
		if(tree->right!=NULL) 
			make3AC(tree->right);
		if(tree->left && tree->right)
			addScope(tree,cutStr(tree->left->SCOPE,tree->right->SCOPE),tree->right->var,NULL,NULL,NULL);
		else if(tree->left)
			addScope(tree,tree->left->SCOPE,tree->left->var,NULL,NULL,NULL);	
		else if(tree->right)
			addScope(tree,tree->right->SCOPE,tree->right->var,NULL,NULL,NULL);	
		return;
	}
	else
	{
		if (tree->left) 
			make3AC(tree->left);
		if (tree->right)
			make3AC(tree->right);
		addScope(tree,"",tree->token,NULL,NULL,NULL);
		return;
	}
	if (tree->left) 
		make3AC(tree->left);
	if (tree->right)
		make3AC(tree->right);
}

void addScope(node* node,char *SCOPE,char *var,char *label,char *labelTrue,char *labelFalse){
	if(SCOPE!=NULL){
		node->SCOPE=(char*)malloc(sizeof(char)*(1+strlen(SCOPE)));
		strcpy(node->SCOPE,SCOPE);
	}
	else if(node->SCOPE==NULL)
	{
		node->SCOPE=(char*)malloc(sizeof(char)*2);
		strcpy(node->SCOPE,"");
	}

	if(var!=NULL){
		node->var=(char*)malloc(sizeof(char)*(1+strlen(var)));
		strcpy(node->var,var);
	}
	else if(node->var==NULL)
	{
		node->var=(char*)malloc(sizeof(char)*2);
		strcpy(node->var,"");
	}

	if(label!=NULL&& node->label==NULL){
		node->label=(char*)malloc(sizeof(char)*(1+strlen(label)));
		strcpy(node->label,label);
	}

	if(labelTrue!=NULL && node->labelTrue==NULL){
		node->labelTrue=(char*)malloc(sizeof(char)*(1+strlen(labelTrue)));
		strcpy(node->labelTrue,labelTrue);
	}
	
	if(labelFalse!=NULL && node->labelFalse==NULL){
		node->labelFalse=(char*)malloc(sizeof(char)*(1+strlen(labelFalse)));
		strcpy(node->labelFalse,labelFalse);
	}
}

void addScope2(node* node,char *SCOPE,char *var,char *label,char *labelTrue,char *labelFalse){
	if(SCOPE!=NULL){
		node->SCOPE=(char*)malloc(sizeof(char)*(1+strlen(SCOPE)));
		strcpy(node->SCOPE,SCOPE);
	}
	else if(node->SCOPE==NULL)
	{
		node->SCOPE=(char*)malloc(sizeof(char)*2);
		strcpy(node->SCOPE,"");
	}

	if(var!=NULL){
		node->var=(char*)malloc(sizeof(char)*(1+strlen(var)));
		strcpy(node->var,var);
	}
	else if(node->var==NULL)
	{
		node->var=(char*)malloc(sizeof(char)*2);
		strcpy(node->var,"");
	}

	if(label!=NULL){
		node->label=(char*)malloc(sizeof(char)*(1+strlen(label)));
		strcpy(node->label,label);
	}

	if(labelTrue!=NULL){
		node->labelTrue=(char*)malloc(sizeof(char)*(1+strlen(labelTrue)));
		strcpy(node->labelTrue,labelTrue);
	}
	
	if(labelFalse!=NULL && node->labelFalse==NULL){
		node->labelFalse=(char*)malloc(sizeof(char)*(1+strlen(labelFalse)));
		strcpy(node->labelFalse,labelFalse);
	}
}

char* newVarible(){
	char* x;
	asprintf(&x,"t%d",t++);
	return x;
}
char* newLabel(){
	char* x;
	asprintf(&x,"L%d",lab++);
	return x;
}
char* generate(char*s1,char*s2,char*s3,char*s4,char*s5){
	char* x;
	asprintf(&x,"%s %s %s %s %s\n",s1,s2,s3,s4,s5);
	return x;
}

char* cutStr(char*des,char*src){
	char* tamp=des;
	char* num;
	asprintf(&num,"%d ",line++);
	if(src!=NULL){
		if(des==NULL){
			des=(char*)malloc((strlen(src)+1)*sizeof(char));
			strcpy(des,src);
			return des;
		}
		des=(char*)malloc((strlen(des)+strlen(src)+1+strlen(num))*sizeof(char));
		if(tamp!=NULL){
			strcat(des,tamp);
		}
		if(src!=NULL)
		{
			strcat(des,src);
		}
	}
	return des;
}

char* space(char *label)
{
	char * message;
	char x=' ';
	int length = strlen(cutStr(label,"\0"));
	if(label==NULL || !strcmp(label,""))
		message="";
	else
	{
		asprintf(&message,"%c",x);
		while(length<5){
			asprintf(&message,"%c%s",x,message);
			length++;
		}
		asprintf(&label,"%s: ",cutStr(label,"\0"));
		message=cutStr(message,label);
	}
	return message;
}

char *strReplac(const char *s, const char *old_word, const char *new_word) 
{ 
    char *res; 
    int i, c = 0; 
    int newWlen = strlen(new_word); 
    int oldWlen = strlen(old_word); 
    for (i = 0; s[i] != '\0'; i++) 
    { 
        if (strstr(&s[i], old_word) == &s[i]) 
        { 
            c++; 
            i += oldWlen - 1; 
        } 
    } 
  
    res = (char *)malloc(i + c * (newWlen - oldWlen) + 1); 
  
    i = 0; 
    while (*s) 
    { 
        if (strstr(s, old_word) == s) 
        { 
            strcpy(&res[i], new_word); 
            i += newWlen; 
            s += oldWlen; 
        } 
        else
            res[i++] = *s++; 
    } 
  
    res[i] = '\0'; 
    return res; 
} 
