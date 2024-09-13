#pragma once
#include<bits/stdc++.h>
using namespace std;

class SymbolInfo {
	public:
	string name;
	string type;
	SymbolInfo *next;
	bool isArray = false;
	bool isFunction = false;
	bool isDefined = false;
	bool isDeclared = false;
	string dataType;
	vector<pair<string, string>> params;
		SymbolInfo(string n, string t) {
			name = n;
			type = t;
			next = nullptr;
			isArray = false;
			isFunction = false;
			isDefined = false;
			isDeclared = false;
		}
		string getName() {
			return name;
		}
		string getType() {
			return type;
		}
		void setName(string n) {
			name = n;
		}
		void setType(string t) {
			type = t;
		}
		SymbolInfo *getNext() {
			return next;
		}
		void setNext(SymbolInfo *nxt) {
			next = nxt;
		}
		void setIsFunction() {
			isFunction = true;
		}
		void setIsArray() {
			isArray = true;
		}
		void setDataType(string type) {
			dataType = type;
		}
};
