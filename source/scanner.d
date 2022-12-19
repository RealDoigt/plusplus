module scanner;
import std.conv;
import token_class;
import token_type;
import std.string;
import std.array;
import error;
import box;

class Scanner
{
    private
    {
        string source;
        Token[] tokens;

        int start = 0,
        current = 0,
        line = 0;
    }

    this(string source)
    {
        this.source = source;
    }

    Token[] scanTokens()
    {
        while (!isAtEnd)
        {
            start = current;
            scanToken;
        }

        tokens ~= new Token(TokenType.endOfFile, "", null, line);
        return tokens;
    }

    private
    {
        bool isAtEnd()
        {
            return current >= source.length;
        }

        void scanToken()
        {
            switch (advance)
            {
                case '#':

                    while (peek != '\n' && !isAtEnd)
                        advance;

                    break;

                case '\n', '\r', '\t': break; // we're ignoring some whitespace

                default:
                    line.reportError("Unexpected character %x".format(source[current - 1]));
                    break;
            }
        }

        char advance()
        {
            return source[current++];
        }

        void addToken(TokenType type, BoxedValue litteral = null)
        {
            auto text = source[start..current];
            tokens ~= new Token(type, text, litteral, line);
        }

        bool match(char expected)
        {
            if (isAtEnd) return false;
            if (source[current] != expected) return false;

            ++current;
            return true;
        }

        bool matchPair(char expectedA, char expectedB)
        {
            if (peek == expectedA && peekNext == expectedB)
            {
                current += 2;
                return true;
            }

            return false;
        }

        char peek()
        {
            if (isAtEnd) return '\0';
            return source[current];
        }

        char peekNext()
        {
            if (current + 1 >= source.length) return '\0';
            return source[current + 1];
        }
    }
}
