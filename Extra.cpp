#include<bits/stdc++.h>
#include "1805020_SymbolTable.cpp"
using namespace std;
class Extra {
    public:
    string name;//name means text
    string type;//type means data_type 
    string return_type;//function return type
    vector<SymbolInfo*> declaration_list;
    vector<pair<string, string>> params;
    vector<pair<string, string>> arg_list;
    Extra(){

    }
    void set_name(string text) {
        name = text;
    }
    void set_type(string text) {
        type = text;
    }
};
