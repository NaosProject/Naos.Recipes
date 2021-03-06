﻿// --------------------------------------------------------------------------------------------------------------------
// <copyright file="ExampleDummyFactory.cs" company="Naos">
//   Copyright 2015 Naos
// </copyright>
// <auto-generated>
//   Sourced from NuGet package. Will be overwritten with package update except in Naos.Recipes source.
// </auto-generated>
// --------------------------------------------------------------------------------------------------------------------

namespace $rootnamespace$
{
    using System;
    using System.Collections.Generic;

    using FakeItEasy;

    using OBeautifulCode.AutoFakeItEasy;

    /// <summary>
    /// Example of how to control how dummy objects get created.
    /// </summary>
    #if !NaosRecipesInitializeTestProject
        [System.Diagnostics.CodeAnalysis.ExcludeFromCodeCoverage]
        [System.CodeDom.Compiler.GeneratedCode("Naos.Recipes.InitializeTestProject", "See package version number")]
    #endif
    public class ExampleDummyFactory : IDummyFactory
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ExampleDummyFactory"/> class.
        /// </summary>
        public ExampleDummyFactory()
        {
            AutoFixtureBackedDummyFactory.AddDummyCreator(
                () =>
                    {
                        // this need a specific constructor because it takes a read only dictionary as a parameter.
                        var result = new ExampleObject(A.Dummy<string>(), new Dictionary<string, string>());
                        return result;
                    });

            // this has valuse I don't want to use.
            AutoFixtureBackedDummyFactory.ConstrainDummyToExclude(ExampleEnumeration.Invalid);
        }

        /// <inheritdoc />
        public Priority Priority => new Priority(1);

        /// <inheritdoc />
        public bool CanCreate(Type type)
        {
            return false;
        }

        /// <inheritdoc />
        public object Create(Type type)
        {
            return null;
        }
    }

    /// <summary>
    /// Example enumeration that has values I don't want used.
    /// </summary>
    public enum ExampleEnumeration
    {
        /// <summary>
        /// Invalid value.
        /// </summary>
        Invalid,

        /// <summary>
        /// Valid value.
        /// </summary>
        Valid
    }

    /// <summary>
    /// Example object that needs some specific construction.
    /// </summary>
    public class ExampleObject
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ExampleObject"/> class.
        /// </summary>
        /// <param name="name">Name of the object.</param>
        /// <param name="metadata">Metadata about the object.</param>
        public ExampleObject(string name, IReadOnlyDictionary<string, string> metadata)
        {
            this.Name = name;
            this.Metadata = metadata;
        }

        /// <summary>
        /// Gets the name of the object.
        /// </summary>
        public string Name { get; private set; }

        /// <summary>
        /// Gets metadata about the object.
        /// </summary>
        public IReadOnlyDictionary<string, string> Metadata { get; private set; }

    }
}