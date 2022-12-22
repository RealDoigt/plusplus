import token_type;
import std.stdio;
import std.file;
import scanner;
import std.string;
import std.conv;

void run (wstring source)
{
    auto scanner = new Scanner(source);
    auto tokens = scanner.scanTokens;

    foreach (token; tokens)
        token.toString.writeln;
}

void runFile(string path)
{
    scope (failure)
        "the system encountered a problem with the file".writeln;

    path.readText.to!wstring.run;
}

void main(string[] args)
{
    if (args.length > 1) 
    { 
        colin = args.length > 3 && args[2] == "-colin";
        args[1].runFile;
    }
    else "++ Interpreter usage: ppi <file>".writeln;
}
