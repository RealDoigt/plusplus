module error;
import std.string;
import std.stdio;

auto hadError = false;

void report(int line, string where, string message)
{
    "Error at line %d %s %s".format(line, where, message).writeln;
}

void reportError(int line, string message, int column = 0)
{
    report(line, column > 0 ? "at column %d".format(column) : "", message);
}
