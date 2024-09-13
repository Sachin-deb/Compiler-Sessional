%option noyywrap yylineno
%x START_STR
%{ 
#include<bits/stdc++.h>
#include "1805020_SymbolTable.cpp"
#include "Extra.cpp"
#include "y.tab.h"
using namespace std;
int error_cnt = 0;
int line_count = 0;
string tempStr;
//ofstream tokenizer;
//ofstream logfile;
//ifstream input;
SymbolTable hashTable(7);
extern YYSTYPE yylval;
//extern SymbolTable *sym_tab;
%}
digit [0-9]
digits {digit}+
number {digits}(.{digits})?(E[+-]?{digits})?
letter [_A-Za-z]
WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z_]
DIGIT [0-9]
NEWLINE [\r]?\n
ALNUM [A-Za-z_0-9]
ALL_EXCEPT_BACKSLASH [^\\]
CHAR [ -~]{-}[']
CHARS {CHAR}+
id {letter}[{letter}|{digit}]*
relop [<|>|<=|>=|=|<>]
SPECIAL_CH '\\[vartafb0n]'|'\\'
SINGLELINE_COMMENT "//"[^\n]+ 
MULTILINE_COMMENT_START "/*"
MULTILINE_COMMENT_END "*/"
ANYTHING_EXCEPT_STAR [^*]
STAR_NOT_FOLLOWED_BY_SLASH "*"[^/]
COMMENT ({MULTILINE_COMMENT_START}({ANYTHING_EXCEPT_STAR}|{STAR_NOT_FOLLOWED_BY_SLASH})*{MULTILINE_COMMENT_END})
NOT_FINISHED_COMMENT ({MULTILINE_COMMENT_START}[^"*/"]*)
%%
[ \t\v\r\f]+ {}
[\n]+ {
	line_count++;
}

"if" {return IF;}
"else" {return ELSE;}
"for" {return FOR;}
"while" {return WHILE;}
"do" {return DO;}
"break" {return BREAK;}
"int" { SymbolInfo *s= new  SymbolInfo(yytext, "INT"); yylval.symbol_info = s; return INT;}
"char" {return CHAR;}
"float" { SymbolInfo *s= new  SymbolInfo(yytext, "FLOAT"); yylval.symbol_info = s; return FLOAT;} 
"double" {return DOUBLE;}
"void" { SymbolInfo *s= new  SymbolInfo(yytext, "VOID"); yylval.symbol_info = s; return VOID;}
"return" {return RETURN;}
"switch" {return SWITCH;}
"case" {return CASE;}
"default" {return DEFAULT;}
"continue" {return CONTINUE;}
"printf"	{return PRINTLN;}

["] { tempStr="";BEGIN START_STR;}

<START_STR>[^\\\n\"] {tempStr += yytext;}

<START_STR>["] {        
		cout << "Line No. "<< yylineno <<":  Token <STRING> Lexeme "<< tempStr <<" found\n";cout.flush();
 		//tokenizer<<"<STRING,"<< yytext <<">"; tokenizer.flush();
		BEGIN INITIAL;
    }

<START_STR>[\\\n] {}

<START_STR>{NEWLINE} {error_cnt++; cout << "Line No." << yylineno << " :Unfinished String Error\n";BEGIN INITIAL;}

<START_STR><<EOF>> {error_cnt++; cout << "Line No." << yylineno << " :Unfinished String Error\n";BEGIN INITIAL;}

	
[_a-zA-Z]([_a-zA-Z]|[0-9])* {    
        
		SymbolInfo *s= new  SymbolInfo(yytext, "ID");
		yylval.symbol_info = s;
		return ID;
    }
[0-9]+ { SymbolInfo *s= new  SymbolInfo(yytext, "CONST_INT");
				yylval.symbol_info = s;
				return CONST_INT;}
[0-9]+(\.[0-9]*)(E[+-]?[0-9]+)? { SymbolInfo *s= new  SymbolInfo(yytext, "CONST_FLOAT");
				yylval.symbol_info = s;
				return CONST_FLOAT; }
[0-9]*[\.]([0-9]*\.[0-9]*)+[^ \n\t\v\r\f]* { error_cnt++; cout << "Line No. " << yylineno << ": Error found: Too many decimal points error.\n";SymbolInfo *s= new  SymbolInfo(yytext, "ERROR_FLOAT");
	yylval.symbol_info = s;
	return ERROR_FLOAT;}
[0-9]*[E]+[0-9]*[\.]+[0-9]* { error_cnt++; cout << "Line No. " << yylineno << ": ILL formatted number.\n";SymbolInfo *s= new  SymbolInfo(yytext, "ERROR_FLOAT");
	yylval.symbol_info = s;
	return ERROR_FLOAT;}
{DIGIT}*(\.{DIGIT}+)?(E[+-]?{DIGIT}+)?{LETTER}{ALNUM}* {
	
	error_cnt++; cout << "Line No. " << yylineno << ": Invalid prefix on ID or invalid suffix on Number .\n";
	SymbolInfo *s= new  SymbolInfo(yytext, "ID");
	yylval.symbol_info = s;
	return ID;
}
['][^'][^']+['] {error_cnt++; cout << "Line No. " << yylineno << ": Multiple Constant Character Error\n";}
('({CHARS}+|['])*') { error_cnt++; cout << "Line No." << yylineno << " :Empty character constant\n"; }
('{CHAR}*[^'\n]?) { error_cnt++; cout << "Line No." << yylineno << " :Unfinished Character\n";}
{SINGLELINE_COMMENT}	{
	cout <<"Line No. "<< yylineno <<":  Token <COMMENT> Lexeme "<<yytext<<" found\n";cout.flush();	
}
{COMMENT} {cout <<"Line No. "<< yylineno <<":  Token <COMMENT> Lexeme "<<yytext<<" found\n";cout.flush();}
 
{NOT_FINISHED_COMMENT} {cout <<"Error at Line No. "<< yylineno <<":  Unfinished Comment "<<yytext<<"\n";cout.flush();error_cnt++; }
{SPECIAL_CH} {
		cout << "Line No. "<< yylineno <<":  Token <CONST_CHAR> Lexeme "<<yytext<<" found\n";cout.flush();
		//tokenizer<<"<CONST_CHAR,"<<yytext<<">";tokenizer.flush();
        SymbolInfo* symbol = new SymbolInfo(yytext, "CONST_CHAR"); hashTable.insertSymbol(*symbol);
    }


"++"	{return INCOP;}
"--"	{return DECOP;}

("-"|"+")  {
		SymbolInfo *s= new  SymbolInfo(yytext, "ADDOP"); yylval.symbol_info = s; return ADDOP;
    }
("*"|"/"|"%") {
		SymbolInfo *s= new  SymbolInfo(yytext, "MULOP"); yylval.symbol_info = s; return MULOP;
    }

("<="|">="|"=="|"!="|">"|"<") {
		SymbolInfo *s= new  SymbolInfo(yytext, "RELOP"); yylval.symbol_info = s; return RELOP;	
    }

("=") { 
		return ASSIGNOP;
    }
("&&"|"||") {
		SymbolInfo *s= new  SymbolInfo(yytext, "LOGICOP"); yylval.symbol_info = s; return LOGICOP;
    }
("!") {
	SymbolInfo *s= new  SymbolInfo(yytext, "NOT"); yylval.symbol_info = s;
	return NOT;
}

("(") {	
		return LPAREN;
    }
(")") {	
		return RPAREN;
    }
("{") {	
		return LCURL;
    }
("}") {	
		return RCURL;
    }
("[") {	
		return LTHIRD;
    }
("]") {	
		return RTHIRD;
    }

(";") {
		
		return SEMICOLON;
    }

(",") {
		return COMMA;
    }



[0-9]([0-9]|[a-zA-Z_])* {cout <<"Error at Line No. "<< yylineno <<":  Invalid identifier "<< yytext <<"\n";cout.flush();error_cnt++; }

. {}
%%
