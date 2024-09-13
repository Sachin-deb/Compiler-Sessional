%{
#include<bits/stdc++.h>
#include "1805020_symbolInfo.cpp"
#include "1805020_SymbolTable.cpp"
#include "1805020_ScopeTable.cpp"
#include "Extra.cpp"
using namespace std;
extern FILE *yyin;
ofstream logFile("log.txt"), errorFile("error.txt");
extern int line_count;
int total_errors = 0;
//extern int err_cnt;
//int err_count = 0;
int yyparse(void);
int yylex(void);
void yyerror(string s){
    cout << s << "\n";
    cout << "no rules matched\n";
	//logout<<"Error at line "<<line_count<<": "<<s<<"\n"<<endl;
	//errout<<"Error at line "<<line_count<<": "<<s<<"\n"<<endl;
    //err_count++;
    //err_cnt++;
}
extern int yylineno;
SymbolTable *sym_tab = new SymbolTable(30);
string curr_return_type;
vector<pair<string, string>> curr_params;

%}

%error-verbose

%union{
    SymbolInfo *symbol_info;
    SymbolInfo *symbol_info_vec[100];
    string *symbol_info_str;
    string *temp_str;
    Extra *extra;
    int ival;
    double dval;
}
%token IF ELSE LOWER_THAN_ELSE FOR WHILE DO BREAK CHAR DOUBLE RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN INCOP DECOP ASSIGNOP LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%token <symbol_info> ID INT FLOAT VOID ADDOP MULOP RELOP LOGICOP CONST_INT CONST_FLOAT ERROR_FLOAT NOT
%type<extra> var_declaration type_specifier declaration_list variable statements statement func_declaration func_definition
%type<extra> expression_statement compound_statement logic_expression rel_expression simple_expression term 
%type<extra> unary_expression factor argument_list arguments start program unit parameter_list expression 

%%
start : program {
        $$ = new Extra();
        $$ = $1;
        logFile << "Line " << yylineno << ": ";
        logFile << "start : program\n"; 
        logFile << $$->name << "\n";
    }
    ;
program : program unit {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += " ";
        $$->name += $2->name;
        logFile << "Line " << yylineno << ": ";
        logFile << "program : program unit\n";
        logFile << $$->name << "\n";
    }
    | unit {
        $$ = new Extra();
        $$->name += $1->name;
        logFile << "Line " << yylineno << ": ";
        logFile << "program : unit\n";
        logFile << $$->name << "\n";
    }
    ;
unit : var_declaration {
        $$ = new Extra();
        $$ = $1;
        logFile << "Line " << yylineno << ": ";
        logFile << "unit : var declaration\n";
        logFile << $$->name << "\n";
    }
    | func_declaration {
        $$ = new Extra();
        $$ = $1;
        logFile << "Line " << yylineno << ": ";
        logFile << "unit : func_declaration\n";
        logFile << $$->name << "\n";
    }
    | func_definition {
        $$ = new Extra();
        $$ = $1;
        logFile << "Line " << yylineno << ": ";
        logFile << "unit : func_definition\n";
        logFile << $$->name << "\n";
    }
    ;
    func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += $2->name;
        $$->name += '(';
        $$->name += $4->name;
        $$->name += ')';
        $$->name += ';';
        SymbolInfo *didFound = sym_tab->fullLookUp($2->getName(), "FUNC");
        if(didFound != nullptr) {
            total_errors++;
            errorFile << "Error at line " << yylineno << " ";
            errorFile << "Function " << $2->getName() << " already declared\n";
        }
        else {
            $2->setDataType($1->name);
            $2->setIsFunction();
            $2->params = $4->params;
            $2->isDeclared = true;
            sym_tab->insertSymbol(*$2);
        }
        logFile << "Line " << yylineno << ": ";
        logFile << "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n";
        logFile << $$->name << "\n";
        //cout << $$->name << "\n";
    }
    | type_specifier ID LPAREN RPAREN SEMICOLON {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += $2->getName();
        $$->name += '(';
        $$->name += ')';
        $$->name += ';';
        $2->dataType = $1->name;
        $2->isFunction = true;
        $2->isDeclared = true;
        //if($2->name == "foo") errorFile << $2->isFunction << "\n";
        //errorFile << sym_tab->insertSymbol(*$2) << "\n";
        logFile << "Line " << yylineno << ": ";
        logFile << "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n";
        logFile << $$->name << "\n";
    }
    ;
