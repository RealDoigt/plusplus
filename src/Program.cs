using ConsolePaint;
using System;
using System.IO;
using static System.Console;
using System.Collections.Generic;

namespace plusplusinterpreter
{
    class Program
    {
        static void Print(ConsoleColor foreground, string text) => new ColorString(ConsoleColor.Black, foreground, text).WriteLine();

        public static void PrintErr(string text) => Print(ConsoleColor.Red, text);

        public static void PrintInfo(string text) => Print(ConsoleColor.White, text);

        public static void PrintWarn(string text) => Print(ConsoleColor.Yellow, text);

        static void Main(string[] args)
        {
            //goto test;
            if (new System.Collections.Generic.List<PlatformID>() { PlatformID.Unix, PlatformID.MacOSX }.Contains(Environment.OSVersion.Platform) || BackgroundColor != ConsoleColor.Black)
            {
                BackgroundColor = ConsoleColor.Black;
                Clear();
            }

            const string INVALID_OPT = "Invalid option.";
            var inDiagnosticMode = false;
            string[] sourceFiles = null;

            if (args == null || args.Length == 0)
            {
                PrintErr("Argument cannot be emtpy. type 'ppi -h' for help.");
                return;
            }

            if (args[0][0] == '-')
                switch (args[0].Substring(1))
                {
                    case "dm":

                        inDiagnosticMode = true;

                        if (args[1] == "-p") goto case "p";
                        break;

                    case "h":

                        if (args.Length == 1)
                        {
                            PrintInfo("To run a single file, type 'ppi <.pp file>'");
                            PrintInfo("To find out about other options type 'ppi -l'");
                            PrintInfo("To get help on a specific option type 'ppi -h <option name without dash>'");
                        }

                        else
                            switch (args[1])
                            {
                                case "dm":

                                    PrintInfo("This is the diagnostic mode option. It will prevent the interpreter from stopping on the first error.");
                                    PrintInfo("This option is useful for getting all errors at once and may improve debugging experience.");
                                    PrintInfo("Usage: 'ppi -dm <.pp file>'");
                                    break;

                                case "h":

                                    PrintInfo("This is the help option. It gives information on options.");
                                    PrintInfo("Usage: 'ppi -h <option name without dash>'");
                                    break;

                                case "ide":

                                    PrintInfo("This is the integrated development environment option. It helps coding ++ apps in real time.");
                                    PrintInfo("Usage: 'ppi -ide <.pp file>'");
                                    PrintInfo("Note: If the file doesn't exist, it will be created.");
                                    PrintInfo("Note: If no file name is given, you won't be able to save your changes.");
                                    PrintWarn("The IDE feature is an experimental work in progress and may or may not be suitable for writing ++ code.");
                                    break;

                                case "l":

                                    PrintInfo("This is the list option. This program will show a list of all available options.");
                                    PrintInfo("Usage: 'ppi -l'");
                                    break;

                                case "li":

                                    PrintInfo("This is the live interpreter option. The interpreter will start a session where code is interpreted as it is typed into the console.");
                                    PrintInfo("Usage: 'ppi -li'");
                                    break;

                                case "p":

                                    PrintInfo("This is the project option. The interpreter will read a whole project setup instead of just one file.");
                                    PrintInfo("Manually typing the files: 'ppi -p <.pp files>'");
                                    PrintInfo("The whole folder (only the top level): 'ppi -p f'");
                                    PrintInfo("Using a project configuration file: 'ppi -p <.txt file>'");
                                    PrintInfo("Note: you can't have a file called 'f.pp' if using the project option.");
                                    PrintWarn("Note: you must have an entry point file if you use the project option and you may only have one.");
                                    PrintWarn("Correct file names for an entry point are: start.pp, main.pp, index.pp and entry.pp");
                                    break;

                                default:
                                    PrintErr(INVALID_OPT);
                                    break;
                            }
                        return;

                    case "ide":
                        Live.Coding.StartIDESession();
                        return;

                    case "l":
                        foreach (var str in new[] { "dm", "h", "ide", "l", "li", "p" }) WriteLine(str);
                        return;

                    case "li":
                        Live.Coding.StartMinimalSession();
                        return;

                    case "p":

                        var indexOffset = inDiagnosticMode ? 1 : 0;
                        var dir = Directory.GetCurrentDirectory() + "\\";

                        if (args[1 + indexOffset] == "f")
                            sourceFiles = Directory.GetFiles(dir, "*.pp", SearchOption.TopDirectoryOnly);

                        else if (File.Exists($"{dir}{args[1 + indexOffset]}.txt"))
                        {
                            var fileContents = new Stack<string>();

                            foreach (var line in File.ReadAllLines($"{dir}{args[1 + indexOffset]}.txt"))
                                if (File.Exists($"{dir}{line}.pp")) fileContents.Push($"{dir}{line}.pp");

                            sourceFiles = fileContents.ToArray();
                        }

                        else
                        {
                            var contents = new Stack<string>();

                            for (int index = 1 + indexOffset; index < args.Length; ++index)
                                if (File.Exists($"{dir}{args[index]}.pp")) contents.Push($"{dir}{args[index]}.pp");

                            sourceFiles = contents.ToArray();
                        }

                        break;

                    default:
                        PrintErr(INVALID_OPT);
                        return;
                }

            if (sourceFiles == null && File.Exists($"{Directory.GetCurrentDirectory()}\\{args[args.Length - 1]}.pp")) sourceFiles = new[] { args[args.Length - 1] + ".pp" };

            else if (sourceFiles == null)
            {
                PrintErr("No valid source file was found. Make sure all the file are .pp files and that you don't use the extension directly the command line or the config file.");
                return;
            }

            var scanners = new Dictionary<string, Scanner>();

            foreach (var sourceFile in sourceFiles)
            {
                var indexOfLastSlash = sourceFile.LastIndexOf('\\');

                if (indexOfLastSlash >= 0)
                    scanners.Add
                    (
                        sourceFile.Substring
                        (
                            indexOfLastSlash, 
                            sourceFile.Substring(sourceFile.LastIndexOf(".pp")).Length - indexOfLastSlash
                        ), 
                        new Scanner(File.ReadAllLines(sourceFile), inDiagnosticMode)
                    );

                else scanners.Add(sourceFile, new Scanner(File.ReadAllLines(sourceFile), inDiagnosticMode));
            }

            // temporary
            foreach (var scanner in scanners)
            {
                if (scanner.Value.ErrorHasOccured && !inDiagnosticMode)
                    scanner.Value.Error.PrintError(scanner.Value.LastScannedLine, scanner.Value.LastScannedColumn);

                else for (int index = 0; index < scanner.Value.TokenCount; ++index) WriteLine(scanner.Value[index]);
            }

            //test:
           // var test = new Scanner(File.ReadAllLines("helloworld.pp"), true);
        }
    }
}
