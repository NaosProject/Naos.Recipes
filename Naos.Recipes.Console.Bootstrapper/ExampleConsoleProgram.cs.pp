// --------------------------------------------------------------------------------------------------------------------
// <copyright file="ExampleConsoleProgram.cs" company="Naos">
//    Copyright (c) Naos 2017. All Rights Reserved.
// </copyright>
// --------------------------------------------------------------------------------------------------------------------

namespace $rootnamespace$
{
    using System;

    using CLAP;

    using Its.Log.Instrumentation;

    /// <summary>
    /// Exmaple of a main entry point of the application, just delete your 'Program.cs' is setup.
    /// </summary>
    public static class ExampleConsoleProgram
    {
        /// <summary>
        /// Main entry point.
        /// </summary>
        /// <param name="args">Arguments for application.</param>
        /// <returns>Exit code.</returns>
        public static int Main(string[] args)
        {
            try
            {
                WriteAsciiArt(Console.WriteLine);

                /*---------------------------------------------------------------------------*
                 * This is just a pass through to the CLAP implementation of the harness,    *
                 * it will parse the command line arguments and provide multiple entry       *
                 * points as configured.  The recipe will install a file named               *
                 * 'ExampleCommandLineAbstraction' which should be renamed to                *
                 * 'CommandLineAbstraction' to compile, this will prevent future package     *
                 * updates from overwriting any custom logic.                                *
                 *---------------------------------------------------------------------------*/
                var exitCode = Parser.Run<ExampleCommandLineAbstraction>(args);
                return exitCode;
            }
            catch (Exception ex)
            {
                /*---------------------------------------------------------------------------*
                 * This should never be reached but is here as a last ditch effort to ensure *
                 * errors are not lost.                                                      *
                 *---------------------------------------------------------------------------*/
                Console.WriteLine(string.Empty);
                Console.WriteLine(ex.Message);
                Console.WriteLine(ex.StackTrace);
                Console.WriteLine(string.Empty);
                Log.Write(ex);

                return 1;
            }
        }

        private static void WriteAsciiArt(Action<string> announcer)
        {
            /*---------------------------------------------------------------------------*
             * Totally unecessary but just plain fun, link to build your own.            *
             * http://patorjk.com/software/taag/#f=Small%20Keyboard&t=NAOS%20Console     *
             *---------------------------------------------------------------------------*/

            announcer(@"______________________________________________________________________________");
            announcer(@"|                                                                            |");
            announcer(@"|                                                                            |");
            announcer(@"|     ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____       |");
            announcer(@"|    ||N |||A |||O |||S |||       |||C |||o |||n |||s |||o |||l |||e ||      |");
            announcer(@"|    ||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||      |");
            announcer(@"|    |/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|      |");
            announcer(@"|                                                                            |");
            announcer(@"|                                                                            |");
            announcer(@"|----------------------------------------------------------------------------|");
            announcer(@"|            Build your own at: http://patorjk.com/software/taag/            |");
            announcer(@"|____________________________________________________________________________|");
        }
    }
}