func_definition : type_specifier ID LPAREN parameter_list RPAREN {
        SymbolInfo *ret_info = sym_tab->fullLookUp($2->name, "FUNC");
        curr_return_type = $1->name;
        if(ret_info != nullptr) {
            if(ret_info->isDefined) {
                total_errors++;
                errorFile << "Error at line " << yylineno << " ";
                errorFile << "Multiple Definition of a function " << $2->name << "\n";
                //sym_tab->enterScope(30);
            }
            else if(ret_info->isDeclared) {
                if(ret_info->params.size() != $4->params.size()) {
                    total_errors++;
                    errorFile << "Error at line " << yylineno << " ";
                    errorFile << "the number of parameters already declared is inconsistent for function " << $2->name << "\n";
                }
                int flag = 0;
                int sz = ret_info->params.size();
                for(int i = 0; i < sz; i++) {
                    if(ret_info->params[i].first != $4->params[i].first) {
                        total_errors++;
                        errorFile << "Error at line " << yylineno << " ";
                        errorFile << "Type of parameters doesnot match for function " << $2->name << "\n";
                    }
                }
                if($1->name != ret_info->dataType) {
                    total_errors++;
                    errorFile << "Error at line " << yylineno << " ";
                    errorFile << "Return types doesnot match\n";
                }
                sym_tab->removeSymbol(ret_info->name, "FUNC");
                SymbolInfo *temp = new SymbolInfo($2->name, "ID");
                temp->dataType = $1->name;
                temp->isFunction = true;
                temp->isDeclared = true;
                temp->isDefined = true;
                //if(temp->name == "foo4") errorFile << "####" << temp->dataType << "\n";
                for(auto x: $4->params) {
                    temp->params.push_back(x);
                }
                sym_tab->insertSymbol(*temp);
                //sym_tab->enterScope(30);
                int cn = 0;
                for(auto x: $4->params) {
                    cn++;
                    int cnt = 0;
                    int cn1 = 1;
                    for(auto y: $4->params) {
                        if(cn1 > cn) break;
                        if(y.second == x.second)cnt++;
                        cn1++;
                    }
                    //SymbolInfo *temp1 = sym_tab->lookUp(x.second, "*");
                    if(cnt == 1) {
                        //SymbolInfo *temp2 = new SymbolInfo(x.second, "ID");
                        //temp2->dataType = x.first;
                        //sym_tab->insertSymbol(*temp2);
                        curr_params.push_back(x);
                    }
                    else {
                        total_errors++;
                        errorFile << "Error at line " << yylineno << " ";
                        errorFile << "Multiple same variable declared " << x.second << "\n";
                    }
                }
            }
            else {
                // the function is already declared
            }
        }
        else {
            ret_info = sym_tab->fullLookUp($2->name, "*");
            //errorFile <<
            if(ret_info != nullptr) {
                total_errors++;
                errorFile << "Error at line " << yylineno << " ";
                errorFile << $2->name << " is a variable not function\n";
                //sym_tab->enterScope(30);
            }
            else {
                SymbolInfo *temp = new SymbolInfo($2->name, "ID");
                temp->dataType = $1->name;
                temp->isFunction = true;
                temp->isDeclared = true;
                temp->isDefined = true;
                //if(temp->name == "foo4") errorFile << "####" << temp->dataType << "\n";
                for(auto x: $4->params) {
                    temp->params.push_back(x);
                }
                sym_tab->insertSymbol(*temp);
            }
                //sym_tab->enterScope(30);
                int cn = 0;
                for(auto x: $4->params) {
                    cn++;
                    int cnt = 0;
                    int cn1 = 1;
                    for(auto y: $4->params) {
                        if(cn1 > cn) break;
                        if(y.second == x.second)cnt++;
                        cn1++;
                    }
                    //SymbolInfo *temp1 = sym_tab->lookUp(x.second, "*");
                    if(cnt == 1) {
                        //SymbolInfo *temp2 = new SymbolInfo(x.second, "ID");
                        //temp2->dataType = x.first;
                        //sym_tab->insertSymbol(*temp2);
                        curr_params.push_back(x);
                    }
                    else {
                        total_errors++;
                        errorFile << "Error at line " << yylineno << " ";
                        errorFile << "Multiple same variable declared " << x.second << "\n";
                    }
                }
                //the function is not declared
        }
    }
    compound_statement {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += $2->name;
        $$->name += "(";
        $$->name += $4->name;
        $$->name += ")";
        $$->name += $7->name;
        logFile << "Line " << yylineno << ": ";
        logFile << "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n";
        logFile << $$->name << "\n";
    }
    | type_specifier ID LPAREN RPAREN {
        SymbolInfo *ret_info = sym_tab->fullLookUp($2->name, "FUNC");
        curr_return_type = $1->name;
        //if(ret_info == nullptr) errorFile << "I am goru\n";
        if(ret_info != nullptr) {
            if(ret_info->isDefined) {
                total_errors++;
                errorFile << "Error at line " << yylineno << " ";
                errorFile << "Multiple Definition of a function " << $2->name << "\n";
                //sym_tab->enterScope(30);
            }
            else if(ret_info->isDeclared) {
                if(ret_info->params.size() != 0) {
                    total_errors++;
                    errorFile << "Error at line " << yylineno << " ";
                    errorFile << "The number of parameters already declared is inconsistent for function " << $2->name;
                }
                if($1->name != ret_info->dataType) {
                    total_errors++;
                    errorFile << "Error at line " << yylineno << " ";
                    errorFile << "Return types doesnot match\n";
                }
                sym_tab->removeSymbol(ret_info->name, "FUNC");
                SymbolInfo *temp = new SymbolInfo($2->name, "ID");
                temp->dataType = $1->name;
                temp->isFunction = true;
                temp->isDeclared = true;
                temp->isDefined = true;
                sym_tab->insertSymbol(*temp);
                //sym_tab->enterScope(30);
            }
            else {
                // the function is already declared
            }
        }
        else {
            ret_info = sym_tab->fullLookUp($2->name, "*");
            if(ret_info != nullptr) {
                total_errors++;
                errorFile << "Error at line " << yylineno << " ";
                //errorFile << ret_info->name << "\n";
                //errorFile << ret_info->isFunction << "\n";
                errorFile << "This is a variable not function " << $2->name << "\n";
                //sym_tab->enterScope(30);
            }
            else {
                SymbolInfo *temp = new SymbolInfo($2->name, "ID");
                temp->dataType = $1->name;
                temp->isFunction = true;
                temp->isDeclared = true;
                temp->isDefined = true;
                
                sym_tab->insertSymbol(*temp);
                //sym_tab->enterScope(30);
                //the function is not declared
            }
        }
    }
    compound_statement {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += $2->name;
        $$->name += "(";
        $$->name += ")";
        $$->name += $6->name;
        logFile << "Line " << yylineno << ": ";
        logFile << "func_definition : type_specifier ID LPAREN RPAREN compound_statement\n";
        logFile << $$->name << "\n";
    }
    ;
