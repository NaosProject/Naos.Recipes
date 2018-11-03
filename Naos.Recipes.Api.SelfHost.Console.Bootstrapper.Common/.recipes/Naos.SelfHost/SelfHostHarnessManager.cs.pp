﻿// --------------------------------------------------------------------------------------------------------------------
// <copyright file="SelfHostHarnessManager.cs" company="Naos">
//   Copyright (c) Naos 2018. All rights reserved.
// </copyright>
// <auto-generated>
//   Sourced from NuGet package. Will be overwritten with package update except in Naos.Recipes.Api.SelfHost.Bootstrapper.Common source.
// </auto-generated>
// --------------------------------------------------------------------------------------------------------------------

namespace $rootnamespace$
{
    using System;
    using System.Globalization;
    using System.Linq;
    using System.Net.Http.Formatting;
    using System.Threading;
    using System.Web.Http;
    using System.Web.Http.Cors;
    using System.Web.Http.Dispatcher;
    using System.Web.Http.ExceptionHandling;
    using Its.Log.Instrumentation;
    using Microsoft.Owin.Hosting;
    using Microsoft.Owin.Hosting.Tracing;
    using OBeautifulCode.Validation.Recipes;
    using Owin;
    using static System.FormattableString;

    /// <summary>
    /// Entry point to manage a self hosted service.
    /// </summary>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1053:StaticHolderTypesShouldNotHaveConstructors", Justification = "Must be instance for WebApp magic to work.")]
    [System.Diagnostics.CodeAnalysis.ExcludeFromCodeCoverage]
    [System.CodeDom.Compiler.GeneratedCode("Naos.Recipes.Api.SelfHost.Bootstrapper.Common", "See package version number")]
    public class SelfHostHarnessManager
    {
        private static readonly object GlobalObjectLock = new object();
        private static HostingSettings globalHostingSettings;
        private static JwtAuthenticationSettings globalJwtAuthenticationSettings;
        private static ExceptionLogger globalExceptionLogger;
        private static HttpConfiguration globalHttpConfiguration;
        private static ITrackActiveConnections globaActiveConnectionTracker;

        /// <summary>
        /// The main entry point for OWIN Web API.
        /// </summary>
        /// <param name="app">The application.</param>
        public static void Configuration(IAppBuilder app)
        {
            app
                .Use<ConnectionTrackingMiddleware>(globaActiveConnectionTracker)
                .UseCors(globalHostingSettings)
                .UseJwtAuthentication(globalJwtAuthenticationSettings)
                .UseGzipDeflateCompression()
                .UseWebApi(globalHttpConfiguration);
        }

