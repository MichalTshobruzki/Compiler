%x C_COMMENT


/*Scanner-file*/
%{
#include<stdio.h>
#include "y.tab.h"
%}
 /*x comment*/

%%
  /*Types /*Keywords Lexemes*/
bool 			{return BOOL;}
char 			{return CHAR;}
int 			{return INT;}
real 			{return REAL;}
string 			{return STRING;}
int\* 			{return INTPTR;}
char\* 			{return CHARPTR;}
real\* 			{return REALPTR;}
void			{return VOID;}

  /*Statement*/
if 			{return IF;}
else 			{return ELSE;}
while 			{return WHILE;}
for 			{return FOR;}
var 			{return VAR;}
function 		{return FUNC;}
null 			{return NULLL;}
main 			{return MAIN;}
do			{return DO;}
 
  /*Operators*/
"&&" 			{return AND;}
"/" 			{return DIV;}
"=" 			{return ASSING;}
"==" 			{return EQL;}
">" 			{return BIGGER;}
">=" 			{return BIGGEREQL;}
"<" 			{return SMALLER;}
"<=" 			{return SMALLEREQL;}
"+" 			{return PLUS;}
"-" 			{return MINUS;}
"!" 			{return NOT;}
"!=" 			{return NOTEQL;}
"||" 			{return OR;}

"*" 			{return MUL;}
"&" 			{return REF;}

  /*Other Lexemes*/
"{" 					{yylval.string = strdup("{");return '{';};
"}" 					{yylval.string = strdup("}");return '}';};
"(" 					{yylval.string = strdup("(");return '(';};
")" 					{yylval.string = strdup(")");return ')';};
"|" 					{yylval.string = strdup("|");return '|';};
"[" 					{yylval.string = strdup("[");return '[';};
"]" 					{yylval.string = strdup("]");return ']';};
";" 					{yylval.string = strdup(";");return ';';};
"," 					{yylval.string = strdup(",");return ',';};

 
"/*"            	{ BEGIN(C_COMMENT); }
<C_COMMENT>"*/" 	{ BEGIN(INITIAL); }
<C_COMMENT>\n   	yylineno++;
<C_COMMENT>.   		;



  /*Literl*/
return 						{return RETURN;}
true 						{return TRUEVal;}
false 						{return FALSEVal;}
[a-zA-Z][a-zA-Z0-9_]* 				{yylval.string= strdup(yytext);return ID;}
"\""[^"]*"\"" 					{yylval.string= strdup(yytext);return STRVal;}
\'.\' 						{yylval.string= strdup(yytext);return CHARVal;}
[+-]?[1-9][0-9]*|[0-9] 				{yylval.string= strdup(yytext);return DECIMAL_INTVal;}
0(x|X)[0-9A-F]+ 				{yylval.string= strdup(yytext);return HEX_INTVal;}
[-+]?[0-9]*[\.]?[0-9]*[eE]?[-+]?[0-9]+ 		{yylval.string= strdup(yytext);return REALVal;}
	/*Skip Whitespace, Enter, Tab*/
[\n] {yylineno++;} //For each line (enter=\n), do yylineo+=1
[ \t]+ ;
. return yytext[0];
%%