parameter_list : parameter_list COMMA type_specifier ID {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += ',';
        $$->name += $3->name;
        $$->name += $4->getName();
        for(auto x: $1->params) {
            $$->params.push_back(x);
        }
        $$->params.push_back({$3->name, $4->name});
        logFile << "Line " << yylineno << ": ";
        logFile << "parameter_list : parameter_list COMMA type_specifier ID\n";
        logFile << $$->name << "\n";
    }
|  parameter_list COMMA type_specifier {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += ',';
        $$->name += $3->name;
        $$->params = $1->params;
        $$->params.push_back({$3->name, ""});
        logFile << "Line " << yylineno << ": ";
        logFile << "parameter_list : parameter_list COMMA type_specifier\n";
        logFile << $$->name << "\n";
    }
| type_specifier ID {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += $2->name;
        $$->params.push_back({$1->name, $2->name});
        cout << $$->name << "\n";
        logFile << "Line " << yylineno << ": ";
        logFile << "parameter_list : type_specifier ID\n";
        logFile << $$->name << "\n";
    }
    | type_specifier {
        $$ = new Extra();
        $$->name += $1->name;
        $$->params.push_back({$1->name, ""});
        logFile << "Line " << yylineno << ": ";
        logFile << "parameter_list : type_specifier\n";
        logFile << $$->name << "\n";
    }   
    ;