        /// <summary>
        /// Main entry point to launch the self hosted API.
        /// </summary>
        /// <param name="harnessSettings">Harness settings.</param>
        /// <param name="hostingSettings">Hosting settings.</param>
        /// <param name="jwtAuthenticationSettings">Authentication settings.</param>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1062:Validate arguments of public methods", MessageId = "0", Justification = "Is checked, not sure why CA can't figure that out.")]
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Maintainability", "CA1506:AvoidExcessiveClassCoupling", Justification = "Prefer this way.")]
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "jwt", Justification = "Spelling/name is correct.")]
        public static void Launch(HarnessSettings harnessSettings, HostingSettings hostingSettings, JwtAuthenticationSettings jwtAuthenticationSettings)
        {
            using (var httpConfiguration = new HttpConfiguration())
            {
                lock (GlobalObjectLock)
                {
                    new { harnessSettings }.Must().NotBeNull();
                    new { hostingSettings }.Must().NotBeNull();
                    new { jwtAuthenticationSettings }.Must().NotBeNull();

                    if (globalHostingSettings != null || globalJwtAuthenticationSettings != null)
                    {
                        throw new ArgumentException(Invariant($"Attempted to {nameof(Launch)} multiple times."));
                    }

                    globaActiveConnectionTracker = new InMemoryActiveConnectionTracker();
                    globalHostingSettings = hostingSettings;
                    globalJwtAuthenticationSettings = jwtAuthenticationSettings;
                    globalExceptionLogger = new DefaultExceptionLogger();
                    globalHttpConfiguration =
                        BuildHttpConfiguration(globalHostingSettings, globalExceptionLogger, httpConfiguration);
                }

                Log.Write(string.Format(CultureInfo.InvariantCulture, "Web server is starting."));

                var startOptions = new StartOptions(globalHostingSettings.Urls.First());
                globalHostingSettings.Urls.Skip(1).ToList().ForEach(startOptions.Urls.Add);

                // Disable built-in owin tracing by using a null trace output
                // see: https://stackoverflow.com/questions/37527531/owin-testserver-logs-multiple-times-while-testing-how-can-i-fix-this/37548074#37548074
                // and: http://stackoverflow.com/questions/17948363/tracelistener-in-owin-self-hosting
                startOptions.Settings.Add(
                    typeof(ITraceOutputFactory).FullName ?? throw new NotSupportedException(
                        Invariant(
                            $"Should never be in a situation that typeof({nameof(ITraceOutputFactory)}).FullName got null.")),
                    typeof(NullTraceOutputFactory).AssemblyQualifiedName);

                using (WebApp.Start<SelfHostHarnessManager>(startOptions))
                {
                    var launchConfigTimeToLive = harnessSettings.TimeToLive;
                    if (launchConfigTimeToLive == default(TimeSpan))
                    {
                        launchConfigTimeToLive = TimeSpan.MaxValue;
                    }

                    var timeout = DateTime.UtcNow.Add(launchConfigTimeToLive);
                    var allUrls = string.Join(", ", globalHostingSettings.Urls);
                    Log.Write(() => new { LogMessage = Invariant($"SelfHost Server launched on {allUrls}. Will terminate when there are no active connections after: {timeout}.") });

                    // once the timeout has been achieved with no active connections the process will exit (this assumes that a scheduled task will restart the process)
                    //    the main impetus for this was the fact that you could have socket or memory issues so we periodically initiate a graceful entire relaunch.
                    while (globaActiveConnectionTracker.ActiveConnectionsCount != 0 || (DateTime.UtcNow < timeout))
                    {
                        Thread.Sleep(harnessSettings.PollingInterval);
                    }

                    Log.Write(() => new { ex = Invariant($"SelfHost Server terminating. There are no active requests and current time if beyond the timeout: {timeout}.") });
                }

                globalHttpConfiguration?.Dispose();
            }
        }

        private static HttpConfiguration BuildHttpConfiguration(HostingSettings hostingSettings, ExceptionLogger exceptionLogger, HttpConfiguration httpConfiguration)
        {
            /*
            //old json logic
            var jsonSerializerSettings = NewtonsoftJsonSerializerSettingsFactory.BuildSettings(SerializationKind.Compact);
            var jsonFormatter = httpConfiguration.Formatters.JsonFormatter;
            jsonFormatter.MediaTypeMappings.Add(
                new RequestHeaderMapping(
                    "Accept",
                    "text/html",
                    StringComparison.OrdinalIgnoreCase,
                    true,
                    "application/json"));

            jsonFormatter.SerializerSettings = jsonSerializerSettings;
            */

            httpConfiguration.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "{controller}/{id}",
                defaults: new { id = RouteParameter.Optional });

            httpConfiguration.Services.Replace(
                typeof(IHttpControllerSelector),
                new ApiControllerSelector(httpConfiguration));

            httpConfiguration.Services.Add(typeof(IExceptionLogger), exceptionLogger);

            if (hostingSettings?.Cors != null && hostingSettings.Cors.Origins.Any())
            {
                var cors = hostingSettings.Cors;
                var corsPolicyProvider = new EnableCorsAttribute(
                    string.Join(",", cors.Origins),
                    string.Join(",", cors.Headers),
                    string.Join(",", cors.Methods),
                    string.Join(",", cors.ExposedHeaders))
                {
                    SupportsCredentials = cors.SupportsCredentials,
                };

                if (cors.PreflightMaxAge.HasValue)
                {
                    corsPolicyProvider.PreflightMaxAge = cors.PreflightMaxAge.Value;
                }

                httpConfiguration.EnableCors(corsPolicyProvider);
            }

            httpConfiguration.Formatters.Remove(httpConfiguration.Formatters.JsonFormatter);
            httpConfiguration.Formatters.Insert(
                0,
                new NaosJsonFormatter());

            var jsonFormatter = httpConfiguration.Formatters.First();
            jsonFormatter.MediaTypeMappings.Add(
                new RequestHeaderMapping("Accept", "text/html", StringComparison.OrdinalIgnoreCase, true, "application/json"));

            return httpConfiguration;
        }
    }
}