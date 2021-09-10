using System;

namespace plusplusinterpreter
{
    static class ErrorMessage
    {
        static public string GetErrorMessage(this ErrorType error, int line, int column)
        {
            var errorLocation = $"at line {line} and column {column}!";

            switch (error)
            {
                case ErrorType.None:
                    return "No error found.";

                case ErrorType.EmptyCode:
                    return "The code is either null or empty.";

                case ErrorType.MissingCharacter:
                    return $"There's a missing character {errorLocation}";

                case ErrorType.InvalidCharacter:
                    return $"There's an invalid character pair {errorLocation}";

                default:
                    return $"There's an error {errorLocation}";
            }
        }

        static public void PrintError(this ErrorType error, int line, int column) => Program.PrintErr(error.GetErrorMessage(line, column));
    }
}
