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

        int start,
        current,
        line = 1,
        column = 1;
    }

    this(wstring source)
    {
        this.source = colin ? source.colinize : source;
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
                    column = 1;
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
                
                    auto faultyChar = source[current - 1];
                    
                    line.reportError
                    (
                        faultyChar == ' ' ? "Unexpected space" :
                        format("Unexpected character %x %s", faultyChar, faultyChar), 
                        column
                    );
                    break;
            }
        }

        auto advance()
        {
            ++column;
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

auto colinize(source)
{
    return source.replace("_+", "±");
}

auto colin = false;