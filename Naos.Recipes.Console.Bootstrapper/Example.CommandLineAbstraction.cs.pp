// --------------------------------------------------------------------------------------------------------------------
// <copyright file="ExampleCommandLineAbstraction.cs" company="Naos">
//    Copyright (c) Naos 2017. All rights reserved.
// </copyright>
// --------------------------------------------------------------------------------------------------------------------

namespace $rootnamespace$
{
    using System;
    using System.Diagnostics;
    using System.Linq;

    using CLAP;

    using Its.Configuration;
    using Its.Log.Instrumentation;

    using Naos.Diagnostics.Domain;
    using Naos.Logging.Domain;

    using Naos.Recipes.Configuration.Setup;

    using OBeautifulCode.Collection.Recipes;

    using Spritely.Recipes;

    /// <summary>
    /// Abstraction for use with <see cref="CLAP" /> to provide basic command line interaction.
    /// </summary>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1053:StaticHolderTypesShouldNotHaveConstructors", Justification = "Cannot be static for command line contract.")]
    public class ExampleCommandLineAbstraction
    {
        /// <summary>
        /// Entry point to simulate a failure.
        /// </summary>
        /// <param name="debug">Optional indication to launch the debugger from inside the application (default is false).</param>
        /// <param name="message">Message to use when creating a SimulatedFailureException.</param>
        /// <param name="environment">Optional value to use when setting the Its.Configuration precedence to use specific settings.</param>
        [Verb(Aliases = "", IsDefault = false, Description = "Throws an exception with provided message to simulate an error and confirm correct setup;\r\n            example usage: [Harness].exe fail /message='My Message.'\r\n                           [Harness].exe fail /message='My Message.' /debug=true\r\n                           [Harness].exe fail /message='My Message.' /environment=ExampleDevelopment\r\n                           [Harness].exe fail /message='My Message.' /environment=ExampleDevelopment /debug=true\r\n")]
        public static void Fail(
            [Aliases("")] [Description("Launches the debugger.")] [DefaultValue(false)] bool debug,
            [Aliases("")] [Required] [Description("Message to use when creating a SimulatedFailureException.")] string message,
            [Aliases("")] [Description("Sets the Its.Configuration precedence to use specific settings.")] [DefaultValue(null)] string environment)
        {
            /*---------------------------------------------------------------------------*
             * Any method should run this logic to debug, setup config & logging, etc.   *
             *---------------------------------------------------------------------------*/
            CommonSetup(debug, environment);

            /*---------------------------------------------------------------------------*
             * Throw an exception after all logging is setup which will excercise the    *
             * top level error handling and can ensure correct setup.  Uses the type     *
             * SimulatedFailureException from Naos.Diagnostics.Domain so they can easily *
             * be filtered out if needed to avoid panic or triggering alarms.            *
             *---------------------------------------------------------------------------*/
            throw new SimulatedFailureException(message);
        }

        /// <summary>
        /// Entry point to log a message and exit gracefully.
        /// </summary>
        /// <param name="debug">Optional indication to launch the debugger from inside the application (default is false).</param>
        /// <param name="message">Message to log.</param>
        /// <param name="environment">Optional value to use when setting the Its.Configuration precedence to use specific settings.</param>
        [Verb(Aliases = "", IsDefault = false, Description = "Logs the provided message to confirm correct setup;\r\n            example usage: [Harness].exe pass /message='My Message.'\r\n                           [Harness].exe pass /message='My Message.' /debug=true\r\n                           [Harness].exe pass /message='My Message.' /environment=ExampleDevelopment\r\n                           [Harness].exe pass /message='My Message.' /environment=ExampleDevelopment /debug=true\r\n")]
        public static void Pass(
            [Aliases("")] [Description("Launches the debugger.")] [DefaultValue(false)] bool debug,
            [Aliases("")] [Required] [Description("Message to log.")] string message,
            [Aliases("")] [Description("Sets the Its.Configuration precedence to use specific settings.")] [DefaultValue(null)] string environment)
        {
            /*---------------------------------------------------------------------------*
             * Any method should run this logic to debug, setup config & logging, etc.   *
             *---------------------------------------------------------------------------*/
            CommonSetup(debug, environment);

            /*---------------------------------------------------------------------------*
             * Write message after all logging is setup which will confirm setup.        *
             *---------------------------------------------------------------------------*/
            Log.Write(() => message);
        }

