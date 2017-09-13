﻿// --------------------------------------------------------------------------------------------------------------------
// <copyright file="Run.cs" company="Naos">
//   Copyright 2017 Naos
// </copyright>
// <auto-generated>
//   Sourced from NuGet package. Will be overwritten with package update except in Naos.Recipes source.
// </auto-generated>
// --------------------------------------------------------------------------------------------------------------------

namespace Naos.Recipes.RunWithRetry
{
    using System;
    using System.Threading.Tasks;

    using Spritely.Recipes;
    using Spritely.Redo;

    /// <summary>
    /// Provides methods to run code and retry if that code throws.
    /// </summary>
    [System.Diagnostics.DebuggerStepThrough]
    [System.Diagnostics.CodeAnalysis.ExcludeFromCodeCoverage]
    [System.CodeDom.Compiler.GeneratedCode("Naos.Recipes", "See package version number")]
    internal static class Run
    {
        private const int RetryCount = 5;

        private const int LinearBackoffDelayInSeconds = 5;

        /// <summary>
        /// Runs a function and retries if any exception is thrown, using a linear-delay backoff strategy.
        /// </summary>
        /// <param name="operation">The operation to execute.</param>
        /// <returns>
        /// A task.
        /// </returns>
        public static async Task WithRetryAsync(this Func<Task> operation)
        {
            new { operation }.Must().NotBeNull().OrThrow();

            await Using
                .LinearBackOff(TimeSpan.FromSeconds(LinearBackoffDelayInSeconds))
                .WithMaxRetries(RetryCount)
                .RunAsync(operation)
                .Now();
        }

        /// <summary>
        /// Runs a function and retries if any exception is thrown, using a linear-delay backoff strategy.
        /// </summary>
        /// <typeparam name="T">The type of task returned by the operation.</typeparam>
        /// <param name="operation">The operation to execute.</param>
        /// <returns>
        /// A task of type returned by the operation.
        /// </returns>
        public static async Task<T> WithRetryAsync<T>(this Func<Task<T>> operation)
        {
            new { operation }.Must().NotBeNull().OrThrow();

            var result = await Using
                .LinearBackOff(TimeSpan.FromSeconds(LinearBackoffDelayInSeconds))
                .WithMaxRetries(RetryCount)
                .RunAsync(operation)
                .Now();
            return result;
        }

        /// <summary>
        /// Runs a function and retries if any exception is thrown, using a linear-delay backoff strategy.
        /// </summary>
        /// <param name="operation">The operation to execute.</param>
        /// <param name="reporter">Action to call to report exceptions as they occur.</param>
        /// <param name="messageBuilder">
        /// Optional.  Transforms the exception message and uses that as the Message property of the 
        /// anonymous object that's sent to the <paramref name="reporter"/>.  If null, then the exception's
        /// Message is used.
        /// </param>
        /// <returns>
        /// A task.
        /// </returns>
        public static async Task WithRetryAsync(this Func<Task> operation, Action<object> reporter, Func<Exception, string> messageBuilder = null)
        {
            new { operation }.Must().NotBeNull().OrThrow();
            new { reporter }.Must().NotBeNull().OrThrow();
            new { messageBuilder }.Must().NotBeNull().OrThrow();

            await Using
                .LinearBackOff(TimeSpan.FromSeconds(LinearBackoffDelayInSeconds))
                .WithReporter(_ => reporter(new { Message = messageBuilder == null ? _.Message : messageBuilder(_), Exception = _ }))
                .WithMaxRetries(RetryCount)
                .RunAsync(operation)
                .Now();
        }

        /// <summary>
        /// Runs a function and retries if any exception is thrown, using a linear-delay backoff strategy.
        /// </summary>
        /// <typeparam name="T">The type of task returned by the operation.</typeparam>
        /// <param name="operation">The operation to execute.</param>
        /// <param name="reporter">Action to call to report exceptions as they occur.</param>
        /// <param name="messageBuilder">
        /// Optional.  Transforms the exception message and uses that as the Message property of the 
        /// anonymous object that's sent to the <paramref name="reporter"/>.  If null, then the exception's
        /// Message is used.
        /// </param>
        /// <returns>
        /// A task of type returned by the operation.
        /// </returns>
        public static async Task<T> WithRetryAsync<T>(this Func<Task<T>> operation, Action<object> reporter, Func<Exception, string> messageBuilder = null)
        {
            new { operation }.Must().NotBeNull().OrThrow();
            new { reporter }.Must().NotBeNull().OrThrow();
            new { messageBuilder }.Must().NotBeNull().OrThrow();

            var result = await Using
                .LinearBackOff(TimeSpan.FromSeconds(LinearBackoffDelayInSeconds))
                .WithReporter(_ => reporter(new { Message = messageBuilder == null ? _.Message : messageBuilder(_), Exception = _ }))
                .WithMaxRetries(RetryCount)
                .RunAsync(operation)
                .Now();
            return result;
        }        
    }
}