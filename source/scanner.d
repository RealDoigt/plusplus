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
        auto isAtEnd()
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

                case '\n':
                    tokens ~= Token(TokenType.endOfLine, "\\n", line);
                    break;

                case '+':

                    if (match(' '))
                    {
                        tokens ~= new Token(TokenType.one, "+ ", line);
                        consumeBasicOperator;
                    }

                    else if (match('+'))
                        tokens ~= new Token(TokenType.allocate, "++", line);

                    else if (match('-'))
                        tokens ~= new Token(TokenType.leftShift, "+-", line);

                    else if (match('±'))
                        tokens ~= new Token(TokenType.and, "+±", line);

                    else if (match('='))
                        tokens ~= new Token(TokenType.not, "+=", line);

                    else goto default;
                    break;

                case '-':

                    if (match(' '))
                    {
                        tokens ~= new Token(TokenType.minusOne, "- ", line);
                        consumeBasicOperator;
                    }

                    else if (match('+'))
                        tokens ~= new Token(TokenType.rightShift, "-+", line);

                    else if (match('-'))
                        tokens ~= new Token(TokenType.deallocate, "--", line);

                    else if (match('±'))
                        tokens ~= new Token(TokenType.or, "-±", line);

                    else if (match('#'))
                        tokens ~= new Token(TokenType.endOfBlock, "-#", line);

                    else goto default;
                    break;

                case '±':

                    if (match(' '))
                    {
                        tokens ~= new Token(TokenType.zero, "± ", line);
                        consumeBasicOperator;
                    }

                    else if (match('+'))
                        tokens ~= new Token(TokenType.jump, "±+", line);

                    else if (match('-'))
                        tokens ~= new Token(TokenType.createLabel, "±-", line);

                    else if (match('±'))
                        tokens ~= new Token(TokenType.jumpIfTrue, "±±", line);

                    else if (match('='))
                        tokens ~= new Token(TokenType.xor, "±=", line);

                    else goto default;
                    break;

                case '#':

                    if (match(' '))
                        tokens ~= new Token(TokenType.accessValue, "# ", line);

                    else if (match('+'))
                        tokens ~= new Token(TokenType.input, "#+", line);

                    else if (match('-'))
                        tokens ~= new Token(TokenType.print, "#-", line);

                    else if (match('±'))
                        tokens ~= new Token(TokenType.accessIA, "#±", line);

                    else if (match('#'))
                        tokens ~= new Token(TokenType.asChar, "##", line);

                    else goto default;
                    break;

                case '=':

                    if (match(' '))
                        tokens ~= new Token(TokenType.assign, "= ", line);

                    else if (match('='))
                        tokens ~= new Token(TokenType.equals, "==", line);

                    else goto default;
                    break;

                default:
                    line.reportError("Unexpected character %x".format(source[current - 1]));
                    break;
            }
        }

        auto advance()
        {
            return source[current++];
        }

        void addToken(TokenType type, BoxedValue litteral = null)
        {
            auto text = source[start..current];
            tokens ~= new Token(type, text, litteral, line);
        }

        auto match(char expected)
        {
            if (isAtEnd) return false;
            if (source[current] != expected) return false;

            ++current;
            return true;
        }

        auto matchPair(char expectedA, char expectedB)
        {
            if (peek == expectedA && peekNext == expectedB)
            {
                current += 2;
                return true;
            }

            return false;
        }

        void consumeBasicOperator()
        {
            if (matchPair('+', ' '))
                tokens ~= new Token(TokenType.plus, "+ ", line);

            else if(matchPair('+', ' '))
                tokens ~= new Token(TokenType.minus, "- ", line);
        }

        auto peek()
        {
            if (isAtEnd) return '\0';
            return source[current];
        }

        auto peekNext()
        {
            if (current + 1 >= source.length) return '\0';
            return source[current + 1];
        }
    }
}
