using System.Collections.Generic;

namespace plusplusinterpreter
{
    class Scanner
    {
        List<TokenType> tokens = new List<TokenType>();
        int currentLine = 0, currentColumn = 0;
        bool errorHasOccured = false;
        ErrorType error = ErrorType.None;

        public TokenType this[int index] => index > 0 && index < tokens.Count ? tokens[index] : TokenType.Invalid;
        public bool ErrorHasOccured => errorHasOccured;
        public ErrorType Error => error;
        public int LastScannedLine => currentLine;
        public int LastScannedColumn => currentColumn;
        public int TokenCount => tokens.Count;

        TokenType LastToken => tokens[tokens.Count - 1];
        TokenType PreviousToken => tokens[tokens.Count - 2];

        public Scanner(string[] code, bool inDiagnosticMode = false)
        {
            if (code == null || code.Length == 0)
            {
                error = ErrorType.EmptyCode;
                errorHasOccured = true;

                if (inDiagnosticMode)
                {
                    ErrorMessage.PrintError(error, 0, 0);
                    Program.PrintErr("Scanning cannot recover from this error... The process will stop immediately.");
                }

                return;
            }

            for (; currentLine < code.Length; ++currentLine, tokens.Add(TokenType.EOL))
            {
                if (code[currentLine].Length % 2 != 0 && !code[currentLine].Contains("  "))
                {
                    error = ErrorType.MissingCharacter;
                    errorHasOccured = true;

                    if (inDiagnosticMode)
                    {
                        ErrorMessage.PrintError(error, currentLine, currentColumn);
                        Program.PrintWarn($"Line {currentLine} will be skipped to avoid crashing.");
                        Program.PrintInfo("Since all code instructions are character pairs, the scanner evaluates two characters at once.");
                        Program.PrintInfo("The most common error is a missing space.");
                    }

                    else return;
                }

                // diagnostic mode shenanigans
                if (error != ErrorType.MissingCharacter)
                    for (currentColumn = 0; currentColumn + 2 < code[currentLine].Length; currentColumn += 2)
                    {
                        tokens.Add(GetTokenType(code[currentLine].Substring(currentColumn, 2)));

                        if (tokens.Count > 0)
                        {
                            if (LastToken == TokenType.Invalid)
                            {
                                Program.PrintWarn(code[currentLine].Substring(currentColumn, 2));
                                error = ErrorType.InvalidCharacter;
                                errorHasOccured = true;

                                if (inDiagnosticMode) ErrorMessage.PrintError(error, currentLine, currentColumn);
                                else return;
                            }

                            if (LastToken == TokenType.Comment)
                            {
                                tokens.RemoveAt(tokens.Count - 1);
                                break;
                            }
                        }

                        ContextualizeScan();
                    }
            }

            tokens.Add(TokenType.EOF);

            if (inDiagnosticMode && errorHasOccured) Program.PrintWarn("Due to one or several errors occuring during the Scanning phase, the next set of diagnostics may not be accurate.");
        }

        static TokenType GetTokenType(string pair)
        {
            if (pair[0] == '-')
                switch (pair[1])
                {
                    case ' ':
                        return TokenType.Minus;

                    case '+':
                        return TokenType.RightShift;

                    case '-':
                        return TokenType.Deallocate;

                    case '±':
                        return TokenType.Or;

                    case '#':
                        return TokenType.EOB;
                }

            if (pair[0] == '+')
                switch (pair[1])
                {
                    case ' ':
                        return TokenType.Plus;

                    case '+':
                        return TokenType.Allocate;

                    case '-':
                        return TokenType.LeftShift;

                    case '±':
                        return TokenType.And;

                    case '=':
                        return TokenType.Not;
                }

            if (pair[0] == '#')
                switch (pair[1])
                {
                    case ' ':
                        return TokenType.AccessValue;

                    case '#':
                        return TokenType.AsChar;

                    case '±':
                        return TokenType.AccessIA;

                    case '-':
                        return TokenType.Print;

                    case '+':
                        return TokenType.Input;
                }

            if (pair[0] == '±')
                switch (pair[1])
                {
                    case ' ':
                        return TokenType.Zero;

                    case '±':
                        return TokenType.JumpIfTrue;

                    case '+':
                        return TokenType.Jump;

                    case '-':
                        return TokenType.CreateLabel;

                    case '=':
                        return TokenType.Xor;
                }

            if (pair == "  ") return TokenType.Comment;
            if (pair == "= ") return TokenType.Assign;
            if (pair == "==") return TokenType.Equals;

            return TokenType.Invalid;
        }

        // This method looks at the previous scans and recontextualizes some tokens
        void ContextualizeScan()
        {
            if (tokens.Count > 1)
            {
                System.Action removeLast = () => tokens.RemoveAt(tokens.Count - 1);
                System.Action removeLastTwo = () => { removeLast(); removeLast(); };

                if (PreviousToken != TokenType.EOB && PreviousToken != TokenType.MinusOne && PreviousToken != TokenType.One && PreviousToken != TokenType.Zero)
                {
                    if (LastToken == TokenType.Plus)
                    {
                        removeLast();
                        tokens.Add(TokenType.One);
                    }

                    else if (LastToken == TokenType.Minus)
                    {
                        removeLast();
                        tokens.Add(TokenType.MinusOne);
                    }
                }

                if (LastToken == TokenType.Equals && PreviousToken == TokenType.Allocate)
                {
                    removeLastTwo();
                    tokens.Add(TokenType.GreaterOrEqual);
                }

                else if (LastToken == TokenType.Equals && PreviousToken == TokenType.Deallocate)
                {
                    removeLastTwo();
                    tokens.Add(TokenType.LowerOrEqual);
                }

                else if (LastToken == TokenType.Deallocate && PreviousToken == TokenType.Deallocate)
                {
                    removeLastTwo();
                    tokens.Add(TokenType.DeallocateAll);
                }
            }
        }
    }
}