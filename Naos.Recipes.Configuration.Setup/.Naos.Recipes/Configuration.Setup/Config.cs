﻿// --------------------------------------------------------------------------------------------------------------------
// <copyright file="Config.cs" company="Naos">
//   Copyright 2017 Naos
// </copyright>
// <auto-generated>
//   Sourced from NuGet package. Will be overwritten with package update except in Naos.Recipes source.
// </auto-generated>
// --------------------------------------------------------------------------------------------------------------------

namespace Naos.Recipes.Configuration.Setup
{
    using Its.Configuration;

    using Naos.Serialization.Domain;
    using Naos.Serialization.Json;

    /// <summary>
    /// Static class to hold logic to setup configuration.
    /// </summary>
    [System.Diagnostics.DebuggerStepThrough]
    [System.Diagnostics.CodeAnalysis.ExcludeFromCodeCoverage]
    [System.CodeDom.Compiler.GeneratedCode("Naos.Recipes", "See package version number")]
    internal static class Config
    {
        private static readonly IStringDeserialize deserializer = new NaosJsonSerializer(SerializationKind.Default);

        /// <summary>
        /// Common precedence used after the environment specific precedence.
        /// </summary>
        public const string CommonPrecedence = "Common";

        /// <summary>
        /// Set the precedence in Its.Configuration to the supplied environment followed by "Common".
        /// </summary>
        /// <param name="environment">Environment name that matches the configuration folder in ".config".</param>
        public static void SetupForUnitTest(string environment)
        {
            Settings.Reset();

            SetupSerialization();
            Settings.Precedence = new[] { environment, CommonPrecedence };
        }

        /// <summary>
        /// Set up serialization logic for Newtonsoft and Its.Configuration to use when reading settings.
        /// </summary>
        public static void SetupSerialization()
        {
            Settings.Deserialize = (type, serialized) => deserializer.Deserialize(serialized, type);
        }
    }
}