compound_statement : LCURL {
        sym_tab->enterScope(30);
        for(auto x: curr_params) {
            SymbolInfo *temp = new SymbolInfo(x.second, "ID");
            temp->dataType = x.first;
            sym_tab->insertSymbol(*temp);
        }
        curr_params.clear();
    }
    statements RCURL {
        $$ = new Extra();
        $$->name += '{';
        $$->name += $3->name;
        $$->name += "}";
        sym_tab->printCurrent(&logFile);
        sym_tab->exitScope();
        logFile << "Line " << yylineno << ": ";
        logFile << "compound_statement : LCURL statements RCURL\n";
        logFile << $$->name << "\n";
    }
    | LCURL RCURL {
        $$ = new Extra();
        $$->name += '{';
        $$->name += "}";
        //sym_tab->printAll();
        //sym_tab->exitScope();
        logFile << "Line " << yylineno << ": ";
        logFile << "compound_statement : LCURL RCURL\n";
        logFile << $$->name << "\n";
    }
    ;
var_declaration : type_specifier declaration_list SEMICOLON {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += $2->name;
        $$->name += ';';
        if($1->name != "int" and $1->name != "float" and $1->name != "double") {
            total_errors++;
            errorFile << "Error at line " << yylineno << " ";
            errorFile << "variable type cannot be " << $1->name << "\n";
        }
        //errorFile << sym_tab->getCurrentScopeTable()->getId() << "\n";
        //errorFile << yylineno << " : " << $$->name << "\n"; 
        //if($$->name == "inta[2],c,i,j;") errorFile << sym_tab->getCurrentScopeTable()->getId() << "\n";
        for(auto x: $2->declaration_list) {
            SymbolInfo *temp = sym_tab->lookUp(x->name, "*");
            if(temp != nullptr) {
                total_errors++;
                errorFile << "Error at line " << yylineno << " ";
                errorFile << "Previously declared variable " << temp->name << "\n";
                continue;
            }
            //if(x->isArray) errorFile << x->name << "\n";
            x->setDataType($1->name);
            sym_tab->insertSymbol(*x);
        }
        logFile << "Line " << yylineno << ": ";
        logFile << "var_declaration : type_specifier declaration_list SEMICOLON\n";
        logFile << $$->name << "\n";
    }
    ;
type_specifier : INT {
        $$ = new Extra();
        $$->name = "int";
        logFile << "Line " << yylineno << ": ";
        logFile << "type_specifier : INT\n";
        logFile << $$->name << "\n";
    }
    | FLOAT {
        $$ = new Extra();
        $$->name = "float";
        logFile << "Line " << yylineno << ": ";
        logFile << "type_specifier : FLOAT\n";
        logFile << $$->name << "\n";
    }
    | VOID {
        $$ = new Extra();
        $$->name = "void";
        logFile << "Line " << yylineno << ": ";
        logFile << "type_specifier : VOID\n";
        logFile << $$->name << "\n";
    }
    ;
declaration_list : declaration_list COMMA ID {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += ',';
        $$->name += $3->getName();
        $$->declaration_list = $1->declaration_list;
        $$->declaration_list.push_back($3);
        $$->type = $1->type;
        logFile << "Line " << yylineno << ": ";
        logFile << "declaration_list : declaration_list COMMA ID \n";
        logFile << $$->name << "\n";
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        //errorFile << yylineno << ": " << $5->name << "\n";
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += ',';
        $$->name += $3->name;
        $$->name += '[';
        $$->name += $5->name;
        $$->name += ']';
        $$->declaration_list = $1->declaration_list;
        $$->type = $1->type;
        $3->setIsArray();
        $$->declaration_list.push_back($3);
        logFile << "Line " << yylineno << ": ";
        logFile << "declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD \n";
        logFile << $$->name << "\n";
    }
    | ID {
        $$ = new Extra();
        $$->name += $1->getName();
        $$->declaration_list.push_back($1);
        logFile << "Line " << yylineno << ": ";
        logFile << "declaration_list : ID\n";
        logFile << $$->name << "\n";
    }
    | ID LTHIRD CONST_INT RTHIRD {
        $$ = new Extra();
        $$->name += $1->getName();
        $$->name += '[';
        $$->name += $3->getName();
        $$->name += ']';
        //errorFile << yylineno << ": " << sym_tab->getCurrentScopeTable()->getId() << "\n";
        $1->isArray = 1;
        $$->declaration_list.push_back($1);
        logFile << "Line " << yylineno << ": ";
        logFile << "declaration_list : ID LTHIRD CONST_INT RTHIRD \n";
        logFile << $$->name << "\n";
    }
    ;
    statements : statement {
        $$ = new Extra();
        $$->name = $1->name;
        logFile << "Line " << yylineno << ": ";
        logFile << "statements : statement \n";
        logFile << $$->name << "\n";
    }
    | statements statement {
        $$ = new Extra();
        $$->name = $1->name + " " + $2->name;
        logFile << "Line " << yylineno << ": ";
        logFile << "statements : statements statement \n";
        logFile << $$->name << "\n";
    };

