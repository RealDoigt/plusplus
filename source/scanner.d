module scanner;
import std.conv;
import token_class;
import token_type;
import std.string;
import std.array;
import error;

class Scanner
{
    private
    {
        wstring source;
        Token[] tokens;

        int start = 0,
        current = 0,
        line = 1;
    }

    this(wstring source)
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
                    tokens ~= new Token(TokenType.endOfLine, "\\n", line);
                    ++line;
                    break;

                case '+':

                    if (match(' '))
                    {
                        addToken(TokenType.one);
                        consumeBasicOperator;
                    }

                    else if (match('+'))
                    {
                        if (matchPair('=', '='))
                            addToken(TokenType.greaterOrEqual);

                        else addToken(TokenType.allocate);
                    }

                    else if (match('-'))
                        addToken(TokenType.leftShift);

                    else if (match('±'))
                        addToken(TokenType.and);

                    else if (match('='))
                        addToken(TokenType.not);

                    else goto default;
                    break;

                case '-':

                    if (match(' '))
                    {
                        addToken(TokenType.minusOne);
                        consumeBasicOperator;
                    }

                    else if (match('+'))
                        addToken(TokenType.rightShift);

                    else if (match('-'))
                    {
                        if (matchPair('=', '='))
                            addToken(TokenType.lowerOrEqual);

                        if (matchPair('-', '-'))
                            addToken(TokenType.deallocateAll);

                        else addToken(TokenType.deallocate);
                    }

                    else if (match('±'))
                        addToken(TokenType.or);

                    else if (match('#'))
                        addToken(TokenType.endOfBlock);

                    else goto default;
                    break;

                case '±':

                    if (match(' '))
                    {
                        addToken(TokenType.zero);
                        consumeBasicOperator;
                    }

                    else if (match('+'))
                        addToken(TokenType.jump);

                    else if (match('-'))
                        addToken(TokenType.createLabel);

                    else if (match('±'))
                        addToken(TokenType.jumpIfTrue);

                    else if (match('='))
                        addToken(TokenType.xor);

                    else goto default;
                    break;

                case '#':

                    if (match(' '))
                        addToken(TokenType.accessValue);

                    else if (match('+'))
                        addToken(TokenType.input);

                    else if (match('-'))
                        addToken(TokenType.print);

                    else if (match('±'))
                        addToken(TokenType.accessIA);

                    else if (match('#'))
                        addToken(TokenType.asChar);

                    else goto default;
                    break;

                case '=':

                    if (match(' '))
                        addToken(TokenType.assign);

                    else if (match('='))
                        addToken(TokenType.equals);

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

        void addToken(TokenType type)
        {
            tokens ~= new Token(type, source[start..current], line);
        }

        auto match(wchar expected)
        {
            if (isAtEnd) return false;
            if (source[current] != expected) return false;

            ++current;
            return true;
        }

        auto matchPair(wchar expectedA, wchar expectedB)
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
                addToken(TokenType.plus);

            else if(matchPair('+', ' '))
                addToken(TokenType.minus);
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
