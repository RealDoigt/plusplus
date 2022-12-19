module token_class;
import token_type;
import std.string;
import std.variant;

class Token
{
    private
    {
        TokenType _type;
        string _lexeme;
        int _line;
    }

    this(TokenType type, string lexeme, int line)
    {
        this.type = type;
        this.line = line;
        this.lexeme = lexeme;
        this.litteral = litteral;
    }

    TokenType type()
    {
        return _type;
    }

    string lexeme()
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
