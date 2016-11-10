// --------------------------------------------------------------------------------------------------------------------
// <copyright file="Authorization.cs" company="Naos">
//   Copyright 2015 Naos
// </copyright>
// --------------------------------------------------------------------------------------------------------------------

namespace Naos.Recipes.ItsDomain
{
    using System.Security.Principal;
    using System.Threading;

    using Microsoft.Its.Domain.Authorization;

    /// <summary>
    /// Helper for authorization needs of Its.Domain.
    /// </summary>
    public static class Authorization<T>
        where T : class
    {
        static Authorization()
        {
            AuthorizationFor<AlwaysIsInRolePrincipal>.ToApplyAnyCommand.ToA<T>.Requires((principal, acct) => true);
        }

        /// <summary>
        /// Register the current principal to always allow.
        /// </summary>
        public static void AuthorizeAllCommands()
        {
            Thread.CurrentPrincipal = new AlwaysIsInRolePrincipal();
        }

        /// <summary>
        /// Implementation of <see cref="IPrincipal"/> that always returns true for role membership.
        /// </summary>
        public class AlwaysIsInRolePrincipal : IPrincipal
        {
            /// <inheritdoc />
            public bool IsInRole(string role)
            {
                return true;
            }

            /// <inheritdoc />
            public IIdentity Identity { get; private set; }
        }
    }
}