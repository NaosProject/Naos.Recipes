// --------------------------------------------------------------------------------------------------------------------
// <copyright file="Config.cs" company="CoMetrics">
//   Copyright 2017 CoMetrics
// </copyright>
// --------------------------------------------------------------------------------------------------------------------

namespace Naos.Recipes.Configuration.Setup
{
    using Its.Configuration;

    using Newtonsoft.Json;

    using Spritely.Recipes;

    /// <summary>
    /// Static class to hold logic to setup configuration.
    /// </summary>
    internal static partial class Config
    {
        /// <summary>
        /// Set the precedence in Its.Configuration to the supplied environment followed by "Common".
        /// </summary>
        /// <param name="environment">Environment name that matches the configuration folder in ".config".</param>
        public static void SetupForUnitTest(string environment)
        {
            JsonConvert.DefaultSettings = () => JsonConfiguration.DefaultSerializerSettings;
            Settings.Deserialize = (type, serialized) => JsonConvert.DeserializeObject(serialized, type);
            Settings.SettingsDirectory = Settings.SettingsDirectory.Replace("\\bin\\Debug", string.Empty);
            Settings.Precedence = new[] { environment, "Common" };
        }
    }
}