statement : var_declaration {
        $$ = new Extra();
        $$->name = $1->name;
        logFile << "Line " << yylineno << ": ";
        logFile << "statement : var_declaration\n";
        logFile << $$->name << "\n";
    }
    | expression_statement {
        $$ = new Extra();
        $$->name = $1->name;
        $$->type = $1->type;
        logFile << "Line " << yylineno << ": ";
        logFile << "statement : expression_statement\n";
        logFile << $$->name << "\n";
    }
    | compound_statement {
        $$ = new Extra();
        $$->name = $1->name;
        $$->type = $$->type;
        logFile << "Line " << yylineno << ": ";
        logFile << "statement : compound_statement\n";
        logFile << $$->name << "\n";
    }
    | FOR LPAREN expression_statement expression_statement expression
RPAREN statement {
        $$ = new Extra();
        $$->name = " for ";
        $$->name += "( ";
        $$->name += $3->name;
        $$->name += " ";
        $$->name += $4->name;
        $$->name += " ";
        $$->name += $5->name;
        $$->name += " ";
        $$->name += ')';
        $$->name += " ";
        $$->name += $7->name;
        logFile << "Line " << yylineno << ": ";
        logFile << "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n";
        logFile << $$->name << "\n";
        //$$->name = "for"  + " " + "(" + $3->name + " " + $4->name + " " + $5->name + " " +  ")" + " " + $7->name;
    }
    | IF LPAREN expression RPAREN statement {
        $$ = new Extra();
        $$->name = " if ";
        $$->name += "( ";
        $$->name += $3->name;
        $$->name += " ";
        $$->name += ") ";
        $$->name += $5->name;
        $$->type = "int";
        logFile << "Line " << yylineno << ": ";
        logFile << "statement : IF LPAREN expression RPAREN statement\n";
        logFile << $$->name << "\n";
        //$$->name = "if" + " " + "(" + " " + $3->name + " " + ")" + " " +  $5->name;
    }
    | IF LPAREN expression RPAREN statement ELSE statement {
        $$ = new Extra();
        $$->name = " if ";
        $$->name += "( ";
        $$->name += $3->name;
        $$->name += " ";
        $$->name += ") ";
        $$->name += $5->name;
        $$->name += " ";
        $$->name += "else ";
        $$->name += $7->name;
        $$->type = "int";
        logFile << "Line " << yylineno << ": ";
        logFile << "statement : IF LPAREN expression RPAREN statement ELSE statement\n";
        logFile << $$->name << "\n";
       // $$->name = "if" + " " + "(" + " " + $3->name + " " + ")" + " " + $5->name + " " + "else" + " " + $7->name;
    }
    | WHILE LPAREN expression RPAREN statement {
        $$ = new Extra();
        $$->name += " while ";
        $$->name += "( ";
        $$->name += $3->name;
        $$->name += " ";
        $$->name += ") ";
        $$->name += $5->name;
        logFile << "Line " << yylineno << ": ";
        logFile << "statement : WHILE LPAREN expression RPAREN statement\n";
        logFile << $$->name << "\n";
       // $$->name = "while" + " " + "(" + " " + $3->name + " " + ")" + " " + $5->name;
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON {
        $$ = new Extra();
        $$->name += " printf ";
        $$->name += "( ";
        $$->name += $3->name;
        $$->name += " ";
        $$->name += ") ";
        $$->name += ";";
        logFile << "Line " << yylineno << ": ";
        logFile << "statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n";
        logFile << $$->name << "\n";
       // $$->name = "printf" + " " + "(" + " " + $3->name + " " + ")" + " " + ';';
        SymbolInfo *ret_info = sym_tab->fullLookUp($3->name, "*");
        if(ret_info == nullptr) {
            total_errors++;
            errorFile << "Error at line " << yylineno << " ";
            errorFile << "Undeclared variable " << $3->name << "\n";
        }
    }
    | RETURN expression SEMICOLON {
        $$ = new Extra();
        $$->name += " return ";
        $$->name += $2->name;
        $$->name += " ";
        $$->name += ";";
        logFile << "Line " << yylineno << ": ";
        logFile << "statement : RETURN expression SEMICOLON \n";
        logFile << $$->name << "\n";
        //errorFile << $2->type << "\n";
       // $$->name = "return" + " " + $2->name + ";";
        if(curr_return_type != $2->type) {
            total_errors++;
            errorFile << "Error at line " << yylineno << " ";
            //errorFile << curr_return_type << " " << $2->type << "\n";
            //errorFile << $2->type << "\n";
            errorFile << "Return type mismatch\n";
        }
    }
    ;
expression_statement : SEMICOLON {
        $$ = new Extra();
        $$->name += " ;";
        logFile << "Line " << yylineno << ": ";
        logFile << "expression_statement : SEMICOLON\n";
        logFile << $$->name << "\n";
    }
    | expression SEMICOLON {
        $$ = new Extra();
        $$->name += " ";
        $$->name += $1->name;
        $$->name += " ";
        $$->name += ";";
        $$->type = $1->type;
        logFile << "Line " << yylineno << ": ";
        logFile << "expression_statement : expression SEMICOLON\n";
        logFile << $$->name << "\n";
    }
    ;
variable : ID {
        $$ = new Extra();
        $$->name += $1->name;
        SymbolInfo *ret_info = sym_tab->fullLookUp($1->name, "*");
        if(ret_info == nullptr) {
            total_errors++;
            errorFile << "Error at line " << yylineno << " ";
            errorFile << "Undeclared variable " << $1->name << "\n";
            $$->type = "error";
        }
        else {
            SymbolInfo *temp = sym_tab->lookUp($1->name, "*");
            if(temp != nullptr) ret_info = temp;
            //errorFile << "!!!" << ret_info->dataType << "\n";
            if(ret_info->isArray) {
                total_errors++;
                errorFile << "Error at line " << yylineno << " ";
                errorFile << "Variable " << ret_info->name << " is array\n";
                $$->type = "error";
            }
            else {
                $$->type = ret_info->dataType;
            }
        }
        //if(yylineno == 57) {
           // errorFile << $$->name << " " << $$->type << "\n";
        //}
        //errorFile << $1->dataType << "\n";
        logFile << "Line " << yylineno << ": ";
        logFile << "variable : ID\n";
        logFile << $$->name << "\n";
    }
    | ID LTHIRD expression RTHIRD {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += '[';
        $$->name += $3->name;
        $$->name += ']';
        //errorFile << $3->type << "\n";
        if($3->type != "int") {
            total_errors++;
            errorFile << "Error at line " << yylineno << " ";
            errorFile << "Array index must be an integer\n";
        }
        SymbolInfo *ret_info = sym_tab->fullLookUp($1->name, "*");
        if(ret_info == nullptr) {
            total_errors++;
            errorFile << "Error at line " << yylineno << " ";
            errorFile << "Undeclared variable " << $1->name << "\n";
            $$->type = "error";
        }
        else {
            //errorFile << sym_tab->getCurrentScopeTable()->getId() << "\n";
            SymbolInfo *temp = sym_tab->lookUp($1->name, "*");
            //if(temp != nullptr) errorFile << temp->dataType << "\n";
            //if(temp != nullptr) errorFile << temp->name << " " << temp->isArray << " " << temp->dataType << "\n";
            if(temp != nullptr) ret_info = temp;
            if(!ret_info->isArray) {
                total_errors++;
                errorFile << "Error at line " << yylineno << " ";
                errorFile << "Variable " << ret_info->name << " is not an array\n";
                $$->type = "error";
            }
            else {
                $$->type = $1->dataType;
            }
        }
        logFile << "Line " << yylineno << ": ";
        logFile << "variable : ID LTHIRD expression RTHIRD\n";
        logFile << $$->name << "\n";
    }
    ;
expression : logic_expression {
        $$ = new Extra();
        $$ = $1;
        logFile << "Line " << yylineno << ": ";
        logFile << "expression : logic_expression\n";
        logFile << $$->name << "\n";
    }
    | variable ASSIGNOP logic_expression {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += " ";
        $$->name += "=";
        $$->name += $3->name;
        if($1->type == "int" and $3->type == "float") {
            total_errors++;
            errorFile << "Error at line " << yylineno << " ";
            errorFile << "Mismatched types\n";
        }
        //errorFile << yylineno << " ";
        //errorFile << $3->type << "\n";
        if($3->type == "void") {
            total_errors++;
            errorFile << "Error at line " << yylineno << " ";
            errorFile << "Mismatched types\n";
        }
        logFile << "Line " << yylineno << ": ";
        logFile << "expression : variable ASSIGNOP logic_expression\n";
        logFile << $$->name << "\n";
    }
    ;
logic_expression : rel_expression {
        $$ = new Extra();
        $$ = $1;
        logFile << "Line " << yylineno << ": ";
        logFile << "logic_expression : rel_expression\n";
        logFile << $$->name << "\n";
    }
    | rel_expression LOGICOP rel_expression {
        $$ = new Extra();
        $$->name = $1->name;
        $$->name += " ";
        $$->name += $2->name;
        $$->name += " ";
        $$->name += $3->name;
        if($1->type != "int" or $3->type != "int") {
            total_errors++;
            errorFile << "Error at line " << yylineno << "\n";
            errorFile << "Mismatched types\n";
            $$->type = "error";
        }
        else {
            $$->type = $1->type;
        }
        logFile << "Line " << yylineno << ": ";
        logFile << "logic_expression : rel_expression LOGICOP rel_expression\n";
        logFile << $$->name << "\n";
    }
    ;
rel_expression : simple_expression {
        $$ = new Extra();
        $$ = $1;
        logFile << "Line " << yylineno << ": ";
        logFile << "rel_expression : simple_expression \n";
        logFile << $$->name << "\n";
    }
    | simple_expression RELOP simple_expression {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += " ";
        $$->name += $2->name;
        $$->name += " ";
        $$->name += $3->name;
        $$->type = "int";
        logFile << "Line " << yylineno << ": ";
        logFile << "rel_expression : simple_expression RELOP simple_expression \n";
        logFile << $$->name << "\n";
    }
    ;
simple_expression : term {
        $$ = new Extra();
        $$ = $1;
        logFile << "Line " << yylineno << ": ";
        logFile << "simple_expression : term  \n";
        logFile << $$->name << "\n";
    }
    | simple_expression ADDOP term {
        $$ = new Extra();
        $$->type = "int";
        if($1->type == "float" or $3->type == "float") $$->type = "float";
        $$->name = $1->name;
        $$->name += " ";
        $$->name += $2->name;
        $$->name += " ";
        $$->name += $3->name;
        logFile << "Line " << yylineno << ": ";
        logFile << "simple_expression : simple_expression ADDOP term\n";
        logFile << $$->name << "\n";
    }
    ;
term : unary_expression {
        $$ = new Extra();
        $$ = $1;        
        logFile << "Line " << yylineno << ": ";
        logFile << "term : unary_expression\n";
        logFile << $$->name << "\n";
    }
    | term MULOP unary_expression {
        string leftType = $1->type;
        string rightType = $3->type;
        string ret_type = "error";
        string op_symbol = $2->name;
        if(op_symbol == "%") {
            if(leftType != "int" or rightType != "int") {
                total_errors++;
                errorFile << "Error at line " << yylineno << " ";
                errorFile << "Non-integer operand on modulus operator\n";
            }
            else {
                if($3->name == "0") {
                    total_errors++;
                    errorFile << "Error at line " << yylineno << " ";
                    errorFile << "Modulo by 0\n";
                }
                ret_type = "int";
            }
        }
        else {
            if(leftType == "float" or rightType == "float") ret_type = "float";
            else ret_type = "int";
            if(op_symbol == "/") {
                if($3->name == "0") {
                    total_errors++;
                    errorFile << "Error at line " << yylineno << " ";
                    errorFile << "Divide by zero\n";
                    ret_type = "error";
                }
            }
        }
        $$->type = ret_type;
        $$ -> name = $1->name;
        $$->name += " ";
        $$->name += $2->name;
        $$->name += " ";
        $$->name += $3->name;
        logFile << "Line " << yylineno << ": ";
        logFile << "term : term MULOP unary_expression\n";
        logFile << $$->name << "\n";
    }
    ;
unary_expression : ADDOP unary_expression {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += " ";
        $$->name += $2->name;
        $$->type = $2->type;
        logFile << "Line " << yylineno << ": ";
        logFile << "unary_expression : ADDOP unary_expression\n";
        logFile << $$->name << "\n";
    } 
    | NOT {
        //cout << "Found NOT\n\n\n\n\n";
    }
    unary_expression {
        //cout << "Found NOT\n\n\n\n";
        $$ = new Extra();
        $$->name += "! ";
        $$->name += $3->name;
        $$->type = $3->type;
        logFile << "Line " << yylineno << ": ";
        logFile << "unary_expression : NOT unary_expression\n";
        logFile << $$->name << "\n";
    }
    | factor {
        $$ = new Extra();
        $$ = $1;
        logFile << "Line " << yylineno << ": ";
        logFile << "unary_expression : factor\n";
        logFile << $$->name << "\n";
    }
    
    ;
factor : variable {
        $$ = new Extra();
        $$ = $1;
        logFile << "Line " << yylineno << ": ";
        logFile << "factor : variable\n";
        logFile << $$->name << "\n";
    }
    | ID LPAREN argument_list RPAREN {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += '(';
        $$->name += $3->name;
        $$->name += ")";
        SymbolInfo *ret_info = sym_tab->fullLookUp($1->name, "FUNC");
        if(ret_info == nullptr) {
            total_errors++;
            errorFile << "Error at line " << yylineno << " ";
            errorFile << "Undeclared function " << $1->name << "\n";
        }
        else {
            if(ret_info->isFunction) {
                if(ret_info->params.size() != $3->arg_list.size()) {
                    total_errors++;
                    errorFile << "Error at line " << yylineno << " ";
                    errorFile << "Parameters count doesnot match\n";
                }
                else {
                    for(int i = 0; i < (int)ret_info->params.size(); i++) {
                        if(ret_info->params[i].first != $3->arg_list[i].first) {
                            total_errors++;
                            errorFile << "Error at line " << yylineno << " ";
                            errorFile << "Parameter type doesnot match\n";
                            //break;
                        }
                    }
                }
            }
            else {
                total_errors++;
                errorFile << "Error at line " << yylineno << " ";
                errorFile << "This is not a function\n";
            }
        }
        SymbolInfo *temp_temp = sym_tab->fullLookUp($1->name, "FUNC");
        if(temp_temp != nullptr) $$->type = temp_temp->dataType;
        //$$->type = $1->dataType;
        //errorFile << "#####" << $1->dataType << "\n";
        logFile << "Line " << yylineno << ": ";
        logFile << "factor : ID LPAREN argument_list RPAREN\n";
        logFile << $$->name << "\n";
    }
    | LPAREN expression RPAREN {
        $$ = new Extra();
        $$->name += '(';
        $$->name += $2->name;
        $$->name += ')';
        $$->type = $2->type;
        logFile << "Line " << yylineno << ": ";
        logFile << "factor : LPAREN expression RPAREN\n";
        logFile << $$->name << "\n";
    }
    | CONST_INT {
        $$ = new Extra();
        $$->name += $1->name;
        $$->type = "int";
        logFile << "Line " << yylineno << ": ";
        logFile << "factor : CONST_INT\n";
        logFile << $$->name << "\n";
    }
    | CONST_FLOAT {
        $$ = new Extra();
        $$->name += $1->name;
        $$->type = "float";
        logFile << "Line " << yylineno << ": ";
        logFile << "factor : CONST_FLOAT\n";
        logFile << $$->name << "\n";
    }
    | variable INCOP {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += "++";
        $$->type = $1->type;
        logFile << "Line " << yylineno << ": ";
        logFile << "factor : variable INCOP\n";
        logFile << $$->name << "\n";
    }
    | variable DECOP {
        $$ = new Extra();
        $$->name += $1->name;
        $$->name += "--";
        $$->type = $1->type;
        logFile << "Line " << yylineno << ": ";
        logFile << "factor : variable DECOP\n";
        logFile << $$->name << "\n";
    }   
    ;
argument_list : arguments {
        $$ = new Extra();
        $$ = $1;
        logFile << "Line " << yylineno << ": ";
        logFile << "argument_list : arguments\n";
        logFile << $$->name << "\n";
    }
    ;
arguments : arguments COMMA logic_expression {
        $$ = new Extra();
        $$ = $1;
        $$->name += ",";
        $$->name += $3->name;
        $$->arg_list.push_back({$3->type, $3->name});
        logFile << "Line " << yylineno << ": ";
        logFile << "arguments : arguments COMMA logic_expression\n";
        logFile << $$->name << "\n";
    }
    | logic_expression {
        $$ = new Extra();
        $$ = $1;
        $$->arg_list.push_back({$1->type, $1->name});
        logFile << "Line " << yylineno << ": ";
        logFile << "arguments : logic_expression\n";
        logFile << $$->name << "\n";
    }
    ;
%%

main(int argc,char *argv[])
{
    if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
    
    yyin = fin;
    yyparse();
    sym_tab->printAll(&logFile);
    logFile << "Total Lines : " << yylineno << "\n";
    logFile << "Total errors : " << total_errors << "\n";
}