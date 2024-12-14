Compiler-Sessional Project

This repository contains a custom-built compiler implementation developed as part of an academic sessional course. The project demonstrates the use of a lexical analyzer, parser, and symbol table management to process and interpret source code effectively.
Features

    Lexical Analysis: Tokenization of source code using a .l (Lex file).
    Parsing: Syntactic analysis implemented with a .y (YACC/Bison file).
    Symbol Table Management: Efficient handling of scope and symbol information using C++ classes.
    Extensibility: Modular design allows easy expansion and testing of compiler features.

Files Overview

    1805020.l:
        Lex file for lexical analysis.
        Defines token patterns for source code.
    1805020.y:
        YACC/Bison file for parsing.
        Implements grammar rules and syntax checking.
    1805020_ScopeTable.cpp:
        Implementation of scope tables for managing scopes during compilation.
    1805020_SymbolTable.cpp:
        Implementation of symbol table functionalities, including insertion, deletion, and lookup of symbols.
    1805020_symbolInfo.cpp:
        Defines and manages information about symbols, such as types and attributes.
    Extra.cpp:
        Additional code components for testing or extended functionality.

How to Run

    Dependencies:
        GCC or another C++ compiler.
        Flex and Bison tools installed.

    Steps:
        Generate the lexical analyzer:

flex 1805020.l

Generate the parser:

bison -d 1805020.y

Compile the generated C files along with the symbol table implementations:

g++ -o compiler lex.yy.c 1805020.tab.c 1805020_ScopeTable.cpp 1805020_SymbolTable.cpp 1805020_symbolInfo.cpp

Run the compiled program:

        ./compiler <input_file>

    Testing:
        Provide test input files to verify the lexical analysis, parsing, and symbol table functionalities.

Future Work

    Add semantic analysis and code generation.
    Improve error handling and reporting.
    Extend the grammar rules to support more complex constructs.

License

This project is for educational purposes and follows the academic guidelines for compiler development.
