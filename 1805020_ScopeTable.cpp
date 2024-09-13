#pragma once
#include<bits/stdc++.h>
#include "1805020_symbolInfo.cpp"
using namespace std;

class ScopeTable {
	SymbolInfo **hashTable;
	int bucketNo;
	ScopeTable *parentScope;
	string id;
	int childCount;
public:
	ScopeTable(int bucketNumber, ScopeTable *parent) {
		bucketNo = bucketNumber;
		hashTable = new SymbolInfo *[bucketNumber];
		for(int i = 0; i < bucketNo; i++) hashTable[i] = nullptr;
		parentScope = parent;
		if(parent == nullptr) {
			id = "1";
		}
		else {
			string parentId = parent -> getId();
			id = parentId;
			id += '.';
			int cnt = parent -> getChildCount();
			parent->increaseChildCount();
			cnt++;
			string conv = to_string(cnt);
			id += conv;
		}
    ///more work to be done;
		childCount = 0;
	}
	void deleteSymbolInfo(SymbolInfo *symbolInfo) {
		if(symbolInfo == nullptr) return ;
		if(symbolInfo -> getNext() != nullptr) deleteSymbolInfo(symbolInfo -> getNext());
		delete(symbolInfo);
	}
	~ScopeTable() {
		for(int i = 0; i < bucketNo; i++) {
			//cout << "reached " << i << "\n";
			deleteSymbolInfo(hashTable[i]);
		}
		delete(hashTable);
	}
	ScopeTable *getParentScope() {
		return parentScope;
	}
	void setParentScope(ScopeTable *newTable) {
		parentScope = newTable;
		return;
	}
	string getId() {
		return id;
	}
	int getChildCount() {
		return childCount;
	}
	void increaseChildCount() {
		childCount++;
	}
	void decreaseChildCount() {
		childCount--;
	}
	static unsigned int hashValue(string s) {
		unsigned int hash = 0;
		for(int i = 0; i < (int) s.size(); i++) {
			hash = (s[i]) + (hash << 6) + (hash << 16) - hash;
		}
		
		return hash;
	}
	bool Insert(SymbolInfo s) {
		//freopen("logfile.txt", "a", stdout);
		int hashVal = hashValue(s.getName());
		int bucketPos = (int)(hashVal % (unsigned int)bucketNo);
		//cout << bucketPos << "\n";
		SymbolInfo *curr = hashTable[bucketPos];
		int cnt = 0;
		if(curr == nullptr) {
			//cout << "here1" << "\n";
			curr = new SymbolInfo(s.getName(), s.getType());
			//if(s.name == "var") cout << "!!!************!!!! is function: " << s.isFunction << "\n";
			curr->dataType = s.dataType;
			curr->isFunction = s.isFunction;
			curr->isDeclared = s.isDeclared;
			curr->isArray = s.isArray;
			curr->isDefined = s.isDefined;
			curr->params = s.params;
			hashTable[bucketPos] = curr;
			cout << "Inserted in ScopeTable# " << id << " at position " << bucketPos << ", " << cnt << "\n";
			return true;
		}
		else {
			SymbolInfo *prev;
			while(curr != nullptr and curr -> getName() != s.getName()) prev = curr, curr = curr -> getNext(), cnt++;
			if(curr == nullptr) {
				curr = new SymbolInfo(s.getName(), s.getType());
				curr->dataType = s.dataType;
				curr->isFunction = s.isFunction;
				curr->isDeclared = s.isDeclared;
				curr->isArray = s.isArray;
				curr->isDefined = s.isDefined;
				curr->params = s.params;
				prev->setNext(curr);
				cout << "Inserted in ScopeTable# " << id << " at position " << bucketPos << ", " << cnt << "\n";
				return true;
			}
			else {
				cout << "Insertion failed!!!Duplicate element found!!!";
				return false;
			}
		}
	}
	SymbolInfo* lookUp(string s, string t) {
		//freopen("logfile.txt", "a", stdout);
		int pos = hashValue(s) % bucketNo;
		//cout << pos << "\n";
		SymbolInfo *curr = hashTable[pos];
		//cout << curr -> getName() << "\n";
		int cnt = 0;
		while(curr != nullptr) {
			if(curr -> getName() == s) { 
				//if(s == "var") cout << "!!!!!!!!!!!!" << curr->isFunction << "\n";
				if(t == "FUNC" and curr -> isFunction) {
					cout << "Found at Scope table " << id << " at position " << pos <<", " << cnt << "\n";
					return curr;	
				}
				else if(t != "FUNC" and curr->isFunction == false) {
					//cout << "!!!!!!!!!!!" << curr->isFunction << "\n";
					cout << "Found at Scope table " << id << " at position " << pos <<", " << cnt << "\n";
					return curr;
				}
			}
			curr = curr -> getNext();
			cnt++;
		}
		return curr;
	}
	bool deletion(string symbolName, string isFunction) {
		//freopen("logfile.txt", "a", stdout);
		int pos = hashValue(symbolName) % bucketNo;
		SymbolInfo *curr = hashTable[pos];
		SymbolInfo *prev = nullptr;
		int cnt = 0;
		while(curr != nullptr) {
			if(curr -> getName() == symbolName and (isFunction != "FUNC" or curr->isFunction)) {
				if(prev != NULL) {
					prev -> setNext(curr -> getNext());
					delete(curr);
					cout << "Deleted Entry " << pos << ", " << cnt << " from current ScopeTable\n";
					return true;
				}
				else {
					hashTable[pos] = curr -> getNext();
					delete(curr);
					cout << "Deleted Entry " << pos << ", " << cnt << " from current ScopeTable\n";
				  return true;
				}
			}
			curr = curr -> getNext();
			cnt++;
		}
		cout << symbolName << " not found!!!\n";

		return false;
	}
	void print(ofstream *logFile) {
		//freopen("logfile.txt", "a", stdout);
		(*logFile) << "Printing Scope Table#" << id << "\n";
		for(int i = 0; i < bucketNo; i++) {
			(*logFile) << i << " ---> ";
			SymbolInfo *curr = hashTable[i];
			while(curr != NULL) {
				(*logFile) << "< " << curr -> getName() << " : " << curr -> getType() << " > ";
				curr = curr -> getNext();
			}
			(*logFile) << "\n";
		}
	}
};
