#pragma once
#include "1805020_ScopeTable.cpp"
#include<bits/stdc++.h>
using namespace std;

class SymbolTable {
	ScopeTable *currentScopeTable;
public:
	SymbolTable(int n) {
		currentScopeTable = new ScopeTable(n, NULL);
	}
	void deleteScopeTable(ScopeTable *current) {
		if(current == nullptr) return ;
		if(current -> getParentScope() != nullptr) deleteScopeTable(current -> getParentScope());
		delete(current);
	}
	~SymbolTable() {
		deleteScopeTable(currentScopeTable);
	}
	ScopeTable *getCurrentScopeTable() {
		return currentScopeTable;
	}
	void setCurrentScopeTable(ScopeTable *newScopeTable) {
		currentScopeTable = newScopeTable;
	}
	void enterScope(int n) {
		ScopeTable *newScopeTable = new ScopeTable(n, currentScopeTable);
		cout << "New scope table with Id " << newScopeTable -> getId() << " created\n";
		setCurrentScopeTable(newScopeTable);
	}
	void exitScope() {
		ScopeTable *prev = currentScopeTable;
		cout << "ScopeTable with Id " << prev -> getId() << " removed\n";
		currentScopeTable = currentScopeTable -> getParentScope();
		delete(prev);
		//currentScopeTable->decreaseChildCount();
	}
	bool insertSymbol(SymbolInfo symbol) {
		return currentScopeTable -> Insert(symbol);
	}
	void removeSymbol (string symbolName, string isFunction) {
		currentScopeTable -> deletion(symbolName, isFunction);
	}
	SymbolInfo *lookUp (string name, string type) {
		ScopeTable *curr = currentScopeTable;
		SymbolInfo *temp = nullptr;
		if(curr != nullptr)
		temp = curr -> lookUp(name, type);
		return temp;
		//cout << "Not found\n";
	}
	SymbolInfo *fullLookUp (string name, string type) {
		ScopeTable *curr = currentScopeTable;
		while(curr != nullptr) {
			//cout << "here\n";
			SymbolInfo* temp = curr -> lookUp(name, type);
			if(temp != nullptr) return temp;
			curr = curr -> getParentScope();
		}
		SymbolInfo *temp = nullptr;
		return temp;
		//cout << "Not found\n";
	}
	void printCurrent(ofstream *logFile) {
		currentScopeTable -> print(logFile);
	}
	void printAll(ofstream *logFile) {
		ScopeTable *curr = currentScopeTable;
		while(curr != nullptr) {
			curr -> print(logFile);
			cout << "\n\n";
			curr = curr -> getParentScope();
		}
	}
};


