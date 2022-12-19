module token_class;
import token_type;
import std.string;
import std.variant;

class Token
{
    private
    {
        TokenType _type;
        wstring _lexeme;
        int _line;
    }

    this(TokenType type, wstring lexeme, int line)
    {
        _type = type;
        _line = line;
        _lexeme = lexeme;
    }

    TokenType type()
    {
        return _type;
    }

    wstring lexeme()
    {
        return _lexeme;
    }

    int line()
    {
        return _line;
    }

    override string toString()
    {
        return "%s %s".format(type, lexeme);
    }
}
