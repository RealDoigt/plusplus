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

        tokens ~= new Token(TokenType.endOfFile, "", line);
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
                case ' ':

                    if (match(' ')) // comments are double spaces
                        while (peek != '\n' && !isAtEnd)
                            advance;

                    else goto default;
                    break;

                case '+':

                    if (match(' '))
                    {
                        if (matchPair('+', ' '))
                            tokens ~= new Token(TokenType.one, "+ + ", line);

                        else tokens ~= new Token(TokenType.plus, "+ ", line);
                    }

                    else if (match('+'))
                        tokens ~= new Token(TokenType.allocate, "++", line);

                    else if (match('-'))
                        tokens ~= new Token(TokenType.leftShift, "+-", line);

                    else if (match('±'))
                        tokens ~= new Token(TokenType.and, "+±", line);

                    else if (match('='))
                        tokens ~= new Token(TokenType.not, "+=", line);

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