        private static void CommonSetup(bool debug, string environment)
        {
            /*---------------------------------------------------------------------------*
             * Useful for launching the debugger from the command line and making sure   *
             * it is connected to the instance of the IDE you want to use.               *
             *---------------------------------------------------------------------------*/
            if (debug)
            {
                Debugger.Launch();
            }

            /*---------------------------------------------------------------------------*
             * Setup deserialization logic for any use of Its.Configuration reading      *
             * config files from the '.config' directory with 'environment' sub folders  *
             * the chain of responsibility is set in the App.config file using the       *
             * 'Its.Configuration.Settings.Precedence' setting.  You can override the    *
             * way this is used by specifying a different diretory for the config or     *
             * providing additonal precedence values using                               *
             * ResetConfigureSerializationAndSetValues.                                  *
             *---------------------------------------------------------------------------*/
            if (!string.IsNullOrWhiteSpace(environment))
            {
                Config.ResetConfigureSerializationAndSetValues(environment, announcer: Console.WriteLine);
            }
            else
            {
                Config.ConfigureSerialization(Console.WriteLine);
            }

            /*---------------------------------------------------------------------------*
             * Initialize logging; this sets up Its.Log which is what gets used through- *
             * out the code.  All Hangfire logging will also get sent through it.  This  *
             * can be swapped out to send all Its.Log messages to another logging frame- *
             * work if there is already one in place.                                    *
             *---------------------------------------------------------------------------*/
            var logProcessorSettings = Settings.Get<LogProcessorSettings>();
            LogProcessing.Instance.Setup(logProcessorSettings, Console.WriteLine);
        }

        /// <summary>
        /// Error method to call from CLAP; a 1 will be returned as the exit code if this is entered since an exception was thrown.
        /// </summary>
        /// <param name="context">Context provided with details.</param>
        [Error]
        public static void Error(ExceptionContext context)
        {
            new { context }.Must().NotBeNull().OrThrowFirstFailure();

            // change color to red
            var originalColor = Console.ForegroundColor;
            Console.ForegroundColor = ConsoleColor.Red;

            // parser exception or
            if (context.Exception is CommandLineParserException)
            {
                Console.WriteLine("Failure parsing command line arguments.  Run the exe with the 'help' command for usage.");
                Console.WriteLine("   " + context.Exception.Message);
            }
            else
            {
                Console.WriteLine("Failure during execution.");
                Console.WriteLine("   " + context.Exception.Message);
                Console.WriteLine(string.Empty);
                Console.WriteLine("   " + context.Exception);
                Log.Write(context.Exception);
            }

            // restore color
            Console.WriteLine();
            Console.ForegroundColor = originalColor;
        }

        /// <summary>
        /// Help method to call from CLAP.
        /// </summary>
        /// <param name="helpText">Generated help text to display.</param>
        [Empty]
        [Help(Aliases = "h,?,-h,-help")]
        [Verb(IsDefault = true)]
        public static void Help(string helpText)
        {
            new { helpText }.Must().NotBeNull().OrThrowFirstFailure();

            Console.WriteLine("   Usage");
            Console.Write("   -----");

            // strip out the usage info about help, it's confusing
            helpText = helpText.Split(new[] { Environment.NewLine }, StringSplitOptions.None).Skip(3).ToNewLineDelimited();
            Console.WriteLine(helpText);
            Console.WriteLine();
        }
    }
}